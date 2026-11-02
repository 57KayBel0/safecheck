import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/reminders/check_in_reminder.dart';
import 'package:safecheck_flutter/widgets/start_trip_form.dart';
import 'package:safecheck_flutter/widgets/trip_completion_notice.dart';
import 'package:safecheck_flutter/widgets/trip_review_dialog.dart';

final _now = DateTime.utc(2026, 11, 2, 18);

TrustedContact _contact(String name) => TrustedContact(
  ownerId: 'test-owner',
  name: name,
  phoneNumber: '+27820000001',
  createdAt: _now,
  updatedAt: _now,
);

typedef _Start =
    Future<void> Function(
      TripType,
      String,
      int,
      CheckInReminderMode,
      LocationSharing,
    );

Widget _form({
  required _Start onStart,
  List<TrustedContact>? contacts,
  Future<List<TrustedContact>> Function()? loadContacts,
  VoidCallback? onOpenContacts,
}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StartTripForm(
          contacts: contacts ?? [_contact('Naledi')],
          loadContacts: loadContacts ?? () async => [_contact('Naledi')],
          serverNow: () => _now,
          onOpenContacts: onOpenContacts ?? () {},
          onStart: onStart,
        ),
      ),
    ),
  ),
);

Future<void> _review(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Review trip'));
  await tester.tap(find.text('Review trip'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('review does not start a trip and location defaults to off', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(_form(onStart: (_, _, _, _, _) async => starts++));
    await tester.enterText(
      find.byType(TextFormField).first,
      'Taxi to Pretoria',
    );
    await _review(tester);

    expect(find.text('Review your trip'), findsOneWidget);
    expect(find.text('Location off'), findsOneWidget);
    expect(find.text('No location will be recorded.'), findsOneWidget);
    expect(find.text('Naledi · +27820000001'), findsOneWidget);
    final review = tester.widget<TripReviewDialog>(
      find.byType(TripReviewDialog),
    );
    expect(review.estimatedDeadline, _now.add(const Duration(minutes: 30)));
    expect(starts, 0);
  });

  testWidgets('editing a draft preserves it without starting', (tester) async {
    var starts = 0;
    await tester.pumpWidget(_form(onStart: (_, _, _, _, _) async => starts++));
    await tester.enterText(
      find.byType(TextFormField).first,
      'Taxi to Pretoria',
    );
    await _review(tester);
    await tester.tap(find.text('Edit details'));
    await tester.pumpAndSettle();

    expect(find.byType(TripReviewDialog), findsNothing);
    expect(find.text('Taxi to Pretoria'), findsOneWidget);
    expect(starts, 0);
  });

  testWidgets('confirmation starts once with the reviewed values', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(
      _form(
        onStart: (type, description, minutes, reminder, sharing) async {
          starts++;
          expect(type, TripType.walking);
          expect(description, 'Walk home');
          expect(minutes, 30);
          expect(reminder, CheckInReminderMode.silent);
          expect(sharing, LocationSharing.off);
        },
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, '  Walk home  ');
    await _review(tester);
    expect(starts, 0);
    await tester.tap(find.text('Confirm and start'));
    await tester.pumpAndSettle();
    expect(starts, 1);
  });

  testWidgets('review refreshes the contact list', (tester) async {
    await tester.pumpWidget(
      _form(
        contacts: [_contact('Old name')],
        loadContacts: () async => [_contact('Updated name')],
        onStart: (_, _, _, _, _) async {},
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Walk home');
    await _review(tester);

    expect(find.text('Updated name · +27820000001'), findsOneWidget);
    expect(find.text('Old name · +27820000001'), findsNothing);
  });

  testWidgets('explicit location choice survives review and confirmation', (
    tester,
  ) async {
    LocationSharing? startedSharing;
    await tester.pumpWidget(
      _form(onStart: (_, _, _, _, sharing) async => startedSharing = sharing),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Taxi home');
    final sharingField = find.byType(DropdownButtonFormField<LocationSharing>);
    await tester.ensureVisible(sharingField);
    await tester.tap(sharingField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('After a missed check-in').last);
    await tester.pumpAndSettle();
    await _review(tester);

    expect(find.text('Location visible after an alert'), findsOneWidget);
    expect(startedSharing, isNull);
    await tester.tap(find.text('Confirm and start'));
    await tester.pumpAndSettle();
    expect(startedSharing, LocationSharing.afterAlert);
  });

  testWidgets('a failed start keeps the draft available for correction', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(
      _form(
        onStart: (_, _, _, _, _) async {
          starts++;
          throw SafeCheckException(
            code: 'conflict',
            message: 'Your trip could not be started.',
          );
        },
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Taxi home');
    await _review(tester);
    await tester.tap(find.text('Confirm and start'));
    await tester.pumpAndSettle();

    expect(starts, 1);
    expect(find.text('Your trip could not be started.'), findsOneWidget);
    expect(find.text('Taxi home'), findsOneWidget);
    expect(find.text('Review trip'), findsOneWidget);
  });

  testWidgets('contact deletion before review prevents starting', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(
      _form(
        loadContacts: () async => [],
        onStart: (_, _, _, _, _) async => starts++,
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Walk home');
    await _review(tester);

    expect(find.byType(TripReviewDialog), findsNothing);
    expect(
      find.text('Add a trusted contact before starting a trip.'),
      findsOneWidget,
    );
    expect(starts, 0);
  });

  testWidgets('failed contact refresh does not offer an outdated review', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(
      _form(
        loadContacts: () async => throw SafeCheckException(
          code: 'validation',
          message: 'Could not refresh contacts.',
        ),
        onStart: (_, _, _, _, _) async => starts++,
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Walk home');
    await _review(tester);

    expect(find.byType(TripReviewDialog), findsNothing);
    expect(find.text('Could not refresh contacts.'), findsOneWidget);
    expect(starts, 0);
  });

  testWidgets('invalid form never loads contacts or starts a trip', (
    tester,
  ) async {
    var loads = 0;
    var starts = 0;
    await tester.pumpWidget(
      _form(
        loadContacts: () async {
          loads++;
          return [_contact('Naledi')];
        },
        onStart: (_, _, _, _, _) async => starts++,
      ),
    );
    await _review(tester);

    expect(find.byType(TripReviewDialog), findsNothing);
    expect(loads, 0);
    expect(starts, 0);
  });

  testWidgets('a pending review cannot submit a second request', (
    tester,
  ) async {
    final pendingContacts = Completer<List<TrustedContact>>();
    var loads = 0;
    var starts = 0;
    await tester.pumpWidget(
      _form(
        loadContacts: () {
          loads++;
          return pendingContacts.future;
        },
        onStart: (_, _, _, _, _) async => starts++,
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Walk home');
    await tester.ensureVisible(find.text('Review trip'));
    await tester.tap(find.text('Review trip'));
    await tester.pump();

    final preparing = find.ancestor(
      of: find.text('Loading contacts…'),
      matching: find.byWidgetPredicate((widget) => widget is FilledButton),
    );
    expect(tester.widget<FilledButton>(preparing).onPressed, isNull);
    expect(loads, 1);
    expect(starts, 0);
    pendingContacts.complete([_contact('Naledi')]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit details'));
    await tester.pumpAndSettle();
  });

  testWidgets('dismissal also starts no trip', (tester) async {
    var starts = 0;
    await tester.pumpWidget(_form(onStart: (_, _, _, _, _) async => starts++));
    await tester.enterText(find.byType(TextFormField).first, 'Walk home');
    await _review(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(TripReviewDialog), findsNothing);
    expect(starts, 0);
  });

  testWidgets(
    'missed-trip notice links to statuses without claiming delivery',
    (tester) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TripCompletionNotice(
              status: TripStatus.missed,
              onDismiss: () {},
              onOpenAlerts: () => opened = true,
            ),
          ),
        ),
      );

      expect(
        find.textContaining('does not confirm message delivery'),
        findsOneWidget,
      );
      expect(find.textContaining('no SMS was sent'), findsNothing);
      await tester.tap(find.text('View alerts'));
      expect(opened, isTrue);
    },
  );

  testWidgets('safe check-in does not show the missed-alert action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TripCompletionNotice(
            status: TripStatus.checkedIn,
            onDismiss: () {},
            onOpenAlerts: () {},
          ),
        ),
      ),
    );
    expect(find.text("You're checked in"), findsOneWidget);
    expect(find.text('View alerts'), findsNothing);
  });

  testWidgets('review fits a narrow screen with large text and long details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (_) => TripReviewDialog(
                  tripType: TripType.minibusTaxi,
                  description: 'Long trip description ' * 9,
                  durationMinutes: 1440,
                  estimatedDeadline: _now.add(const Duration(days: 1)),
                  contacts: [
                    for (var i = 0; i < 5; i++) _contact('Contact $i'),
                  ],
                  locationSharing: LocationSharing.afterAlert,
                  reminderMode: CheckInReminderMode.silent,
                ),
              ),
              child: const Text('Open review'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open review'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Edit details'));
    await tester.pumpAndSettle();
    expect(find.byType(TripReviewDialog), findsNothing);
  });
}
