import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'safecheck_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

/// These tests commit real transactions on separate connections so that the
/// requests actually race in Postgres. They clean up after themselves.
void main() {
  withServerpod(
    'Given concurrent requests',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      const userId = '33333333-3333-4333-8333-333333333333';
      final user = signedIn(sessionBuilder, userId);

      Future<void> cleanUp() async {
        final session = sessionBuilder.build();
        await AlertMessage.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(userId),
        );
        await SafetyAlert.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(userId),
        );
        await Trip.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(userId),
        );
        await TrustedContact.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(userId),
        );
        await UserProfile.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(userId),
        );
      }

      setUp(cleanUp);
      tearDown(cleanUp);

      Future<List<Object?>> settle(Iterable<Future<Object?>> futures) {
        return Future.wait(
          futures.map((f) => f.then<Object?>((v) => v, onError: (e) => e)),
        );
      }

      test('when many deadline tasks and a check-in race then one alert '
          'is created', () async {
        await setUpTraveller(endpoints, user, contactCount: 3);
        final trip = (await endpoints.trip.startTrip(
          user,
          TripType.walking,
          'Walk home from the station',
          30,
        )).trip!;
        await expireTrip(sessionBuilder, trip.id!);

        await settle([
          for (var i = 0; i < 8; i++)
            endpoints.futureCalls.tripDeadline.processDeadline(
              sessionBuilder,
              trip.id!,
            ),
          endpoints.futureCalls.tripDeadline.sweepOverdue(sessionBuilder),
          endpoints.trip.checkIn(user, trip.id!),
        ]);

        expect(await endpoints.alert.listAlerts(user), hasLength(1));
        expect(await endpoints.alert.listMessages(user), hasLength(3));
        expect(
          (await endpoints.trip.history(user)).single.status,
          TripStatus.missed,
        );
      });

      test('when check-in races deadline tasks before the deadline then the '
          'check-in wins and no alert is created', () async {
        await setUpTraveller(endpoints, user);
        final trip = (await endpoints.trip.startTrip(
          user,
          TripType.driving,
          'Drive to Durban',
          30,
        )).trip!;

        final results = await settle([
          endpoints.trip.checkIn(user, trip.id!),
          endpoints.trip.checkIn(user, trip.id!),
          for (var i = 0; i < 5; i++)
            endpoints.futureCalls.tripDeadline.processDeadline(
              sessionBuilder,
              trip.id!,
            ),
        ]);

        expect(results.whereType<Exception>(), isEmpty);
        expect(await endpoints.alert.listAlerts(user), isEmpty);
        expect(
          (await endpoints.trip.history(user)).single.status,
          TripStatus.checkedIn,
        );
      });

      test(
        'when several trips start at once then only one is active',
        () async {
          await setUpTraveller(endpoints, user);
          final results = await settle([
            for (var i = 0; i < 6; i++)
              endpoints.trip.startTrip(user, TripType.other, 'Trip $i', 30),
          ]);

          expect(results.whereType<TripSnapshot>(), hasLength(1));
          expect(
            results.whereType<SafeCheckException>().map((e) => e.code),
            everyElement('conflict'),
          );
          expect(await endpoints.trip.history(user), hasLength(1));
        },
      );

      test(
        'when many contacts are added at once then at most five exist',
        () async {
          await endpoints.profile.saveProfile(user, 'Lerato', '0820000099');
          await settle([
            for (var i = 0; i < 9; i++)
              endpoints.contact.add(user, 'C$i', '07100000${10 + i}', null),
          ]);
          expect(await endpoints.contact.list(user), hasLength(5));
        },
      );
    },
  );
}
