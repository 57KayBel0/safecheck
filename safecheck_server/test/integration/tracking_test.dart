import 'dart:convert';

import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/common/links.dart';
import 'package:safecheck_server/src/tracking/tracking_service.dart';
import 'package:test/test.dart';

import 'safecheck_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Tracking privacy and validation', (builder, endpoints) {
    final alice = signedIn(builder, aliceId);
    final bob = signedIn(builder, bobId);

    Future<Trip> start(LocationSharing mode) async {
      await setUpTraveller(endpoints, alice, contactCount: 1);
      return (await endpoints.trip.startTrip(
        alice,
        TripType.walking,
        'Tracking verification',
        30,
        mode,
      )).trip!;
    }

    LocationPoint point(
      DateTime at, {
      double lat = -26,
      double lon = 28,
      double? accuracy = 5,
    }) => LocationPoint(
      latitude: lat,
      longitude: lon,
      recordedAt: at,
      accuracyMeters: accuracy,
    );

    Future<String> token(Trip trip) async => (await TrackingLink.db.find(
      builder.build(),
      where: (t) => t.tripId.equals(trip.id!),
    )).single.token;

    test(
      'tracking URL uses the same stored token and database as its page',
      () async {
        final trip = await start(LocationSharing.live);
        final storedToken = await token(trip);
        final links = await endpoints.trip.getTrackingLinks(alice, trip.id!);
        final session = builder.build();
        expect(links.single.url, trackingUrl(session, storedToken));
        expect(Uri.parse(links.single.url).path, '/t/$storedToken');
        final view = await TrackingService.view(session, storedToken);
        expect(view!.trip.id, trip.id);
        expect(view.trip.ownerId, trip.ownerId);
      },
    );

    test(
      'location reads, uploads and links reject another owner and guests',
      () async {
        final trip = await start(LocationSharing.live);
        await endpoints.location.recordLocations(alice, trip.id!, [
          point(trip.startedAt),
        ]);
        await expectLater(
          endpoints.location.recordLocations(bob, trip.id!, [
            point(trip.startedAt),
          ]),
          throwsSafeCheck('not_found'),
        );
        await expectLater(
          endpoints.location.getTripLocations(bob, trip.id!),
          throwsSafeCheck('not_found'),
        );
        await expectLater(
          endpoints.trip.getTrackingLinks(bob, trip.id!),
          throwsSafeCheck('not_found'),
        );
        await expectLater(
          endpoints.location.recordLocations(builder, trip.id!, [
            point(trip.startedAt),
          ]),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        expect(
          await endpoints.location.getTripLocations(alice, trip.id!),
          hasLength(1),
        );
      },
    );

    test('invalid coordinates and accuracy reject the whole batch', () async {
      final trip = await start(LocationSharing.live);
      for (final invalid in [
        point(trip.startedAt, lat: -90.01),
        point(trip.startedAt, lat: 90.01),
        point(trip.startedAt, lon: -180.01),
        point(trip.startedAt, lon: 180.01),
        point(trip.startedAt, accuracy: -1),
      ]) {
        await expectLater(
          endpoints.location.recordLocations(alice, trip.id!, [
            point(trip.startedAt),
            invalid,
          ]),
          throwsSafeCheck('validation'),
        );
      }
      expect(
        await endpoints.location.getTripLocations(alice, trip.id!),
        isEmpty,
      );
      expect(
        await endpoints.location.recordLocations(alice, trip.id!, [
          point(trip.startedAt, lat: -90, lon: -180),
          point(
            trip.startedAt.add(const Duration(seconds: 1)),
            lat: 90,
            lon: 180,
          ),
        ]),
        2,
      );
    });

    test(
      'non-finite values fail JSON transport and service validation without saving any points',
      () async {
        final trip = await start(LocationSharing.live);
        for (final invalid in [
          point(trip.startedAt, lat: double.nan),
          point(trip.startedAt, lat: double.infinity),
          point(trip.startedAt, lon: double.negativeInfinity),
          point(trip.startedAt, accuracy: double.nan),
        ]) {
          expect(
            () => jsonEncode(invalid.toJson()),
            throwsA(isA<JsonUnsupportedObjectError>()),
          );
          await expectLater(
            TrackingService.record(builder.build(), aliceId, trip.id!, [
              point(trip.startedAt),
              invalid,
            ]),
            throwsSafeCheck('validation'),
          );
          expect(
            await endpoints.location.getTripLocations(alice, trip.id!),
            isEmpty,
          );
        }
      },
    );

    test(
      'timestamp window filters stale and future fixes; retries and batch duplicates are skipped',
      () async {
        final trip = await start(LocationSharing.live);
        final fix = point(trip.startedAt);
        expect(
          await endpoints.location.recordLocations(alice, trip.id!, [
            point(trip.startedAt.subtract(const Duration(minutes: 3))),
            point(trip.startedAt.add(const Duration(days: 1))),
          ]),
          0,
        );
        expect(
          await endpoints.location.recordLocations(alice, trip.id!, [fix, fix]),
          1,
        );
        expect(
          await endpoints.location.recordLocations(alice, trip.id!, [fix]),
          0,
        );
        expect(
          await endpoints.location.getTripLocations(alice, trip.id!),
          hasLength(1),
        );
      },
    );

    test(
      'off creates no contact links and rejects location collection',
      () async {
        final trip = await start(LocationSharing.off);
        expect(await endpoints.trip.getTrackingLinks(alice, trip.id!), isEmpty);
        expect(
          await TrackingLink.db.find(
            builder.build(),
            where: (t) => t.tripId.equals(trip.id!),
          ),
          isEmpty,
        );
        await expectLater(
          endpoints.location.recordLocations(alice, trip.id!, [
            point(trip.startedAt),
          ]),
          throwsSafeCheck('conflict'),
        );
      },
    );

    for (final mode in [LocationSharing.live, LocationSharing.afterAlert]) {
      test('${mode.name} visibility and controlled 48-hour expiry', () async {
        final trip = await start(mode);
        final secret = await token(trip);
        await endpoints.location.recordLocations(alice, trip.id!, [
          point(trip.startedAt),
        ]);
        final active = (await TrackingService.view(
          builder.build(),
          secret,
          now: trip.startedAt,
        ))!;
        expect(active.showLocation, mode == LocationSharing.live);
        expect(active.points, hasLength(mode == LocationSharing.live ? 1 : 0));
        await expireTrip(builder, trip.id!);
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          trip.id!,
        );
        final missed = (await Trip.db.findById(builder.build(), trip.id!))!;
        final boundary = missed.endedAt!.add(TrackingService.alertVisibility);
        for (final at in [
          boundary.subtract(const Duration(microseconds: 1)),
          boundary,
        ]) {
          final view = (await TrackingService.view(
            builder.build(),
            secret,
            now: at,
          ))!;
          expect(view.showLocation, isTrue);
          expect(view.points, hasLength(1));
        }
        final expired = (await TrackingService.view(
          builder.build(),
          secret,
          now: boundary.add(const Duration(microseconds: 1)),
        ))!;
        expect(expired.showLocation, isFalse);
        expect(expired.points, isEmpty);
        expect(expired.message, contains('expired'));
      });

      test(
        '${mode.name} hides stored location after successful check-in',
        () async {
          final trip = await start(mode);
          final secret = await token(trip);
          await endpoints.location.recordLocations(alice, trip.id!, [
            point(trip.startedAt),
          ]);
          await endpoints.trip.checkIn(alice, trip.id!);
          final view = (await TrackingService.view(builder.build(), secret))!;
          expect(view.showLocation, isFalse);
          expect(view.points, isEmpty);
          expect(view.message, contains('checked in safely'));
        },
      );
    }

    test('short and unknown tracking tokens reveal nothing', () async {
      await start(LocationSharing.live);
      for (final invalid in ['', 'short', 'x' * 64]) {
        expect(await TrackingService.view(builder.build(), invalid), isNull);
      }
    });
  });
}
