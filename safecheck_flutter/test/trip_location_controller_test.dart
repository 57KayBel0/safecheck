import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_flutter/location/trip_location_controller.dart';

class FakeLocation implements TripLocationService {
  bool enabled = true;
  LocationAccess access = LocationAccess.granted;
  LocationAccess requested = LocationAccess.granted;
  int requests = 0;
  int positions = 0;
  Future<LocationSample> Function()? acquire;
  @override
  Future<bool> servicesEnabled() async => enabled;
  @override
  Future<LocationAccess> permission() async => access;
  @override
  Future<LocationAccess> requestPermission() async {
    requests++;
    return access = requested;
  }

  @override
  Future<LocationSample> position() async {
    positions++;
    return acquire == null
        ? LocationSample(0, 0, 1, DateTime.utc(2026))
        : await acquire!();
  }
}

Future<void> finish() async => Future<void>.delayed(Duration.zero);

void main() {
  late FakeLocation service;
  late TripLocationController controller;
  late List<TrackingState> states;
  late List<int> uploads;
  bool failUpload = false;
  setUp(() {
    service = FakeLocation();
    states = [];
    uploads = [];
    failUpload = false;
    controller = TripLocationController(
      service: service,
      onChanged: () => states.add(controller.state),
      timeout: const Duration(milliseconds: 10),
      upload: (id, point) async {
        uploads.add(id);
        if (failUpload) throw StateError('fake upload failure');
        return 1;
      },
    );
  });
  tearDown(() => controller.dispose());

  test(
    'granted permission acquires and confirms upload without prompting',
    () async {
      controller.attach(7, enabled: true);
      await finish();
      expect(service.requests, 0);
      expect(uploads, [7]);
      expect(
        states,
        containsAllInOrder([
          TrackingState.permissionGranted,
          TrackingState.acquiring,
          TrackingState.uploading,
          TrackingState.uploaded,
        ]),
      );
      expect(controller.busy, false);
    },
  );
  test('permission request waits for explicit enable action', () async {
    service.access = LocationAccess.denied;
    controller.attach(7, enabled: true);
    await finish();
    expect(controller.state, TrackingState.needsPermission);
    expect(service.requests, 0);
    await controller.enable();
    expect(service.requests, 1);
    expect(controller.state, TrackingState.uploaded);
  });
  test('denial clears loading without acquiring or uploading', () async {
    service.access = service.requested = LocationAccess.denied;
    controller.attach(7, enabled: true);
    await finish();
    await controller.enable();
    expect(controller.state, TrackingState.denied);
    expect(controller.busy, false);
    expect(service.positions, 0);
    expect(uploads, isEmpty);
  });
  test('blocked permission does not repeatedly request permission', () async {
    service.access = LocationAccess.blocked;
    controller.attach(7, enabled: true);
    await finish();
    await controller.enable();
    expect(controller.state, TrackingState.blocked);
    expect(service.requests, 0);
    expect(uploads, isEmpty);
    expect(controller.busy, false);
  });
  test('disabled services do not acquire or upload', () async {
    service.enabled = false;
    controller.attach(7, enabled: true);
    await finish();
    expect(controller.state, TrackingState.servicesDisabled);
    expect(controller.busy, false);
    expect(service.positions, 0);
    expect(uploads, isEmpty);
  });
  test(
    'pending GPS acquisition times out and retry uses the same trip',
    () async {
      service.acquire = () => Completer<LocationSample>().future;
      controller.attach(7, enabled: true);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(controller.state, TrackingState.gpsTimeout);
      expect(controller.busy, false);
      expect(uploads, isEmpty);
      service.acquire = null;
      await controller.enable();
      expect(uploads, [7]);
      expect(controller.state, TrackingState.uploaded);
    },
  );
  test(
    'upload failure does not claim tracking; explicit retry reuses trip',
    () async {
      failUpload = true;
      controller.attach(7, enabled: true);
      await finish();
      expect(controller.state, TrackingState.uploadFailed);
      expect(controller.busy, false);
      expect(states, isNot(contains(TrackingState.uploaded)));
      failUpload = false;
      await controller.enable();
      expect(uploads, [7, 7]);
      expect(controller.state, TrackingState.uploaded);
    },
  );
  test('sharing off never requests location even on retry', () async {
    controller.attach(7, enabled: false);
    await controller.enable();
    expect(controller.state, TrackingState.off);
    expect(service.requests, 0);
    expect(service.positions, 0);
    expect(uploads, isEmpty);
  });
  test(
    'continue without location pauses updates without modifying trip',
    () async {
      service.access = LocationAccess.denied;
      controller.attach(7, enabled: true);
      await finish();
      controller.continueWithoutLocation();
      await controller.update();
      controller.attach(7, enabled: true);
      await controller.update();
      expect(controller.state, TrackingState.paused);
      expect(uploads, isEmpty);
      await controller.enable();
      expect(uploads, [7]);
    },
  );
  test('late GPS completion after check-in cannot upload', () async {
    final fix = Completer<LocationSample>();
    service.acquire = () => fix.future;
    controller.attach(7, enabled: true);
    await finish();
    controller.attach(null, enabled: false);
    fix.complete(LocationSample(0, 0, 1, DateTime.utc(2026)));
    await finish();
    expect(uploads, isEmpty);
    expect(controller.state, TrackingState.off);
  });

  test('upload is not claimed while confirmation is pending', () async {
    final confirmation = Completer<int>();
    controller.dispose();
    controller = TripLocationController(
      service: service,
      onChanged: () {},
      upload: (id, point) => confirmation.future,
    );
    controller.attach(7, enabled: true);
    await finish();
    expect(controller.permissionGranted, true);
    expect(controller.state, TrackingState.uploading);
    confirmation.complete(0);
    await finish();
    expect(controller.state, TrackingState.uploadFailed);
    expect(controller.busy, false);
  });

  test('upload timeout releases loading state', () async {
    controller.dispose();
    controller = TripLocationController(
      service: service,
      onChanged: () {},
      timeout: const Duration(milliseconds: 10),
      upload: (id, point) => Completer<int>().future,
    );
    controller.attach(7, enabled: true);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(controller.state, TrackingState.uploadFailed);
    expect(controller.busy, false);
  });
}
