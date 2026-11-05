import 'dart:convert';

import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/planning/meta_trip_planner.dart';
import 'package:safecheck_server/src/planning/planning_service.dart';
import 'package:test/test.dart';

import 'safecheck_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

class _Transport implements PlannerTransport {
  int calls = 0;
  int status = 200;
  Map<String, dynamic>? lastRequest;
  Map<String, dynamic> draft = {};

  @override
  Future<PlannerHttpResponse> post(
    Uri endpoint, {
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    calls++;
    lastRequest = jsonDecode(body) as Map<String, dynamic>;
    return PlannerHttpResponse(
      status,
      status == 200
          ? jsonEncode({
              'choices': [
                {
                  'finish_reason': 'stop',
                  'message': {
                    'role': 'assistant',
                    'content': jsonEncode(draft),
                  },
                },
              ],
            })
          : 'Private provider response must not escape',
    );
  }
}

void main() {
  withServerpod('Authenticated AI planning', (builder, endpoints) {
    final alice = signedIn(builder, aliceId);
    final bob = signedIn(builder, bobId);
    late _Transport transport;
    late DateTime now;
    final originalPlanner = PlanningService.plannerFor;
    final originalClock = PlanningService.clock;

    setUp(() {
      now = DateTime.now().toUtc();
      transport = _Transport()
        ..draft = {
          'tripType': 'minibusTaxi',
          'description': 'Taxi from Pretoria CBD to Mamelodi',
          'checkInAtUtc': now
              .add(const Duration(minutes: 45))
              .toIso8601String(),
          'questions': <String>[],
        };
      PlanningService.clock = () => now;
      PlanningService.plannerFor = (_) => MetaTripPlanner(
        apiKey: 'test-key-only',
        transport: transport,
        clock: () => now,
      );
    });

    tearDown(() {
      PlanningService.plannerFor = originalPlanner;
      PlanningService.clock = originalClock;
    });

    test(
      'anonymous requests cannot check availability, plan or confirm',
      () async {
        final unauthenticated = throwsA(
          isA<ServerpodUnauthenticatedException>(),
        );
        await expectLater(
          endpoints.planning.isAvailable(builder),
          unauthenticated,
        );
        await expectLater(
          endpoints.planning.propose(builder, 'A trip', []),
          unauthenticated,
        );
        await expectLater(
          endpoints.trip.startPlannedTrip(
            builder,
            TripType.walking,
            'Home',
            now.add(const Duration(minutes: 30)),
            LocationSharing.off,
          ),
          unauthenticated,
        );
        expect(transport.calls, 0);
      },
    );

    test(
      'planning returns a proposal without starting, tracking or alerting',
      () async {
        await setUpTraveller(endpoints, alice);
        expect(await endpoints.planning.isAvailable(alice), isTrue);
        final response = await endpoints.planning.propose(
          alice,
          'Taxi to Mamelodi in 45 minutes',
          [],
        );
        expect(jsonDecode(response)['tripType'], 'minibusTaxi');
        expect(await endpoints.trip.history(alice), isEmpty);
        expect(await endpoints.alert.listAlerts(alice), isEmpty);
        expect(await endpoints.alert.listMessages(alice), isEmpty);
        expect(await TrackingLink.db.count(builder.build()), 0);
        final sent = jsonEncode(transport.lastRequest);
        expect(sent, isNot(contains('+27830000010')));
        expect(sent, isNot(contains('Contact 0')));
      },
    );

    test('clarifications use bounded alternating context', () async {
      transport.draft = {
        'tripType': 'walking',
        'description': 'Walk home',
        'checkInAtUtc': null,
        'questions': ['What time will you check in?'],
      };
      final first = await endpoints.planning.propose(alice, 'Walking home', []);
      expect(jsonDecode(first)['questions'], hasLength(1));
      await endpoints.planning.propose(alice, 'In 20 minutes', [
        'Walking home',
        first,
      ]);
      final messages = transport.lastRequest!['messages'] as List;
      expect(messages.map((m) => m['role']), [
        'developer',
        'user',
        'assistant',
        'user',
      ]);
      await expectLater(
        endpoints.planning.propose(alice, 'Now', ['Odd history']),
        throwsSafeCheck('planning_invalidInput'),
      );
      expect(transport.calls, 2);
    });

    test(
      'missing credentials keep manual setup available without using quota',
      () async {
        PlanningService.plannerFor = (_) =>
            MetaTripPlanner(apiKey: null, transport: transport);
        expect(await endpoints.planning.isAvailable(alice), isFalse);
        await expectLater(
          endpoints.planning.propose(alice, 'A trip', []),
          throwsSafeCheck('planning_notConfigured'),
        );
        expect(await PlanningQuota.db.count(builder.build()), 0);
        expect(transport.calls, 0);
        await setUpTraveller(endpoints, alice);
        expect(
          (await endpoints.trip.startTrip(
            alice,
            TripType.walking,
            'Home',
            15,
          )).trip,
          isNotNull,
        );
      },
    );

    test(
      'provider failures consume one request and return a safe error',
      () async {
        transport.status = 500;
        await expectLater(
          endpoints.planning.propose(alice, 'A trip', []),
          throwsSafeCheck('planning_unavailable'),
        );
        expect(transport.calls, 1);
        final quota = (await PlanningQuota.db.find(builder.build())).single;
        expect(quota.dayCount, 1);
        expect(quota.windowCount, 1);
      },
    );

    test(
      'five requests per window are durable and isolated by owner',
      () async {
        for (var i = 0; i < PlanningService.windowLimit; i++) {
          await endpoints.planning.propose(alice, 'A trip', []);
        }
        await expectLater(
          endpoints.planning.propose(alice, 'A trip', []),
          throwsSafeCheck('planning_rateLimited'),
        );
        expect(transport.calls, 5);
        await endpoints.planning.propose(bob, 'A trip', []);
        expect(transport.calls, 6);
        now = now.add(const Duration(minutes: 10));
        await endpoints.planning.propose(alice, 'A trip', []);
        final quota = await PlanningQuota.db.findFirstRow(
          builder.build(),
          where: (q) => q.ownerId.equals(aliceId),
        );
        expect(quota!.windowCount, 1);
        expect(quota.dayCount, 6);
      },
    );

    test(
      'daily cap survives new windows and resets on the next UTC day',
      () async {
        now = DateTime.utc(2026, 11, 2, 10);
        for (var i = 0; i < PlanningService.dayLimit; i++) {
          if (i > 0 && i % PlanningService.windowLimit == 0) {
            now = now.add(const Duration(minutes: 10));
          }
          await PlanningService.reserveRequest(builder.build(), aliceId);
        }
        now = now.add(const Duration(minutes: 10));
        await expectLater(
          PlanningService.reserveRequest(builder.build(), aliceId),
          throwsSafeCheck('planning_rateLimited'),
        );
        now = DateTime.utc(2026, 11, 3, 10);
        await PlanningService.reserveRequest(builder.build(), aliceId);
        final quota = (await PlanningQuota.db.find(builder.build())).single;
        expect(quota.dayCount, 1);
        expect(quota.windowCount, 1);
      },
    );

    test(
      'confirmation preserves the approved exact time and snapshots contacts',
      () async {
        await setUpTraveller(endpoints, alice);
        final approved = DateTime.now().toUtc().add(
          const Duration(minutes: 20, seconds: 42),
        );
        final snapshot = await endpoints.trip.startPlannedTrip(
          alice,
          TripType.minibusTaxi,
          'Taxi home',
          approved,
          LocationSharing.off,
        );
        expect(snapshot.trip!.deadline, approved);
        expect(snapshot.trip!.locationSharing, LocationSharing.off);
        expect(snapshot.trip!.contacts, hasLength(2));
        expect(await endpoints.trip.history(bob), isEmpty);
        await expectLater(
          endpoints.trip.startPlannedTrip(
            alice,
            TripType.walking,
            'Another trip',
            approved,
            LocationSharing.off,
          ),
          throwsSafeCheck('conflict'),
        );
        await endpoints.trip.checkIn(alice, snapshot.trip!.id!);
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          snapshot.trip!.id!,
        );
        expect(await endpoints.alert.listAlerts(alice), isEmpty);
      },
    );

    test(
      'expired, too-close and more-than-24-hour confirmations create no trip',
      () async {
        await setUpTraveller(endpoints, alice);
        final current = DateTime.now().toUtc();
        for (final deadline in [
          current.subtract(const Duration(minutes: 1)),
          current.add(const Duration(seconds: 30)),
          current.add(const Duration(hours: 25)),
        ]) {
          await expectLater(
            endpoints.trip.startPlannedTrip(
              alice,
              TripType.walking,
              'Home',
              deadline,
              LocationSharing.off,
            ),
            throwsSafeCheck('validation'),
          );
        }
        expect(await endpoints.trip.history(alice), isEmpty);
        expect(await endpoints.alert.listAlerts(alice), isEmpty);
      },
    );
  });

  withServerpod(
    'Concurrent AI quota reservations',
    rollbackDatabase: RollbackDatabase.disabled,
    (builder, endpoints) {
      const owner = '44444444-4444-4444-8444-444444444444';
      Future<void> cleanup() async {
        await PlanningQuota.db.deleteWhere(
          builder.build(),
          where: (q) => q.ownerId.equals(owner),
        );
      }

      setUp(cleanup);
      tearDown(cleanup);
      test(
        'racing requests reserve at most the per-user window limit',
        () async {
          final results = await Future.wait([
            for (var i = 0; i < 12; i++)
              PlanningService.reserveRequest(
                builder.build(),
                owner,
              ).then<Object?>((_) => true, onError: (Object e) => e),
          ]);
          expect(
            results.where((r) => r == true),
            hasLength(PlanningService.windowLimit),
          );
          expect(
            results.whereType<SafeCheckException>().map((e) => e.code),
            everyElement('planning_rateLimited'),
          );
          final quota = (await PlanningQuota.db.find(
            builder.build(),
            where: (q) => q.ownerId.equals(owner),
          )).single;
          expect(quota.windowCount, PlanningService.windowLimit);
        },
      );
    },
  );
}
