import 'package:serverpod/serverpod.dart';

import '../common/validation.dart';
import '../generated/protocol.dart';
import 'trip_service.dart';

/// Starts trips, checks in and lists trip history for the signed-in user.
class TripEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the caller's active trip (if any) and the server time.
  Future<TripSnapshot> getActiveTrip(Session session) {
    return TripService.getActive(session, ownerIdOf(session));
  }

  /// Starts a trip. The deadline is computed on the server from
  /// [durationMinutes]. Fails if the caller already has an active trip.
  /// [locationSharing] decides whether contacts can see the trip's location.
  Future<TripSnapshot> startTrip(
    Session session,
    TripType tripType,
    String description,
    int durationMinutes, [
    LocationSharing? locationSharing,
  ]) {
    return TripService.start(
      session,
      ownerIdOf(session),
      tripType: tripType,
      description: description,
      durationMinutes: durationMinutes,
      locationSharing: locationSharing ?? LocationSharing.off,
    );
  }

  /// Starts a reviewed plan at its approved absolute deadline. The server
  /// revalidates the time at confirmation; it never shifts a stale draft.
  Future<TripSnapshot> startPlannedTrip(
    Session session,
    TripType tripType,
    String description,
    DateTime checkInAtUtc,
    LocationSharing locationSharing,
  ) {
    return TripService.start(
      session,
      ownerIdOf(session),
      tripType: tripType,
      description: description,
      durationMinutes: 1,
      exactDeadline: checkInAtUtc,
      locationSharing: locationSharing,
    );
  }

  /// Checks in safely on the caller's active trip [tripId].
  Future<TripSnapshot> checkIn(Session session, int tripId) {
    return TripService.checkIn(session, ownerIdOf(session), tripId);
  }

  /// Lists the caller's 50 most recent trips, newest first.
  Future<List<Trip>> history(Session session) {
    return TripService.history(session, ownerIdOf(session));
  }

  /// Each contact's tracking link for the caller's trip [tripId], for the
  /// caller to share. Empty when the trip does not share location.
  Future<List<TrackingLinkInfo>> getTrackingLinks(Session session, int tripId) {
    return TripService.trackingLinks(session, ownerIdOf(session), tripId);
  }
}
