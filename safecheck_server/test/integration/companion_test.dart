import 'dart:async';
import 'dart:convert';
import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/companion/companion_ai.dart';
import 'package:safecheck_server/src/companion/safety_plan_service.dart';
import 'package:safecheck_server/src/companion/incident_service.dart';
import 'package:safecheck_server/src/messaging/message_dispatcher.dart';
import 'package:test/test.dart';
import 'safecheck_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

class _Ai extends CompanionAi {
  _Ai() : super(apiKey: 'synthetic');
  bool fail = false;
  int calls = 0;
  final started = Completer<void>();
  Completer<Map<String, dynamic>>? wait;
  Map<String, dynamic>? context;
  @override
  Future<Map<String, dynamic>> preparePlan(Map<String, dynamic> value) async {
    calls++;
    context = value;
    if (fail) throw const FormatException();
    return {
      'checkInAdvice': 'Use the reviewed deadline.',
      'precautions': ['Verify transport details.'],
      'uncertainties': ['No prediction of danger.'],
    };
  }

  @override
  Future<Map<String, dynamic>> organizeIncident(
    Map<String, dynamic> value,
  ) async {
    calls++;
    if (!started.isCompleted) started.complete();
    context = value;
    if (fail) throw const FormatException();
    if (wait != null) return wait!.future;
    return {
      'overviewFacts': [0, 3],
      'factOrder': [0, 3, 1, 2],
      'actionCodes': ['callTraveller', 'checkTiming'],
    };
  }
}

void main() {
  withServerpod('Safety companion', (builder, endpoints) {
    final alice = signedIn(builder, aliceId);
    final bob = signedIn(builder, bobId);
    final original = SafetyPlanService.aiFor;
    late _Ai ai;
    setUp(() {
      ai = _Ai();
      SafetyPlanService.aiFor = (_) => ai;
    });
    tearDown(() => SafetyPlanService.aiFor = original);
    Future<JourneyRequest> request({
      int grace = 0,
      bool summary = false,
      bool resolution = false,
    }) async {
      await setUpTraveller(endpoints, alice);
      final contacts = await endpoints.contact.list(alice);
      return JourneyRequest(
        tripType: TripType.walking,
        description: 'Walk home in Pretoria',
        checkInAtUtc: DateTime.now().toUtc().add(const Duration(minutes: 20)),
        contactIds: [contacts.first.id!],
        graceMinutes: grace,
        useAiIncidentSummary: summary,
        allowContactResolution: resolution,
      );
    }

    Future<Trip> expire(Trip trip, {bool pastGrace = true}) async {
      final now = DateTime.now().toUtc();
      return Trip.db.updateRow(
        builder.build(),
        trip.copyWith(
          deadline: now.subtract(const Duration(minutes: 1)),
          alertAt: trip.graceMinutes == 0
              ? null
              : (pastGrace
                    ? now.subtract(const Duration(seconds: 1))
                    : now.add(const Duration(minutes: 2))),
        ),
      );
    }

    Future<SafetyAlert> miss(Trip trip) async {
      await expire(trip);
      await endpoints.futureCalls.tripDeadline.processDeadline(
        builder,
        trip.id!,
      );
      return (await endpoints.alert.listAlerts(alice)).single;
    }

    String token(List<AlertMessage> messages) => RegExp(
      r'/incident/([A-Za-z0-9_-]+)',
    ).firstMatch(messages.first.body)!.group(1)!;

    test('companion endpoints require login', () async {
      final r = JourneyRequest(
        tripType: TripType.walking,
        description: 'Home',
        checkInAtUtc: DateTime.now().toUtc(),
        contactIds: [1],
      );
      final denied = throwsA(isA<ServerpodUnauthenticatedException>());
      await expectLater(endpoints.trip.startJourney(builder, r), denied);
      await expectLater(endpoints.trip.extendJourney(builder, 1, 15), denied);
      await expectLater(endpoints.trip.requestHelp(builder, 1), denied);
      await expectLater(
        endpoints.alert.resolveIncident(builder, 1, ''),
        denied,
      );
      await expectLater(
        endpoints.planning.prepareSafetyPlan(
          builder,
          TripType.walking,
          'Home',
          r.checkInAtUtc,
          0,
        ),
        denied,
      );
    });
    test(
      'selected contacts, exact time and reviewed plan are persisted',
      () async {
        final r = await request(grace: 2);
        final plan = await endpoints.planning.prepareSafetyPlan(
          alice,
          r.tripType,
          r.description,
          r.checkInAtUtc,
          2,
        );
        r.safetyPlanJson = plan;
        final trip = (await endpoints.trip.startJourney(alice, r)).trip!;
        expect(trip.contacts, hasLength(1));
        expect(trip.deadline, r.checkInAtUtc);
        expect(trip.alertAt, r.checkInAtUtc.add(const Duration(minutes: 2)));
        expect(jsonDecode(trip.safetyPlanJson!)['source'], 'meta');
        expect(ai.context.toString(), isNot(contains('+2783')));
      },
    );
    test('missing provider returns an honest standard safety plan', () async {
      SafetyPlanService.aiFor = (_) => CompanionAi(apiKey: null);
      final plan = await endpoints.planning.prepareSafetyPlan(
        alice,
        TripType.walking,
        'Home',
        DateTime.now().toUtc().add(const Duration(minutes: 20)),
        0,
      );
      expect(jsonDecode(plan)['source'], 'standard');
    });
    test(
      'foreign, duplicated and missing contact selections are rejected',
      () async {
        final r = await request();
        await endpoints.contact.add(bob, 'Other contact', '0710000001', null);
        final foreign = (await endpoints.contact.list(bob)).single.id!;
        for (final ids in [
          <int>[],
          [foreign],
          [r.contactIds.first, r.contactIds.first],
        ]) {
          await expectLater(
            endpoints.trip.startJourney(alice, r.copyWith(contactIds: ids)),
            throwsSafeCheck('validation'),
          );
        }
        expect(await endpoints.trip.history(alice), isEmpty);
      },
    );
    test('grace prevents early alerts and permits check-in', () async {
      final trip = (await endpoints.trip.startJourney(
        alice,
        await request(grace: 5),
      )).trip!;
      await expire(trip, pastGrace: false);
      await endpoints.futureCalls.tripDeadline.processDeadline(
        builder,
        trip.id!,
      );
      expect(await endpoints.alert.listAlerts(alice), isEmpty);
      expect(
        (await endpoints.trip.checkIn(alice, trip.id!)).endedTrip!.status,
        TripStatus.checkedIn,
      );
    });
    test(
      'after grace one incident and selected-recipient messages are created',
      () async {
        final trip = (await endpoints.trip.startJourney(
          alice,
          await request(grace: 2),
        )).trip!;
        final alert = await miss(trip);
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          trip.id!,
        );
        expect(await endpoints.alert.listAlerts(alice), hasLength(1));
        final messages = await endpoints.alert.listMessages(alice);
        expect(messages, hasLength(1));
        expect(messages.single.status, MessageStatus.simulated);
        expect(
          messages.single.body,
          contains('Journey: Walk home in Pretoria'),
        );
        expect(alert.brief!.unknowns.join(), contains('not proof of danger'));
        expect(alert.briefStatus, BriefStatus.fallback);
        expect(ai.calls, 0);
        final view = await endpoints.incident.view(builder, token(messages));
        expect(view!.canResolve, isFalse);
        expect(view.trackingUrl, isNull);
      },
    );
    test(
      'extensions preserve ownership and prevent the old task raising an alert',
      () async {
        final trip = (await endpoints.trip.startJourney(
          alice,
          await request(grace: 2),
        )).trip!;
        await expectLater(
          endpoints.trip.extendJourney(bob, trip.id!, 15),
          throwsSafeCheck('not_found'),
        );
        final extended = (await endpoints.trip.extendJourney(
          alice,
          trip.id!,
          15,
        )).trip!;
        expect(
          extended.deadline,
          trip.deadline.add(const Duration(minutes: 15)),
        );
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          trip.id!,
        );
        expect(await endpoints.alert.listAlerts(alice), isEmpty);
        await expire(extended);
        await expectLater(
          endpoints.trip.extendJourney(alice, trip.id!, 15),
          throwsSafeCheck('conflict'),
        );
      },
    );
    test(
      'help requests are explicit, owner-only and idempotent against deadline tasks',
      () async {
        final trip = (await endpoints.trip.startJourney(
          alice,
          await request(),
        )).trip!;
        await expectLater(
          endpoints.trip.requestHelp(bob, trip.id!),
          throwsSafeCheck('not_found'),
        );
        await endpoints.trip.requestHelp(alice, trip.id!);
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          trip.id!,
        );
        final alert = (await endpoints.alert.listAlerts(alice)).single;
        expect(alert.reason, AlertReason.helpRequested);
        expect(alert.brief!.facts.first, contains('requested help'));
        expect(
          (await endpoints.trip.history(alice)).single.helpRequestedAt,
          isNotNull,
        );
      },
    );
    test(
      'AI failure leaves messages and the factual standard brief intact',
      () async {
        final trip = (await endpoints.trip.startJourney(
          alice,
          await request(summary: true),
        )).trip!;
        final alert = await miss(trip);
        expect(
          (await endpoints.alert.listMessages(alice)).single.status,
          MessageStatus.simulated,
        );
        ai.fail = true;
        await IncidentService.enrich(builder.build(), alert.id!);
        final updated = (await endpoints.alert.listAlerts(alice)).single;
        expect(updated.briefStatus, BriefStatus.fallback);
        expect(updated.brief!.source, 'standard');
        expect(await endpoints.alert.listMessages(alice), hasLength(1));
      },
    );
    test(
      'summary organization is claimed once and can finish after notification dispatch',
      () async {
        final trip = (await endpoints.trip.startJourney(
          alice,
          await request(summary: true),
        )).trip!;
        final alert = await miss(trip);
        ai.wait = Completer<Map<String, dynamic>>();
        final work = IncidentService.enrich(builder.build(), alert.id!);
        await ai.started.future.timeout(const Duration(seconds: 5));
        expect(
          (await endpoints.alert.listMessages(alice)).single.status,
          MessageStatus.simulated,
        );
        await IncidentService.enrich(builder.build(), alert.id!);
        expect(ai.calls, 1);
        ai.wait!.complete({
          'overviewFacts': [0, 3],
          'factOrder': [0, 3],
          'actionCodes': ['callTraveller'],
        });
        await work;
        final updated = (await endpoints.alert.listAlerts(alice)).single;
        expect(updated.briefStatus, BriefStatus.ready);
        expect(updated.brief!.source, 'meta');
        expect(ai.context.toString(), isNot(contains('Contact 0')));
        expect(ai.context.toString(), isNot(contains('+278300')));
      },
    );
    test(
      'reviewed plan survives missed deadline, summary and owner resolution',
      () async {
        final r = await request(summary: true, resolution: true);
        r.safetyPlanJson = await endpoints.planning.prepareSafetyPlan(
          alice,
          r.tripType,
          r.description,
          r.checkInAtUtc,
          0,
        );
        final trip = (await endpoints.trip.startJourney(alice, r)).trip!;
        final alert = await miss(trip);
        final originalFacts = List<String>.of(alert.brief!.facts);
        final originalUnknowns = List<String>.of(alert.brief!.unknowns);
        expect(
          (await endpoints.alert.listMessages(alice)).single.body,
          contains('/incident/'),
        );
        await IncidentService.enrich(builder.build(), alert.id!);
        final enriched = (await endpoints.alert.listAlerts(alice)).single;
        expect(enriched.brief!.source, 'meta');
        expect(enriched.brief!.facts.toSet(), originalFacts.toSet());
        expect(enriched.brief!.unknowns, originalUnknowns);
        expect(jsonDecode(trip.safetyPlanJson!)['source'], 'meta');
        final resolved = await endpoints.alert.resolveIncident(
          alice,
          alert.id!,
          'Fictional traveller confirmed safe.',
        );
        expect(resolved.resolvedAt, isNotNull);
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          trip.id!,
        );
        await MessageDispatcher.dispatchPending(
          builder.build(),
          alertId: alert.id!,
        );
        await IncidentService.enrich(builder.build(), alert.id!);
        expect(await endpoints.alert.listAlerts(alice), hasLength(1));
        expect(await endpoints.alert.listMessages(alice), hasLength(1));
        expect(ai.calls, 2);
      },
    );
    test(
      'stalled AI cannot block alert creation or owner resolution',
      () async {
        final trip = (await endpoints.trip.startJourney(
          alice,
          await request(summary: true),
        )).trip!;
        final alert = await miss(trip);
        ai.wait = Completer<Map<String, dynamic>>();
        final work = IncidentService.enrich(builder.build(), alert.id!);
        await ai.started.future.timeout(const Duration(seconds: 5));
        try {
          expect(await endpoints.alert.listMessages(alice), hasLength(1));
          final resolved = await endpoints.alert.resolveIncident(
            alice,
            alert.id!,
            'Confirmed safe while AI pending.',
          );
          expect(resolved.resolvedAt, isNotNull);
        } finally {
          ai.wait!.complete({
            'overviewFacts': [0],
            'factOrder': [0],
            'actionCodes': ['callTraveller'],
          });
          await work;
        }
        final updated = (await endpoints.alert.listAlerts(alice)).single;
        expect(updated.resolutionNote, 'Confirmed safe while AI pending.');
        expect(updated.resolvedAt, isNotNull);
      },
    );
    test(
      'resolution is owner-only, idempotent and skips pending messages',
      () async {
        final trip = (await endpoints.trip.startJourney(
          alice,
          await request(),
        )).trip!;
        final alert = await miss(trip);
        await expectLater(
          endpoints.alert.resolveIncident(bob, alert.id!, 'Safe'),
          throwsSafeCheck('not_found'),
        );
        final session = builder.build();
        await AlertMessage.db.updateWhere(
          session,
          columnValues: (m) => [m.status(MessageStatus.pending)],
          where: (m) => m.alertId.equals(alert.id!),
        );
        final resolved = await endpoints.alert.resolveIncident(
          alice,
          alert.id!,
          'Spoke to traveller.',
        );
        await MessageDispatcher.dispatchPending(session, alertId: alert.id);
        expect(resolved.resolvedAt, isNotNull);
        expect(
          (await endpoints.alert.listMessages(alice)).single.status,
          MessageStatus.skipped,
        );
        final again = await endpoints.alert.resolveIncident(
          alice,
          alert.id!,
          'Changed',
        );
        expect(again.resolutionNote, 'Spoke to traveller.');
      },
    );
    test('private contact links require explicit consent and expire', () async {
      final r = await request(resolution: true);
      final contact = (await endpoints.contact.list(alice)).first;
      await TrustedContact.db.updateRow(
        builder.build(),
        contact.copyWith(optInStatus: ContactOptInStatus.accepted),
      );
      final trip = (await endpoints.trip.startJourney(alice, r)).trip!;
      final alert = await miss(trip);
      final t = token(await endpoints.alert.listMessages(alice));
      expect((await endpoints.incident.view(builder, t))!.canResolve, isTrue);
      final resolved = await endpoints.incident.resolve(
        builder,
        t,
        'Confirmed safe',
      );
      expect(resolved!.resolvedAt, isNotNull);
      final access = (await IncidentAccess.db.find(builder.build())).single;
      expect(access.tokenHash, isNot(t));
      await IncidentAccess.db.updateRow(
        builder.build(),
        access.copyWith(
          expiresAt: DateTime.now().toUtc().subtract(
            const Duration(seconds: 1),
          ),
        ),
      );
      expect(await endpoints.incident.view(builder, t), isNull);
      await expectLater(
        endpoints.incident.resolve(builder, t, 'Again'),
        throwsSafeCheck('not_found'),
      );
      expect(await endpoints.incident.view(builder, 'bad-token'), isNull);
      expect((await endpoints.alert.listAlerts(alice)).single.id, alert.id);
    });
  });
}
