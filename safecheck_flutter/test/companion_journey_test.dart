import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/widgets/companion_journey_form.dart';
import 'package:safecheck_flutter/widgets/trip_review_dialog.dart';
import 'package:safecheck_flutter/widgets/incident_brief_card.dart';

final now = DateTime.utc(2026, 11, 3, 10);
final contacts = [
  for (var i = 1; i <= 2; i++)
    TrustedContact(
      id: i,
      ownerId: 'owner',
      name: 'Contact $i',
      phoneNumber: '+2782000000$i',
      createdAt: now,
      updatedAt: now,
    ),
];
String plan(String source) => jsonEncode({
  'source': source,
  'checkInAdvice': 'Check the confirmed deadline.',
  'precautions': ['Check transport details.'],
  'uncertainties': ['No prediction of danger.'],
});
Widget form({
  required Future<void> Function(JourneyRequest) start,
  Future<List<TrustedContact>> Function()? refresh,
  Future<String> Function(TripType, String, DateTime, int)? prepare,
  bool? available = true,
  DateTime Function()? clock,
}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CompanionJourneyForm(
          contacts: contacts,
          loadContacts: refresh ?? () async => contacts,
          serverNow: clock ?? () => now,
          propose: (_, _) async => jsonEncode({
            'tripType': 'walking',
            'description': 'Walk to Pretoria station',
            'checkInAtUtc': now
                .add(const Duration(minutes: 30))
                .toIso8601String(),
            'questions': <String>[],
          }),
          preparePlan: prepare ?? (_, _, _, _) async => plan('meta'),
          onStart: start,
          onOpenContacts: () {},
          onBusyChanged: (_) {},
          aiAvailable: available,
          onRetryAvailability: () {},
        ),
      ),
    ),
  ),
);
Future<void> tap(WidgetTester t, String text) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await t.pumpAndSettle();
  await t.ensureVisible(find.text(text));
  await t.pumpAndSettle();
  await t.tap(find.text(text));
  await t.pumpAndSettle();
}

Future<void> describe(WidgetTester t) async => t.enterText(
  find.byKey(const Key('journey-description')),
  'Walk to Pretoria station',
);
void main() {
  testWidgets(
    'journey review does not act and confirms selected contacts with privacy defaults',
    (t) async {
      JourneyRequest? sent;
      await t.pumpWidget(form(start: (r) async => sent = r));
      await describe(t);
      await t.ensureVisible(find.text('Contact 2'));
      await t.pumpAndSettle();
      await t.tap(find.text('Contact 2'));
      await t.pumpAndSettle();
      await tap(t, 'Review safety journey');
      final review = t.widget<TripReviewDialog>(find.byType(TripReviewDialog));
      expect(review.contacts.map((c) => c.id), [1]);
      expect(sent, isNull);
      expect(review.locationSharing, LocationSharing.off);
      expect(review.graceMinutes, 0);
      await tap(t, 'Confirm and start');
      expect(sent!.contactIds, [1]);
      expect(sent!.useAiIncidentSummary, isFalse);
      expect(sent!.allowContactResolution, isFalse);
    },
  );
  testWidgets(
    'AI suggestions are displayed and saved only through confirmed review',
    (t) async {
      JourneyRequest? sent;
      await t.pumpWidget(form(start: (r) async => sent = r));
      await describe(t);
      await tap(t, 'Create AI safety plan');
      expect(find.text('AI safety plan'), findsOneWidget);
      expect(sent, isNull);
      await tap(t, 'Review safety journey');
      expect(
        t
            .widget<TripReviewDialog>(find.byType(TripReviewDialog))
            .safetyPlanJson,
        isNotNull,
      );
      await tap(t, 'Edit details');
      expect(sent, isNull);
      await tap(t, 'Review safety journey');
      await tap(t, 'Confirm and start');
      expect(jsonDecode(sent!.safetyPlanJson!)['source'], 'meta');
    },
  );
  testWidgets('provider fallback is labelled and does not block manual setup', (
    t,
  ) async {
    await t.pumpWidget(
      form(
        available: false,
        start: (_) async {},
        prepare: (_, _, _, _) async => plan('standard'),
      ),
    );
    expect(find.text('Describe with AI'), findsOneWidget);
    await describe(t);
    await tap(t, 'Create AI safety plan');
    expect(find.text('Standard safety plan'), findsOneWidget);
    await tap(t, 'Review safety journey');
    expect(find.byType(TripReviewDialog), findsOneWidget);
    await tap(t, 'Edit details');
  });
  testWidgets('deleted selected contacts prevent stale review', (t) async {
    await t.pumpWidget(
      form(
        start: (_) async => fail('Must not start'),
        refresh: () async => [contacts.first],
      ),
    );
    await describe(t);
    await tap(t, 'Review safety journey');
    expect(find.byType(TripReviewDialog), findsNothing);
    expect(find.textContaining('contacts changed'), findsOneWidget);
  });
  testWidgets('grace and explicit AI/contact permissions are reviewed', (
    t,
  ) async {
    JourneyRequest? sent;
    await t.pumpWidget(form(start: (r) async => sent = r));
    await describe(t);
    final dropdown = find.byType(DropdownButtonFormField<int>);
    await t.ensureVisible(dropdown);
    await t.pumpAndSettle();
    await t.tap(dropdown);
    await t.pumpAndSettle();
    await t.tap(find.text('5 minutes').last);
    await t.pumpAndSettle();
    await tap(t, 'Use Meta for an incident brief');
    await tap(t, 'Allow accepted contacts to resolve incidents');
    await tap(t, 'Review safety journey');
    final review = t.widget<TripReviewDialog>(find.byType(TripReviewDialog));
    expect(review.graceMinutes, 5);
    expect(review.useAiIncidentSummary, isTrue);
    expect(review.allowContactResolution, isTrue);
    await tap(t, 'Confirm and start');
    expect(sent!.graceMinutes, 5);
  });
  testWidgets('unsent AI changes cannot bypass review', (t) async {
    await t.pumpWidget(form(start: (_) async => fail('Must not start')));
    await describe(t);
    await t.ensureVisible(find.byKey(const Key('journey-ai-input')));
    await t.pumpAndSettle();
    await t.enterText(
      find.byKey(const Key('journey-ai-input')),
      'A different journey',
    );
    await tap(t, 'Review safety journey');
    expect(find.byType(TripReviewDialog), findsNothing);
    expect(find.textContaining('Interpret your typed changes'), findsOneWidget);
  });
  testWidgets(
    'incident card distinguishes facts, uncertainties, AI source and resolution',
    (t) async {
      var resolves = 0;
      final alert = SafetyAlert(
        id: 1,
        ownerId: 'owner',
        tripId: 1,
        travellerName: 'Traveller',
        travellerPhone: '+27820000000',
        tripType: TripType.walking,
        tripDescription: 'Home',
        deadline: now,
        createdAt: now,
        contacts: [],
        brief: IncidentBrief(
          source: 'meta',
          overview: 'Check-in not recorded.',
          facts: ['Deadline recorded.'],
          unknowns: ['Safety unconfirmed.'],
          nextSteps: ['Try calling.'],
          generatedAt: now,
        ),
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: IncidentBriefCard(
                alert: alert,
                onResolve: () => resolves++,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Recorded facts'), findsOneWidget);
      expect(find.text('What is uncertain'), findsOneWidget);
      await tap(t, 'Resolve incident');
      expect(resolves, 1);
    },
  );
}
