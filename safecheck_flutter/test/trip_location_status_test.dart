import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/location/trip_location_controller.dart';
import 'package:safecheck_flutter/widgets/trip_location_status.dart';
import 'trip_location_controller_test.dart' show FakeLocation;

void main() {
  testWidgets('denial explains settings and leaves check-in usable', (
    tester,
  ) async {
    final service = FakeLocation()
      ..access = LocationAccess.denied
      ..requested = LocationAccess.denied;
    late TripLocationController controller;
    StateSetter? refresh;
    var checkedIn = false;
    controller = TripLocationController(
      service: service,
      upload: (_, _) async => 1,
      onChanged: () => refresh?.call(() {}),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              refresh = setState;
              return ListView(
                children: [
                  TripLocationStatus(
                    controller: controller,
                    sharing: LocationSharing.afterAlert,
                  ),
                  TextButton(
                    onPressed: () => checkedIn = true,
                    child: const Text("I'm safe"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    controller.attach(7, enabled: true);
    await tester.pump();
    expect(find.text('Enable location'), findsOneWidget);
    expect(service.requests, 0);
    expect(find.textContaining('only after a missed check-in'), findsOneWidget);
    await tester.tap(find.text('Enable location'));
    await tester.pump();
    expect(find.textContaining('permission was not granted'), findsOneWidget);
    expect(find.textContaining('Chrome/Edge:'), findsOneWidget);
    await tester.ensureVisible(find.text("I'm safe"));
    await tester.tap(find.text("I'm safe"));
    expect(checkedIn, true);
    await tester.ensureVisible(find.text('Continue without location'));
    await tester.tap(find.text('Continue without location'));
    await tester.pump();
    expect(find.textContaining('sharing setting is unchanged'), findsOneWidget);
  });

  testWidgets('granted permission and pending GPS do not claim an upload', (
    tester,
  ) async {
    final fix = Completer<LocationSample>();
    final confirmation = Completer<int>();
    var uploads = 0;
    int? uploadedTripId;
    LocationSample? uploadedSample;
    final service = FakeLocation()..acquire = () => fix.future;
    late TripLocationController controller;
    StateSetter? refresh;
    controller = TripLocationController(
      service: service,
      upload: (tripId, sample) {
        uploads++;
        // Do not call flutter_test.expect from this controller continuation:
        // pump may have an active TestAsyncUtils guard in another zone. An
        // assertion error here is caught as an application upload failure.
        uploadedTripId = tripId;
        uploadedSample = sample;
        return confirmation.future;
      },
      onChanged: () => refresh?.call(() {}),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (_, setState) {
              refresh = setState;
              return TripLocationStatus(
                controller: controller,
                sharing: LocationSharing.live,
              );
            },
          ),
        ),
      ),
    );
    controller.attach(7, enabled: true);
    await tester.pump();
    expect(controller.state, TrackingState.acquiring);
    expect(uploads, 0);
    expect(find.text('Location permission granted.'), findsOneWidget);
    expect(find.text('Acquiring position…'), findsOneWidget);
    expect(find.textContaining('Location uploaded.'), findsNothing);
    expect(service.requests, 0);
    final beforeGpsCompletion = tester.binding.clock.now();
    fix.complete(LocationSample(0, 0, 1, DateTime.utc(2026)));
    // pump flushes the GPS continuation after its frame. Check the controller
    // transition, then render the frame scheduled by onChanged.
    await tester.pump();
    expect(controller.state, TrackingState.uploading);
    expect(uploads, 1);
    expect(uploadedTripId, 7);
    expect(uploadedSample!.time, DateTime.utc(2026));
    expect(confirmation.isCompleted, false);
    expect(controller.busy, true);
    await tester.pump();
    // These pumps process microtasks and frames without advancing the fake
    // clock; the controller's unchanged 20-second upload timeout cannot fire.
    expect(tester.binding.clock.now(), beforeGpsCompletion);
    expect(controller.state, TrackingState.uploading);
    expect(find.text('Uploading location…'), findsOneWidget);
    expect(find.textContaining('Location uploaded.'), findsNothing);

    confirmation.complete(1);
    await tester.pump();
    expect(controller.state, TrackingState.uploaded);
    expect(controller.busy, false);
    // Render the successful confirmation notification rather than assuming
    // the frame preceding microtask completion already contains that state.
    await tester.pump();
    expect(find.textContaining('Location uploaded.'), findsOneWidget);
  });
}
