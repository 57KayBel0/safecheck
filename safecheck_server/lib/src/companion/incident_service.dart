import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import '../common/links.dart';
import '../common/owner_lock.dart';
import '../common/validation.dart';
import '../generated/protocol.dart';
import '../generated/future_calls.dart';
import '../planning/planning_service.dart';
import '../planning/meta_trip_planner.dart';
import '../trips/trip_service.dart' show formatSast, tripTypeLabel;
import 'companion_ai.dart';
import 'safety_plan_service.dart';

abstract final class IncidentService {
  static final _running = <int>{};
  static String hashToken(String token) =>
      sha256.convert(utf8.encode(token)).toString();

  static Future<IncidentBrief> initialBrief(
    Session session,
    Trip trip,
    SafetyAlert alert,
    Transaction transaction,
  ) async {
    TripLocation? location;
    if (trip.locationSharing != LocationSharing.off) {
      location = await TripLocation.db.findFirstRow(
        session,
        where: (p) =>
            p.tripId.equals(trip.id!) & p.ownerId.equals(trip.ownerId),
        orderBy: (p) => p.recordedAt.desc(),
        transaction: transaction,
      );
    }
    final facts = <String>[
      alert.reason == AlertReason.helpRequested
          ? 'The traveller explicitly requested help.'
          : 'The scheduled check-in was not recorded before the alert time.',
      'Traveller-reported journey: ${trip.description}',
      'Transport: ${tripTypeLabel(trip.tripType)}.',
      'Check-in deadline: ${formatSast(trip.deadline)}.',
      'Grace period: ${trip.graceMinutes} minutes. Alert recorded: ${formatSast(alert.createdAt)}.',
      if (location != null)
        'Last consented location was recorded at ${formatSast(location.recordedAt)}; it is not guaranteed live.',
    ];
    return IncidentBrief(
      source: 'standard',
      overview: facts.first,
      facts: facts,
      unknowns: [
        'The traveller’s current safety has not been independently confirmed.',
        'A missed check-in is not proof of danger.',
        if (location == null)
          'No consented location is available for this brief.',
        'An alert record does not confirm message delivery.',
      ],
      nextSteps: [
        incidentActions['callTraveller']!,
        incidentActions['checkTiming']!,
        if (location != null) incidentActions['reviewLocation']!,
        incidentActions['urgentEvidence']!,
      ],
      generatedAt: alert.createdAt,
    );
  }

  static Future<Map<String, String>> createLinks(
    Session session,
    Trip trip,
    SafetyAlert alert,
    Map<String, String> tracking,
    Transaction transaction,
  ) async {
    final links = <String, String>{};
    for (final contact in trip.contacts) {
      final token = generateToken();
      String url;
      try {
        url = publicWebUrl(session, '/incident/$token');
      } catch (_) {
        continue;
      } // A link configuration error must not block the alert.
      await IncidentAccess.db.insertRow(
        session,
        IncidentAccess(
          tokenHash: hashToken(token),
          ownerId: trip.ownerId,
          alertId: alert.id!,
          contactName: contact.name,
          canResolve: contact.canResolveIncident && contact.optedIn == true,
          trackingUrl: tracking[contact.phoneNumber],
          createdAt: alert.createdAt,
          expiresAt: alert.createdAt.add(const Duration(hours: 48)),
        ),
        transaction: transaction,
      );
      links[contact.phoneNumber] = url;
    }
    return links;
  }

  /// Scheduling is best-effort. The standard brief and notification outbox
  /// already exist. The sweep recovers a lost scheduling attempt.
  static Future<void> schedule(Session session, int alertId) async {
    try {
      await session.serverpod.futureCalls
          .callWithDelay(
            const Duration(seconds: 1),
            identifier: 'incident-summary-$alertId',
          )
          .incidentSummary
          .generate(alertId);
    } catch (_) {
      session.log(
        'Incident summary scheduling deferred.',
        level: LogLevel.warning,
      );
    }
  }

  /// A future call only launches bounded independent work. Waiting for Meta
  /// never occupies the deadline future-call worker or its database transaction.
  static void launch(Serverpod pod, int alertId) {
    if (_running.length >= 2 || !_running.add(alertId)) return;
    unawaited(
      _generate(
        pod,
        alertId,
      ).catchError((Object _) {}).whenComplete(() => _running.remove(alertId)),
    );
  }

  static Future<void> _generate(Serverpod pod, int alertId) async {
    final session = await pod.createSession(enableLogging: false);
    try {
      await enrich(session, alertId);
    } finally {
      await session.close();
    }
  }

  /// Shared by the independent worker and integration tests.
  static Future<void> enrich(Session session, int alertId) async {
    try {
      final claimed = await SafetyAlert.db.updateWhere(
        session,
        columnValues: (a) => [
          a.briefStatus(BriefStatus.processing),
          a.briefAttemptedAt(DateTime.now().toUtc()),
        ],
        where: (a) =>
            a.id.equals(alertId) &
            a.briefStatus.equals(BriefStatus.pending) &
            a.resolvedAt.equals(null),
      );
      if (claimed.isEmpty) return;
      final alert = claimed.single;
      final brief = alert.brief;
      if (brief == null) throw const FormatException();
      final ai = SafetyPlanService.aiFor(session);
      if (!ai.isConfigured) throw const FormatException();
      await PlanningService.reserveRequest(session, alert.ownerId);
      final raw = await ai.organizeIncident({
        'facts': brief.facts,
        'unknowns': brief.unknowns,
        'locationAvailable': brief.facts.any(
          (f) => f.startsWith('Last consented location'),
        ),
        'allowedActions': incidentActions.keys.toList(),
      });
      final organized = organizeBrief(brief, raw);
      await SafetyAlert.db.updateWhere(
        session,
        columnValues: (a) => [
          a.brief(organized),
          a.briefStatus(BriefStatus.ready),
        ],
        where: (a) =>
            a.id.equals(alertId) &
            a.briefStatus.equals(BriefStatus.processing) &
            a.resolvedAt.equals(null),
      );
    } catch (error) {
      final reason = error is TripPlanningException
          ? error.failure.name
          : 'invalidResponse';
      session.log('Incident AI fallback: $reason.', level: LogLevel.warning);
      await SafetyAlert.db.updateWhere(
        session,
        columnValues: (a) => [a.briefStatus(BriefStatus.fallback)],
        where: (a) =>
            a.id.equals(alertId) & a.briefStatus.equals(BriefStatus.processing),
      );
    }
  }

  static IncidentBrief organizeBrief(
    IncidentBrief base,
    Map<String, dynamic> raw,
  ) {
    List<int> indexes(String key, int max) {
      final list = raw[key];
      if (list is! List ||
          list.isEmpty ||
          list.length > max ||
          list.any((i) => i is! int || i < 0 || i >= base.facts.length) ||
          list.toSet().length != list.length) {
        throw const FormatException();
      }
      return list.cast<int>();
    }

    if (raw.length != 3 ||
        !raw.keys.toSet().containsAll({
          'overviewFacts',
          'factOrder',
          'actionCodes',
        })) {
      throw const FormatException();
    }
    final overview = indexes('overviewFacts', 3);
    final order = indexes('factOrder', 12);
    final codes = raw['actionCodes'];
    final hasLocation = base.facts.any(
      (f) => f.startsWith('Last consented location'),
    );
    if (codes is! List ||
        codes.isEmpty ||
        codes.length > 4 ||
        codes.toSet().length != codes.length ||
        codes.any(
          (c) =>
              c is! String ||
              !incidentActions.containsKey(c) ||
              (c == 'reviewLocation' && !hasLocation),
        )) {
      throw const FormatException();
    }
    return IncidentBrief(
      source: 'meta',
      overview: overview.map((i) => base.facts[i]).join(' '),
      facts: [
        for (final i in {
          ...order,
          ...List.generate(base.facts.length, (i) => i),
        })
          base.facts[i],
      ],
      unknowns: base.unknowns,
      nextSteps: [for (final code in codes) incidentActions[code]!],
      generatedAt: DateTime.now().toUtc(),
    );
  }

  static Future<void> recoverSummaries(Session session) async {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(minutes: 2));
    // An uncertain request after a crash is not automatically billed again.
    await SafetyAlert.db.updateWhere(
      session,
      columnValues: (a) => [a.briefStatus(BriefStatus.fallback)],
      where: (a) =>
          a.briefStatus.equals(BriefStatus.processing) &
          (a.briefAttemptedAt < cutoff),
    );
    final pending = await SafetyAlert.db.find(
      session,
      where: (a) =>
          a.briefStatus.equals(BriefStatus.pending) & a.resolvedAt.equals(null),
      limit: 20,
    );
    for (final alert in pending) {
      await schedule(session, alert.id!);
    }
    await IncidentAccess.db.deleteWhere(
      session,
      where: (a) => a.expiresAt < DateTime.now().toUtc(),
    );
  }

  static Future<SafetyAlert> resolveOwner(
    Session session,
    String owner,
    int alertId,
    String note,
  ) => _resolve(session, owner, alertId, note, 'Traveller', owner);

  static Future<SafetyAlert> _resolve(
    Session session,
    String owner,
    int alertId,
    String note,
    String actor,
    String by, {
    IncidentAccess? access,
  }) async {
    final clean = cleanOptionalText(
      note,
      field: 'Resolution note',
      maxLength: 200,
    );
    return session.db.transaction((tx) async {
      await lockOwner(session, owner, tx);
      if (access != null &&
          (!access.canResolve ||
              !DateTime.now().toUtc().isBefore(access.expiresAt))) {
        throw notFoundError('This action is not available.');
      }
      final alert = await SafetyAlert.db.findFirstRow(
        session,
        where: (a) => a.id.equals(alertId) & a.ownerId.equals(owner),
        transaction: tx,
      );
      if (alert == null) {
        throw notFoundError('That incident could not be found.');
      }
      if (alert.resolvedAt != null) return alert;
      await SafetyAlert.db.updateWhere(
        session,
        columnValues: (a) => [
          a.resolvedAt(DateTime.now().toUtc()),
          a.resolvedBy(by),
          a.resolutionActor(actor),
          a.resolutionNote(clean),
        ],
        where: (a) => a.id.equals(alertId) & a.ownerId.equals(owner),
        transaction: tx,
      );
      // Preserve a brief that completed concurrently; stop only unfinished work.
      await SafetyAlert.db.updateWhere(
        session,
        columnValues: (a) => [a.briefStatus(BriefStatus.fallback)],
        where: (a) =>
            a.id.equals(alertId) &
            (a.briefStatus.equals(BriefStatus.pending) |
                a.briefStatus.equals(BriefStatus.processing)),
        transaction: tx,
      );
      await AlertMessage.db.updateWhere(
        session,
        columnValues: (m) => [
          m.status(MessageStatus.skipped),
          m.statusUpdatedAt(DateTime.now().toUtc()),
        ],
        where: (m) =>
            m.alertId.equals(alertId) & m.status.equals(MessageStatus.pending),
        transaction: tx,
      );
      return (await SafetyAlert.db.findById(
        session,
        alertId,
        transaction: tx,
      ))!;
    });
  }

  static Future<IncidentAccess?> _access(Session session, String token) async {
    if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(token)) return null;
    return IncidentAccess.db.findFirstRow(
      session,
      where: (a) =>
          a.tokenHash.equals(hashToken(token)) &
          (a.expiresAt > DateTime.now().toUtc()),
    );
  }

  static Future<IncidentView?> view(Session session, String token) async {
    final access = await _access(session, token);
    if (access == null) return null;
    final alert = await SafetyAlert.db.findById(session, access.alertId);
    if (alert == null ||
        alert.ownerId != access.ownerId ||
        alert.brief == null) {
      return null;
    }
    return IncidentView(
      travellerName: alert.travellerName,
      journeyDescription: alert.tripDescription,
      deadline: alert.deadline,
      createdAt: alert.createdAt,
      reason: alert.reason,
      brief: alert.brief!,
      canResolve: access.canResolve && alert.resolvedAt == null,
      resolvedAt: alert.resolvedAt,
      resolutionActor: alert.resolutionActor,
      resolutionNote: alert.resolutionNote,
      trackingUrl: access.trackingUrl,
    );
  }

  static Future<IncidentView?> resolveFromLink(
    Session session,
    String token,
    String note,
  ) async {
    final access = await _access(session, token);
    if (access == null || !access.canResolve) {
      throw notFoundError('This action is not available.');
    }
    await _resolve(
      session,
      access.ownerId,
      access.alertId,
      note,
      'Trusted contact: ${access.contactName}',
      'contact-link:${access.id}',
      access: access,
    );
    return view(session, token);
  }
}
