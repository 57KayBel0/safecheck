import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/client.dart' as app;
import 'package:safecheck_flutter/screens/trip_screen.dart';

/// Uses the real generated endpoint references with an in-memory RPC boundary.
/// Does not verify provider access, database behavior or SMS delivery.
class _Client extends Client {
  _Client() : super('http://localhost/');

  bool available = true;
  bool loseStartReply = false;
  Trip? activeTrip;
  int starts = 0;
  final now = DateTime.now().toUtc();
  final calls = <String>[];
  Map<String, dynamic>? startArguments;

  void reset() {
    available = true;
    loseStartReply = false;
    activeTrip = null;
    starts = 0;
    calls.clear();
    startArguments = null;
  }

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    final call = '$endpoint.$method';
    calls.add(call);
    final Object result;
    switch (call) {
      case 'planning.isAvailable':
        result = available;
      case 'contact.list':
        result = [
          TrustedContact(
            ownerId: 'owner',
            name: 'Naledi',
            phoneNumber: '+27820000000',
            createdAt: now,
            updatedAt: now,
          ),
        ];
      case 'trip.getActiveTrip':
        result = TripSnapshot(trip: activeTrip, serverTime: now);
      case 'planning.propose':
        result = jsonEncode({
          'tripType': 'minibusTaxi',
          'description': 'Taxi to Mamelodi',
          'checkInAtUtc': now
              .add(const Duration(minutes: 45))
              .toIso8601String(),
          'questions': <String>[],
        });
      case 'trip.startPlannedTrip':
        starts++;
        startArguments = args;
        activeTrip = Trip(
          id: 42,
          ownerId: 'owner',
          tripType: args['tripType'] as TripType,
          description: args['description'] as String,
          durationMinutes: 45,
          startedAt: now,
          deadline: args['checkInAtUtc'] as DateTime,
          status: TripStatus.active,
          contacts: [
            ContactSnapshot(name: 'Naledi', phoneNumber: '+27820000000'),
          ],
          locationSharing: args['locationSharing'] as LocationSharing,
        );
        if (loseStartReply)
          throw StateError('Synthetic connection loss after commit');
        result = TripSnapshot(trip: activeTrip, serverTime: now);
      default:
        throw StateError('Unexpected RPC: $call');
    }
    return result as T;
  }
}

void main() {
  final client = _Client();
  setUpAll(() => app.client = client);
  setUp(client.reset);
  tearDownAll(client.close);

  Future<void> show(WidgetTester tester, {double textScale = 1}) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: TripScreen(onOpenContacts: () {}, onOpenAlerts: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> planAndReview(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(const Key('ai-trip-input')),
      'Taxi home in 45 minutes',
    );
    await tap(tester, 'Prepare my draft');
    expect(client.starts, 0);
    await tap(tester, 'Review AI draft');
    expect(client.starts, 0);
    expect(
      tester
          .widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>))
          .onSelectionChanged,
      isNull,
    );
  }

  testWidgets(
    'the Trip tab plans through the generated client and shows only the confirmed trip',
    (tester) async {
      await show(tester);
      await planAndReview(tester);
      await tap(tester, 'Confirm and start');
      expect(client.starts, 1);
      expect(
        client.startArguments!['checkInAtUtc'],
        client.now.add(const Duration(minutes: 45)),
      );
      expect(client.startArguments!['locationSharing'], LocationSharing.off);
      expect(find.text('Trip active'), findsOneWidget);
      expect(find.byKey(const Key('ai-trip-input')), findsNothing);
      expect(client.calls.where((c) => c.startsWith('location.')), isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'a lost start reply reconciles the committed trip without retrying',
    (tester) async {
      client.loseStartReply = true;
      await show(tester);
      await planAndReview(tester);
      await tap(tester, 'Confirm and start');
      expect(client.starts, 1);
      expect(find.text('Trip active'), findsOneWidget);
      expect(
        client.calls.where((c) => c == 'trip.getActiveTrip').length,
        greaterThan(1),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('missing AI configuration leaves the manual form available', (
    tester,
  ) async {
    client.available = false;
    await show(tester);
    expect(find.text('Start a trip'), findsOneWidget);
    expect(
      find.text('AI planning is unavailable. Manual trip setup still works.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ai-trip-input')), findsNothing);
    expect(client.starts, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'the AI/manual selector fits a narrow screen with enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await show(tester, textScale: 1.5);
      expect(tester.takeException(), isNull);
      await tap(tester, 'Manual');
      expect(find.text('Start a trip'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
