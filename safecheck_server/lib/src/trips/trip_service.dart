import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../companion/incident_service.dart';
import '../companion/companion_ai.dart';
import '../companion/safety_plan_service.dart';

import '../common/links.dart';
import '../common/owner_lock.dart';
import '../common/validation.dart';
import '../generated/future_calls.dart';
import '../generated/protocol.dart';
import '../messaging/message_dispatcher.dart';
import '../tracking/tracking_service.dart';

/// Trip lifecycle rules shared by the endpoint and the deadline future call.
///
/// A trip leaves the `active` state exactly once. Both ways out (check-in and
/// missed deadline) use a single conditional `UPDATE ... WHERE status =
/// 'active'`, so Postgres row locking guarantees that only one of any number
/// of concurrent attempts succeeds. Everything else (alert and message rows)
/// is written in the same transaction as the winning update.
abstract final class TripService {
  /// Identifier of the future call that processes [tripId]'s deadline.
  static String deadlineCallId(int tripId) => 'trip-deadline-$tripId';

  /// Identifier of the recurring safety-net sweep.
  static const sweepCallId = 'trip-overdue-sweep';

  static Future<TripSnapshot> getActive(Session session, String ownerId) async {
    await _processOverdueFor(session, ownerId);
    final trip = await _findActive(session, ownerId);
    return TripSnapshot(trip: trip, serverTime: _now());
  }

  static Future<TripSnapshot> start(
    Session session,
    String ownerId, {
    required TripType tripType,
    required String description,
    required int durationMinutes,
    DateTime? exactDeadline,
    List<int>? contactIds,
    int graceMinutes = 0,
    String? safetyPlanJson,
    bool companionMode = false,
    bool useAiIncidentSummary = false,
    bool allowContactResolution = false,
    LocationSharing locationSharing = LocationSharing.off,
  }) async {
    final cleanDescription = cleanText(
      description,
      field: 'Trip description',
      maxLength: maxDescriptionLength,
    );
    validateDuration(durationMinutes);
    SafetyPlanService.validateGrace(graceMinutes);
    String? reviewedPlan;
    if (companionMode) {
      try {
        if (safetyPlanJson != null && safetyPlanJson.length > 4096) {
          throw const FormatException();
        }
        reviewedPlan = jsonEncode(
          safetyPlanJson == null
              ? standardPlan()
              : validateSafetyPlan(jsonDecode(safetyPlanJson)),
        );
      } catch (_) {
        throw validationError('Review a valid safety plan before starting.');
      }
    }

    // A previous trip whose deadline already passed must be closed (and its
    // alert raised) before the user can start a new one.
    await _processOverdueFor(session, ownerId);

    final trip = await session.db.transaction((transaction) async {
      await lockOwner(session, ownerId, transaction);

      final profile = await UserProfile.db.findFirstRow(
        session,
        where: (t) => t.ownerId.equals(ownerId),
        transaction: transaction,
      );
      if (profile == null) {
        throw validationError('Set up your profile before starting a trip.');
      }

      var contacts = await TrustedContact.db.find(
        session,
        where: (t) => t.ownerId.equals(ownerId),
        orderBy: (t) => t.id,
        transaction: transaction,
      );
      if (contactIds != null) {
        final ids = contactIds.toSet();
        if (ids.isEmpty ||
            ids.length != contactIds.length ||
            ids.length > 5 ||
            !ids.every((id) => contacts.any((c) => c.id == id))) {
          throw validationError(
            'Select current trusted contacts from your own account.',
          );
        }
        contacts = contacts.where((c) => ids.contains(c.id)).toList();
      }
      if (contacts.isEmpty) {
        throw validationError(
          'Add at least one trusted contact before starting a trip.',
        );
      }

      final active = await _findActive(session, ownerId, transaction);
      if (active != null) {
        throw conflictError(
          'You already have an active trip. Check in before starting another.',
        );
      }

      final now = _now();
      final deadline =
          exactDeadline?.toUtc() ?? now.add(Duration(minutes: durationMinutes));
      final remaining = deadline.difference(now);
      if (remaining < const Duration(minutes: 1) ||
          remaining > const Duration(hours: 24)) {
        throw validationError(
          'Choose a check-in time between one minute and 24 hours from now. '
          'Your draft may have expired; review a new time.',
        );
      }
      final trip = await Trip.db.insertRow(
        session,
        Trip(
          ownerId: ownerId,
          activeOwnerId: ownerId,
          tripType: tripType,
          description: cleanDescription,
          durationMinutes: exactDeadline == null
              ? durationMinutes
              : (remaining.inMicroseconds /
                        const Duration(minutes: 1).inMicroseconds)
                    .ceil(),
          startedAt: now,
          deadline: deadline,
          status: TripStatus.active,
          companionMode: companionMode,
          graceMinutes: graceMinutes,
          alertAt: graceMinutes == 0
              ? null
              : deadline.add(Duration(minutes: graceMinutes)),
          safetyPlanJson: reviewedPlan,
          useAiIncidentSummary: companionMode && useAiIncidentSummary,
          contacts: [
            for (final c in contacts)
              ContactSnapshot(
                name: c.name,
                canResolveIncident:
                    allowContactResolution &&
                    c.optInStatus == ContactOptInStatus.accepted,
                phoneNumber: c.phoneNumber,
                relationship: c.relationship,
                optedIn: c.optInStatus == ContactOptInStatus.accepted,
                notifyByWhatsapp: c.notifyByWhatsapp,
                notifyBySms: c.notifyBySms,
              ),
          ],
          locationSharing: locationSharing,
        ),
        transaction: transaction,
      );

      if (locationSharing != LocationSharing.off) {
        await TrackingLink.db.insert(session, [
          for (final c in trip.contacts)
            TrackingLink(
              token: generateToken(),
              ownerId: ownerId,
              tripId: trip.id!,
              contactName: c.name,
              contactPhone: c.phoneNumber,
              createdAt: now,
            ),
        ], transaction: transaction);
      }
      return trip;
    });

    await _scheduleDeadline(session, trip);
    return TripSnapshot(trip: trip, serverTime: _now());
  }

  /// Marks the owner's active trip [tripId] as safe. Repeating a successful
  /// check-in returns the same result. Checking in after the deadline fails
  /// and makes sure the alert has been created.
  static Future<TripSnapshot> checkIn(
    Session session,
    String ownerId,
    int tripId,
  ) async {
    final now = _now();
    final updated = await Trip.db.updateWhere(
      session,
      columnValues: (t) => [
        t.status(TripStatus.checkedIn),
        t.endedAt(now),
        t.activeOwnerId(null),
      ],
      where: (t) =>
          t.id.equals(tripId) &
          t.ownerId.equals(ownerId) &
          t.status.equals(TripStatus.active) &
          ((t.alertAt > now) | (t.alertAt.equals(null) & (t.deadline > now))),
    );

    if (updated.isNotEmpty) {
      await _cancelDeadline(session, tripId);
      return TripSnapshot(endedTrip: updated.single, serverTime: _now());
    }

    // The update did not apply: work out why, without revealing other
    // users' trips.
    final trip = await Trip.db.findFirstRow(
      session,
      where: (t) => t.id.equals(tripId) & t.ownerId.equals(ownerId),
    );
    if (trip == null) {
      throw notFoundError('That trip could not be found.');
    }
    switch (trip.status) {
      case TripStatus.checkedIn:
        return TripSnapshot(endedTrip: trip, serverTime: _now());
      case TripStatus.active:
        // Deadline passed but the future call has not run yet.
        await processDeadline(session, tripId);
        throw conflictError(
          'The check-in deadline has passed, so an alert was created for '
          'your trusted contacts.',
        );
      case TripStatus.missed:
        throw conflictError(
          'The check-in deadline has passed, so an alert was created for '
          'your trusted contacts.',
        );
    }
  }

  static Future<List<Trip>> history(Session session, String ownerId) async {
    await _processOverdueFor(session, ownerId);
    return Trip.db.find(
      session,
      where: (t) => t.ownerId.equals(ownerId),
      orderBy: (t) => t.startedAt.desc(),
      limit: 50,
    );
  }

  /// Closes trip [tripId] as missed and creates its alert and simulated SMS
  /// messages, if the trip is still active and its deadline has passed.
  ///
  /// Safe to call any number of times, concurrently, and concurrently with a
  /// check-in: only one caller can move the trip out of `active`, and the
  /// unique index on `safety_alert.tripId` backs this up. Returns the alert
  /// when this call created it, otherwise null.
  static Future<SafetyAlert?> processDeadline(Session session, int tripId) =>
      _raiseAlert(session, tripId);

  static Future<TripSnapshot> requestHelp(
    Session session,
    String owner,
    int tripId,
  ) async {
    final trip = await Trip.db.findFirstRow(
      session,
      where: (t) => t.id.equals(tripId) & t.ownerId.equals(owner),
    );
    if (trip == null) throw notFoundError('That journey could not be found.');
    if (trip.status != TripStatus.active) {
      throw conflictError('This journey has already ended.');
    }
    final alert = await _raiseAlert(session, tripId, helpForOwner: owner);
    if (alert == null) throw conflictError('This journey has already ended.');
    await _cancelDeadline(session, tripId);
    return TripSnapshot(
      endedTrip: await Trip.db.findById(session, tripId),
      serverTime: _now(),
    );
  }

  static Future<TripSnapshot> extend(
    Session session,
    String owner,
    int tripId,
    int minutes,
  ) async {
    if (minutes < 1 || minutes > 120) {
      throw validationError('Extend by between 1 and 120 minutes.');
    }
    final trip = await session.db.transaction((tx) async {
      await lockOwner(session, owner, tx);
      final existing = await Trip.db.findFirstRow(
        session,
        where: (t) => t.id.equals(tripId) & t.ownerId.equals(owner),
        transaction: tx,
      );
      if (existing == null) {
        throw notFoundError('That journey could not be found.');
      }
      final now = _now();
      if (existing.status != TripStatus.active ||
          !now.isBefore(existing.alertAt ?? existing.deadline)) {
        throw conflictError('This journey can no longer be extended.');
      }
      final base = existing.deadline.isAfter(now) ? existing.deadline : now;
      final deadline = base.add(Duration(minutes: minutes));
      if (deadline.difference(existing.startedAt) > const Duration(hours: 24)) {
        throw validationError('A journey cannot exceed 24 hours.');
      }
      final updated = await Trip.db.updateWhere(
        session,
        columnValues: (t) => [
          t.deadline(deadline),
          t.alertAt(
            existing.graceMinutes == 0
                ? null
                : deadline.add(Duration(minutes: existing.graceMinutes)),
          ),
          t.durationMinutes(deadline.difference(existing.startedAt).inMinutes),
        ],
        where: (t) =>
            t.id.equals(tripId) &
            t.ownerId.equals(owner) &
            t.status.equals(TripStatus.active) &
            ((t.alertAt > now) | (t.alertAt.equals(null) & (t.deadline > now))),
        transaction: tx,
      );
      if (updated.isEmpty) {
        throw conflictError(
          'The journey ended before this extension was saved.',
        );
      }
      return updated.single;
    });
    // Queue operations stay outside the trip transaction. An old or racing job
    // rechecks the stored deadline, and the sweep recovers a lost replacement.
    await _cancelDeadline(session, tripId);
    final latest = await Trip.db.findById(session, tripId);
    if (latest?.status == TripStatus.active) {
      await _scheduleDeadline(session, latest!);
    }
    return TripSnapshot(trip: trip, serverTime: _now());
  }

  static Future<SafetyAlert?> _raiseAlert(
    Session session,
    int tripId, {
    String? helpForOwner,
  }) async {
    final now = _now();
    final alert = await session.db.transaction((transaction) async {
      final updated = await Trip.db.updateWhere(
        session,
        columnValues: (t) => [
          t.status(TripStatus.missed),
          t.endedAt(now),
          t.activeOwnerId(null),
          if (helpForOwner != null) t.helpRequestedAt(now),
          if (helpForOwner != null) t.companionMode(true),
        ],
        where: (t) =>
            t.id.equals(tripId) &
            t.status.equals(TripStatus.active) &
            (helpForOwner != null
                ? t.ownerId.equals(helpForOwner)
                : ((t.alertAt <= now) |
                      (t.alertAt.equals(null) & (t.deadline <= now)))),
        transaction: transaction,
      );
      if (updated.isEmpty) return null;
      final trip = updated.single;

      final profile = await UserProfile.db.findFirstRow(
        session,
        where: (t) => t.ownerId.equals(trip.ownerId),
        transaction: transaction,
      );
      final travellerName = profile?.displayName ?? 'A SafeCheck user';
      final travellerPhone = profile?.phoneNumber ?? 'unknown number';

      var alert = await SafetyAlert.db.insertRow(
        session,
        SafetyAlert(
          ownerId: trip.ownerId,
          tripId: trip.id!,
          travellerName: travellerName,
          travellerPhone: travellerPhone,
          tripType: trip.tripType,
          tripDescription: trip.description,
          deadline: trip.deadline,
          createdAt: now,
          contacts: trip.contacts,
          reason: helpForOwner == null
              ? AlertReason.missedCheckIn
              : AlertReason.helpRequested,
          briefStatus: trip.companionMode && trip.useAiIncidentSummary
              ? BriefStatus.pending
              : BriefStatus.fallback,
        ),
        transaction: transaction,
      );

      // Each contact's own tracking link, if the trip shares location.
      final links = await TrackingLink.db.find(
        session,
        where: (t) => t.tripId.equals(trip.id!),
        transaction: transaction,
      );
      final linkByPhone = {
        for (final l in links) l.contactPhone: trackingUrl(session, l.token),
      };

      final incidentLinks = <String, String>{};
      if (trip.companionMode) {
        final brief = await IncidentService.initialBrief(
          session,
          trip,
          alert,
          transaction,
        );
        alert = await SafetyAlert.db.updateRow(
          session,
          alert.copyWith(brief: brief),
          transaction: transaction,
        );
        incidentLinks.addAll(
          await IncidentService.createLinks(
            session,
            trip,
            alert,
            linkByPhone,
            transaction,
          ),
        );
      }
      if (trip.contacts.isNotEmpty) {
        final messages = <AlertMessage>[];

        for (final contact in trip.contacts) {
          final body = trip.companionMode
              ? 'SafeCheck: $travellerName '
                    '${alert.reason == AlertReason.helpRequested ? 'requested help' : 'missed a check-in'}. '
                    'Journey: ${trip.description}. Deadline ${formatSast(trip.deadline)}. '
                    'Safety is unconfirmed. Try contacting the traveller.'
                    '${incidentLinks[contact.phoneNumber] == null ? '' : '\nIncident: ${incidentLinks[contact.phoneNumber]}'}'
                    '${linkByPhone[contact.phoneNumber] == null ? '' : '\nTrack:\n${linkByPhone[contact.phoneNumber]}'}'
              : alertMessageBody(
                  travellerName: travellerName,
                  trackingUrl: linkByPhone[contact.phoneNumber],
                );

          if (contact.optedIn == true && contact.notifyByWhatsapp) {
            messages.add(
              AlertMessage(
                ownerId: trip.ownerId,
                alertId: alert.id!,
                tripId: trip.id!,
                recipientName: contact.name,
                recipientPhone: contact.phoneNumber,
                channel: MessageChannel.whatsapp,
                status: MessageStatus.pending,
                body: body,
                createdAt: now,
              ),
            );
          }

          if (contact.notifyBySms) {
            messages.add(
              AlertMessage(
                ownerId: trip.ownerId,
                alertId: alert.id!,
                tripId: trip.id!,
                recipientName: contact.name,
                recipientPhone: contact.phoneNumber,
                channel: MessageChannel.sms,
                status: MessageStatus.pending,
                body: body,
                createdAt: now,
              ),
            );
          }
        }

        if (messages.isNotEmpty) {
          await AlertMessage.db.insert(
            session,
            messages,
            transaction: transaction,
          );
        }
      }
      return alert;
    });

    if (alert != null) {
      session.log(
        'Trip $tripId created ${alert.reason.name} alert ${alert.id} for '
        '${alert.contacts.length} contact(s).',
        level: LogLevel.warning,
      );
      await MessageDispatcher.dispatchPending(session, alertId: alert.id);
      if (alert.briefStatus == BriefStatus.pending) {
        await IncidentService.schedule(session, alert.id!);
      }
    }
    return alert;
  }

  /// Returns each contact's tracking link for the owner's trip [tripId], so
  /// the owner can share them. Empty if the trip does not share location.
  static Future<List<TrackingLinkInfo>> trackingLinks(
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
    final links = await TrackingLink.db.find(
      session,
      where: (t) => t.tripId.equals(tripId) & t.ownerId.equals(ownerId),
      orderBy: (t) => t.id,
    );
    return [
      for (final l in links)
        TrackingLinkInfo(
          contactName: l.contactName,
          contactPhone: l.contactPhone,
          url: trackingUrl(session, l.token),
        ),
    ];
  }

  /// Processes every active trip whose deadline has passed. Used as a safety
  /// net in case a per-trip future call was lost or could not be scheduled.
  static Future<int> sweepOverdue(Session session) async {
    final overdue = await Trip.db.find(
      session,
      where: (t) => t.status.equals(TripStatus.active) & (t.deadline <= _now()),
      orderBy: (t) => t.deadline,
      limit: 200,
    );
    var created = 0;
    for (final trip in overdue) {
      if (await processDeadline(session, trip.id!) != null) created++;
    }
    // Finish any messages left unsent by a crash, and apply retention.
    await MessageDispatcher.releaseStuck(session);
    await MessageDispatcher.dispatchPending(session);
    await TrackingService.deleteExpiredLocations(session);
    await IncidentService.recoverSummaries(session);
    return created;
  }

  static Future<void> _processOverdueFor(
    Session session,
    String ownerId,
  ) async {
    final overdue = await Trip.db.find(
      session,
      where: (t) =>
          t.ownerId.equals(ownerId) &
          t.status.equals(TripStatus.active) &
          (t.deadline <= _now()),
    );
    for (final trip in overdue) {
      await processDeadline(session, trip.id!);
    }
  }

  static Future<Trip?> _findActive(
    Session session,
    String ownerId, [
    Transaction? transaction,
  ]) {
    return Trip.db.findFirstRow(
      session,
      where: (t) =>
          t.ownerId.equals(ownerId) & t.status.equals(TripStatus.active),
      transaction: transaction,
    );
  }

  static Future<void> _scheduleDeadline(Session session, Trip trip) async {
    try {
      await FutureCalls()
          .callAtTime(
            trip.alertAt ?? trip.deadline,
            identifier: deadlineCallId(trip.id!),
          )
          .tripDeadline
          .processDeadline(trip.id!);
    } catch (e, stackTrace) {
      // The recurring sweep still processes the trip, so starting the trip
      // must not fail because of this.
      session.log(
        'Could not schedule deadline call for trip ${trip.id}',
        level: LogLevel.error,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> _cancelDeadline(Session session, int tripId) async {
    try {
      await FutureCalls().cancel(deadlineCallId(tripId));
    } catch (e, stackTrace) {
      // Harmless: a call that still fires finds the trip already closed.
      session.log(
        'Could not cancel deadline call for trip $tripId',
        level: LogLevel.warning,
        exception: e,
        stackTrace: stackTrace,
      );
    }
  }

  static DateTime _now() => DateTime.now().toUtc();
}

/// Builds the text of a SafeCheck alert message for SMS or WhatsApp.
String alertMessageBody({required String travellerName, String? trackingUrl}) {
  final tracking = trackingUrl == null ? '' : '\nTrack:\n$trackingUrl';
  return 'SafeCheck: $travellerName missed check-in.$tracking';
}

String tripTypeLabel(TripType type) => switch (type) {
  TripType.walking => 'Walking',
  TripType.minibusTaxi => 'Minibus taxi',
  TripType.rideHailing => 'Ride-hailing',
  TripType.driving => 'Driving',
  TripType.publicTransport => 'Public transport',
  TripType.meetingSomeone => 'Meeting someone',
  TripType.other => 'Other',
};

/// Formats [time] in South African Standard Time (UTC+2, no daylight saving).
String formatSast(DateTime time) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final t = time.toUtc().add(const Duration(hours: 2));
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)} SAST on '
      '${t.day} ${months[t.month - 1]} ${t.year}';
}
