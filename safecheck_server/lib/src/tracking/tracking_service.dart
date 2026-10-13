import 'package:serverpod/serverpod.dart';

import '../common/validation.dart';
import '../generated/protocol.dart';

/// What a contact's tracking page shows.
class TrackingView {
  const TrackingView({
    required this.travellerName,
    required this.trip,
    required this.showLocation,
    required this.message,
    this.points = const [],
  });

  final String travellerName;
  final Trip trip;

  /// Whether the location may be shown right now.
  final bool showLocation;

  /// Explains the current state to the contact.
  final String message;
  final List<TripLocation> points;
}

/// Location collection and the rules for who may see it.
///
/// Contacts see a trip's location through their own secret link:
/// - `live` trips: while the trip is active.
/// - `afterAlert` trips: only once a missed check-in raised an alert.
/// - After a missed check-in (either mode): for [alertVisibility].
/// - After a safe check-in: never again.
abstract final class TrackingService {
  /// How long contacts can see the location after a missed check-in.
  static const alertVisibility = Duration(hours: 48);

  /// Points that arrive this long after the trip ended are rejected.
  static const lateUploadWindow = Duration(minutes: 15);

  /// Stored points are deleted after this long.
  static const retention = Duration(days: 30);

  static const maxPointsPerUpload = 100;
  static const maxPointsShown = 2000;

  /// Stores the owner's GPS fixes for trip [tripId]. Returns how many were
  /// stored; duplicates of already stored fixes are skipped.
  static Future<int> record(
    Session session,
    String ownerId,
    int tripId,
    List<LocationPoint> points,
  ) async {
    if (points.isEmpty) return 0;
    if (points.length > maxPointsPerUpload) {
      throw validationError(
        'Send at most $maxPointsPerUpload location points at a time.',
      );
    }

    final trip = await Trip.db.findFirstRow(
      session,
      where: (t) => t.id.equals(tripId) & t.ownerId.equals(ownerId),
    );
    if (trip == null) {
      throw notFoundError('That trip could not be found.');
    }
    if (trip.locationSharing == LocationSharing.off) {
      throw conflictError('Location sharing is off for this trip.');
    }

    final now = DateTime.now().toUtc();
    final endedAt = trip.endedAt;
    if (trip.status != TripStatus.active &&
        (endedAt == null || now.isAfter(endedAt.add(lateUploadWindow)))) {
      throw conflictError('This trip has ended, so location is not saved.');
    }

    // Accept fixes from the trip itself: not before it started, not after it
    // ended, and not from the future (allowing for small clock differences).
    const skew = Duration(minutes: 2);
    final earliest = trip.startedAt.subtract(skew);
    final latest = (endedAt ?? now).add(skew);
    for (final p in points) {
      if (p.latitude.isNaN ||
          p.longitude.isNaN ||
          p.latitude < -90 ||
          p.latitude > 90 ||
          p.longitude < -180 ||
          p.longitude > 180) {
        throw validationError('Location coordinates are out of range.');
      }
      final accuracy = p.accuracyMeters;
      if (accuracy != null && (accuracy.isNaN || accuracy < 0)) {
        throw validationError('Location accuracy is invalid.');
      }
    }
    final inWindow = points.where((p) {
      final at = p.recordedAt.toUtc();
      return !at.isBefore(earliest) && !at.isAfter(latest);
    }).toList();
    if (inWindow.isEmpty) return 0;

    // Retries resend the same fixes; skip ones already stored.
    final times = inWindow.map((p) => p.recordedAt.toUtc()).toList()..sort();
    final existing = await TripLocation.db.find(
      session,
      where: (t) =>
          t.tripId.equals(tripId) &
          t.recordedAt.between(times.first, times.last),
    );
    final seen = {for (final e in existing) e.recordedAt.toUtc()};
    final fresh = <TripLocation>[];
    for (final p in inWindow) {
      final at = p.recordedAt.toUtc();
      if (!seen.add(at)) continue;
      fresh.add(
        TripLocation(
          ownerId: ownerId,
          tripId: tripId,
          latitude: p.latitude,
          longitude: p.longitude,
          accuracyMeters: p.accuracyMeters,
          recordedAt: at,
          receivedAt: now,
        ),
      );
    }
    if (fresh.isNotEmpty) {
      await TripLocation.db.insert(session, fresh);
    }
    return fresh.length;
  }

  /// Resolves a contact's tracking link. Returns null for unknown tokens.
  static Future<TrackingView?> view(
    Session session,
    String token, {
    DateTime? now,
  }) async {
    if (token.length < 20) return null;
    final link = await TrackingLink.db.findFirstRow(
      session,
      where: (t) => t.token.equals(token),
    );
    if (link == null) return null;
    final trip = await Trip.db.findById(session, link.tripId);
    if (trip == null) return null;

    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(trip.ownerId),
    );
    final name = profile?.displayName ?? 'The traveller';
    now = (now ?? DateTime.now()).toUtc();

    TrackingView hidden(String message) => TrackingView(
      travellerName: name,
      trip: trip,
      showLocation: false,
      message: message,
    );

    switch (trip.status) {
      case TripStatus.checkedIn:
        return hidden(
          '$name checked in safely. Location sharing has ended.',
        );
      case TripStatus.active:
        if (trip.locationSharing != LocationSharing.live) {
          return hidden(
            "$name's location will only be shown here if they miss their "
            'check-in.',
          );
        }
      case TripStatus.missed:
        final endedAt = trip.endedAt ?? trip.deadline;
        if (now.isAfter(endedAt.add(alertVisibility))) {
          return hidden('This link has expired.');
        }
    }

    final points = await TripLocation.db.find(
      session,
      where: (t) => t.tripId.equals(trip.id!),
      orderBy: (t) => t.recordedAt.desc(),
      limit: maxPointsShown,
    );
    return TrackingView(
      travellerName: name,
      trip: trip,
      showLocation: true,
      message: trip.status == TripStatus.missed
          ? '$name missed their check-in. This is their last known location.'
          : '$name is sharing their trip with you live.',
      points: points.reversed.toList(),
    );
  }

  /// Returns stored GPS points for a trip owned by [ownerId].
  static Future<List<TripLocation>> ownerLocations(
    Session session,
    String ownerId,
    int tripId,
  ) async {
    final trip = await Trip.db.findFirstRow(
      session,
      where: (t) => t.id.equals(tripId) & t.ownerId.equals(ownerId),
    );

    if (trip == null) {
      throw notFoundError('That trip could not be found.');
    }

    final points = await TripLocation.db.find(
      session,
      where: (t) => t.tripId.equals(tripId) & t.ownerId.equals(ownerId),
      orderBy: (t) => t.recordedAt.desc(),
      limit: maxPointsShown,
    );

    return points.reversed.toList();
  }

  /// Deletes location points older than [retention].
  static Future<void> deleteExpiredLocations(Session session) async {
    final cutoff = DateTime.now().toUtc().subtract(retention);
    await TripLocation.db.deleteWhere(
      session,
      where: (t) => t.receivedAt < cutoff,
    );
  }
}
