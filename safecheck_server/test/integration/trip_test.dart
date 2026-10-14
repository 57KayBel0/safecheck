import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'safecheck_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the trip endpoint', (sessionBuilder, endpoints) {
    final alice = signedIn(sessionBuilder, aliceId);
    final bob = signedIn(sessionBuilder, bobId);

    Future<Trip> startTrip({int minutes = 30}) async {
      final snapshot = await endpoints.trip.startTrip(
        alice,
        TripType.minibusTaxi,
        'Taxi from Bree Street rank to Soweto',
        minutes,
      );
      return snapshot.trip!;
    }

    group('when starting a trip', () {
      test('without a profile or contacts then it is rejected', () async {
        await expectLater(
          endpoints.trip.startTrip(alice, TripType.walking, 'Walk', 30),
          throwsSafeCheck('validation'),
        );
        await endpoints.profile.saveProfile(alice, 'Thandi', '0820000001');
        await expectLater(
          endpoints.trip.startTrip(alice, TripType.walking, 'Walk', 30),
          throwsSafeCheck('validation'),
        );
      });

      test(
        'with an invalid duration or description then it is rejected',
        () async {
          await setUpTraveller(endpoints, alice);
          for (final minutes in [0, -5, 24 * 60 + 1]) {
            await expectLater(
              endpoints.trip.startTrip(
                alice,
                TripType.walking,
                'Walk',
                minutes,
              ),
              throwsSafeCheck('validation'),
            );
          }
          await expectLater(
            endpoints.trip.startTrip(alice, TripType.walking, '   ', 30),
            throwsSafeCheck('validation'),
          );
          await expectLater(
            endpoints.trip.startTrip(alice, TripType.walking, 'x' * 201, 30),
            throwsSafeCheck('validation'),
          );
        },
      );

      test(
        'then the server sets the deadline and snapshots contacts',
        () async {
          await setUpTraveller(endpoints, alice);
          final trip = await startTrip(minutes: 45);

          expect(trip.status, TripStatus.active);
          expect(trip.deadline.difference(trip.startedAt).inMinutes, 45);
          expect(trip.contacts.map((c) => c.name), ['Contact 0', 'Contact 1']);

          final active = await endpoints.trip.getActiveTrip(alice);
          expect(active.trip?.id, trip.id);
          expect(
            active.serverTime
                .difference(DateTime.now().toUtc())
                .inSeconds
                .abs(),
            lessThan(5),
          );
        },
      );

      test('while another is active then it is rejected', () async {
        await setUpTraveller(endpoints, alice);
        await startTrip();
        await expectLater(startTrip(), throwsSafeCheck('conflict'));
        expect(await endpoints.trip.history(alice), hasLength(1));
      });
    });

    group('when checking in', () {
      test('as the owner then the trip ends safely', () async {
        await setUpTraveller(endpoints, alice);
        final trip = await startTrip();

        final result = await endpoints.trip.checkIn(alice, trip.id!);
        expect(result.trip, isNull);
        expect(result.endedTrip?.status, TripStatus.checkedIn);
        expect(result.endedTrip?.endedAt, isNotNull);
        expect((await endpoints.trip.getActiveTrip(alice)).trip, isNull);

        // Tapping again is harmless.
        final again = await endpoints.trip.checkIn(alice, trip.id!);
        expect(again.endedTrip?.status, TripStatus.checkedIn);

        // A deadline call that fires late does nothing.
        await endpoints.futureCalls.tripDeadline.processDeadline(
          sessionBuilder,
          trip.id!,
        );
        expect(await endpoints.alert.listAlerts(alice), isEmpty);

        // A new trip can start after checking in.
        expect((await startTrip()).status, TripStatus.active);
      });

      test('as another user then the trip is not found or changed', () async {
        await setUpTraveller(endpoints, alice);
        final trip = await startTrip();

        await expectLater(
          endpoints.trip.checkIn(bob, trip.id!),
          throwsSafeCheck('not_found'),
        );
        expect((await endpoints.trip.getActiveTrip(bob)).trip, isNull);
        expect(await endpoints.trip.history(bob), isEmpty);
        expect(
          (await endpoints.trip.getActiveTrip(alice)).trip?.status,
          TripStatus.active,
        );
      });

      test('after the deadline then it fails and the alert exists', () async {
        await setUpTraveller(endpoints, alice);
        final trip = await startTrip();
        await expireTrip(sessionBuilder, trip.id!);

        await expectLater(
          endpoints.trip.checkIn(alice, trip.id!),
          throwsSafeCheck('conflict'),
        );
        expect(await endpoints.alert.listAlerts(alice), hasLength(1));
        final history = await endpoints.trip.history(alice);
        expect(history.single.status, TripStatus.missed);
      });
    });

    group('when the deadline passes without a check-in', () {
      test(
        'then the future call creates one alert and demo SMS per contact',
        () async {
          await setUpTraveller(endpoints, alice);
          final trip = await startTrip();
          await expireTrip(sessionBuilder, trip.id!);

          await endpoints.futureCalls.tripDeadline.processDeadline(
            sessionBuilder,
            trip.id!,
          );

          final alerts = await endpoints.alert.listAlerts(alice);
          expect(alerts, hasLength(1));
          expect(alerts.single.tripId, trip.id);
          expect(alerts.single.travellerName, 'Thandi');
          expect(alerts.single.travellerPhone, '+27820000001');

          final messages = await endpoints.alert.listMessages(alice);
          expect(messages, hasLength(2));
          expect(
            messages.map((m) => m.recipientPhone).toSet(),
            {'+27830000010', '+27830000011'},
          );
          for (final message in messages) {
            expect(message.alertId, alerts.single.id);
            expect(message.tripId, trip.id);
            expect(message.channel, MessageChannel.sms);
            expect(message.status, MessageStatus.simulated);
            expect(message.body, 'SafeCheck: Thandi missed check-in.');
          }

          expect(
            (await endpoints.trip.history(alice)).single.status,
            TripStatus.missed,
          );
          expect(await endpoints.alert.listAlerts(bob), isEmpty);
          expect(await endpoints.alert.listMessages(bob), isEmpty);
        },
      );

      test('then repeated task execution creates no duplicates', () async {
        await setUpTraveller(endpoints, alice);
        final trip = await startTrip();
        await expireTrip(sessionBuilder, trip.id!);

        for (var i = 0; i < 3; i++) {
          await endpoints.futureCalls.tripDeadline.processDeadline(
            sessionBuilder,
            trip.id!,
          );
          await endpoints.futureCalls.tripDeadline.sweepOverdue(
            sessionBuilder,
          );
        }
        await endpoints.trip.getActiveTrip(alice);
        await endpoints.trip.history(alice);

        expect(await endpoints.alert.listAlerts(alice), hasLength(1));
        expect(await endpoints.alert.listMessages(alice), hasLength(2));
      });

      test('then the sweep alone also raises the alert', () async {
        await setUpTraveller(endpoints, alice);
        final trip = await startTrip();
        await expireTrip(sessionBuilder, trip.id!);

        await endpoints.futureCalls.tripDeadline.sweepOverdue(sessionBuilder);
        expect(await endpoints.alert.listAlerts(alice), hasLength(1));
      });

      test(
        'then contact edits after the start do not change the alert',
        () async {
          await setUpTraveller(endpoints, alice, contactCount: 1);
          final trip = await startTrip();

          final contact = (await endpoints.contact.list(alice)).single;
          await endpoints.contact.update(
            alice,
            contact.id!,
            'Renamed',
            '0849999999',
            null,
          );
          await endpoints.contact.add(alice, 'Added later', '0848888888', null);
          await expireTrip(sessionBuilder, trip.id!);
          await endpoints.futureCalls.tripDeadline.processDeadline(
            sessionBuilder,
            trip.id!,
          );

          final message = (await endpoints.alert.listMessages(alice)).single;
          expect(message.recipientName, 'Contact 0');
          expect(message.recipientPhone, '+27830000010');
          final alert = (await endpoints.alert.listAlerts(alice)).single;
          expect(alert.contacts.single.name, 'Contact 0');
        },
      );

      test('then a new trip can be started', () async {
        await setUpTraveller(endpoints, alice);
        final trip = await startTrip();
        await expireTrip(sessionBuilder, trip.id!);

        // No explicit processing: starting a trip closes the overdue one.
        final next = await startTrip();
        expect(next.id, isNot(trip.id));
        expect(await endpoints.alert.listAlerts(alice), hasLength(1));
      });
    });
  });
}
