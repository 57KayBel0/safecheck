import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/reminders/check_in_reminder.dart';
import 'package:safecheck_flutter/widgets/ai_trip_form.dart';
import 'package:safecheck_flutter/widgets/trip_review_dialog.dart';

final _now = DateTime.utc(2026, 11, 2, 18);
final _deadline = _now.add(const Duration(minutes: 45));

String _draft({bool ready = true}) => jsonEncode({
  'tripType': 'minibusTaxi',
  'description': 'Taxi from Pretoria CBD to Mamelodi',
  'checkInAtUtc': ready ? _deadline.toIso8601String() : null,
  'questions': ready ? <String>[] : ['What time will you check in?'],
});

TrustedContact _contact(String name) => TrustedContact(
  ownerId: 'owner',
  name: name,
  phoneNumber: '+27820000001',
  createdAt: _now,
  updatedAt: _now,
);

typedef _Start =
    Future<void> Function(
      TripType,
      String,
      DateTime,
      CheckInReminderMode,
      LocationSharing,
    );

Widget _form({
  required _Start onStart,
  Future<String> Function(String, List<String>)? propose,
  Future<List<TrustedContact>> Function()? loadContacts,
  DateTime Function()? clock,
  VoidCallback? onUseManual,
  ValueChanged<bool>? onBusyChanged,
  double textScale = 1,
}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AiTripForm(
          propose: propose ?? (_, _) async => _draft(),
          loadContacts: loadContacts ?? () async => [_contact('Naledi')],
          serverNow: clock ?? () => _now,
          onStart: onStart,
          onUseManual: onUseManual ?? () {},
          onOpenContacts: () {},
          onBusyChanged: onBusyChanged ?? (_) {},
        ),
      ),
    ),
  ),
);

Future<void> _tap(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _plan(
  WidgetTester tester, {
  String text = 'Taxi to Mamelodi in 45 minutes',
}) async {
  await tester.enterText(find.byKey(const Key('ai-trip-input')), text);
  await _tap(tester, 'Prepare my draft');
}

void main() {
  testWidgets(
    'clarifies, reviews fresh contacts, then starts only after confirmation',
    (tester) async {
      var requests = 0;
      var starts = 0;
      final contexts = <List<String>>[];
      final busy = <bool>[];
      await tester.pumpWidget(
        _form(
          propose: (input, history) async {
            contexts.add(history);
            return _draft(ready: ++requests > 1);
          },
          loadContacts: () async => [_contact('Updated contact')],
          onBusyChanged: busy.add,
          onStart: (type, description, deadline, reminder, sharing) async {
            starts++;
            expect(type, TripType.minibusTaxi);
            expect(deadline, _deadline);
            expect(reminder, CheckInReminderMode.silent);
            expect(sharing, LocationSharing.off);
          },
        ),
      );
      await _plan(tester);
      expect(find.text('What time will you check in?'), findsOneWidget);
      expect(find.text('Review AI draft'), findsNothing);
      await tester.enterText(
        find.byKey(const Key('ai-trip-input')),
        'In 45 minutes',
      );
      await _tap(tester, 'Send answer or changes');
      expect(contexts[0], isEmpty);
      expect(contexts[1], hasLength(2));
      expect(find.textContaining('20:45 SAST'), findsOneWidget);
      expect(starts, 0);
      await _tap(tester, 'Review AI draft');
      expect(find.text('Updated contact · +27820000001'), findsOneWidget);
      final review = tester.widget<TripReviewDialog>(
        find.byType(TripReviewDialog),
      );
      expect(review.exactDeadline, isTrue);
      expect(review.estimatedDeadline, _deadline);
      expect(find.text('Location off'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(starts, 0);
      await _tap(tester, 'Confirm and start');
      expect(starts, 1);
      expect(busy.last, isFalse);
    },
  );

  testWidgets('edit and dismissal preserve the draft without starting', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(_form(onStart: (_, _, _, _, _) async => starts++));
    await _plan(tester);
    await _tap(tester, 'Review AI draft');
    await _tap(tester, 'Edit details');
    expect(starts, 0);
    expect(find.text('Draft ready for review'), findsOneWidget);
    await _tap(tester, 'Review AI draft');
    Navigator.of(tester.element(find.byType(TripReviewDialog))).pop();
    await tester.pumpAndSettle();
    expect(starts, 0);
  });

  testWidgets(
    'unsent changes block review and failed changes invalidate the old draft',
    (tester) async {
      var requests = 0;
      await tester.pumpWidget(
        _form(
          onStart: (_, _, _, _, _) async => fail('Must not start'),
          propose: (_, _) async {
            if (++requests > 1) {
              throw SafeCheckException(
                message: 'AI unavailable',
                code: 'planning_unavailable',
              );
            }
            return _draft();
          },
        ),
      );
      await _plan(tester);
      await tester.enterText(
        find.byKey(const Key('ai-trip-input')),
        'Change to 30 minutes',
      );
      await tester.pump();
      final review = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Review AI draft'),
      );
      expect(review.onPressed, isNull);
      await _tap(tester, 'Send answer or changes');
      expect(find.text('AI unavailable'), findsOneWidget);
      expect(find.text('Review AI draft'), findsNothing);
    },
  );

  testWidgets('invalid provider output offers manual setup without starting', (
    tester,
  ) async {
    var manual = 0;
    await tester.pumpWidget(
      _form(
        onStart: (_, _, _, _, _) async => fail('Must not start'),
        propose: (_, _) async => '{"unexpected": true}',
        onUseManual: () => manual++,
      ),
    );
    await _plan(tester);
    expect(find.textContaining('invalid draft'), findsOneWidget);
    await _tap(tester, 'Use manual setup');
    expect(manual, 1);
  });

  testWidgets('slow proposals disable repeated requests and manual switching', (
    tester,
  ) async {
    final response = Completer<String>();
    var requests = 0;
    await tester.pumpWidget(
      _form(
        onStart: (_, _, _, _, _) async => fail('Must not start'),
        propose: (_, _) {
          requests++;
          return response.future;
        },
      ),
    );
    await tester.enterText(
      find.byKey(const Key('ai-trip-input')),
      'Taxi to Mamelodi',
    );
    await tester.ensureVisible(find.text('Prepare my draft'));
    await tester.tap(find.text('Prepare my draft'));
    await tester.pump();
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Preparing draft…'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(
            find.widgetWithText(TextButton, 'Use manual setup'),
          )
          .onPressed,
      isNull,
    );
    expect(requests, 1);
    response.complete(_draft());
    await tester.pumpAndSettle();
    expect(find.text('Review AI draft'), findsOneWidget);
  });

  testWidgets('a deadline that expires during review cannot start', (
    tester,
  ) async {
    var now = _now;
    var starts = 0;
    await tester.pumpWidget(
      _form(clock: () => now, onStart: (_, _, _, _, _) async => starts++),
    );
    await _plan(tester);
    await _tap(tester, 'Review AI draft');
    now = _deadline.subtract(const Duration(seconds: 20));
    await _tap(tester, 'Confirm and start');
    expect(starts, 0);
    expect(find.textContaining('draft has expired'), findsOneWidget);
  });

  testWidgets('empty refreshed contacts block confirmation', (tester) async {
    await tester.pumpWidget(
      _form(
        loadContacts: () async => [],
        onStart: (_, _, _, _, _) async => fail('Must not start'),
      ),
    );
    await _plan(tester);
    await _tap(tester, 'Review AI draft');
    expect(find.byType(TripReviewDialog), findsNothing);
    expect(
      find.text('Add a trusted contact before starting a trip.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'explicit location choice appears in review and confirmed request',
    (tester) async {
      LocationSharing? sent;
      await tester.pumpWidget(
        _form(onStart: (_, _, _, _, sharing) async => sent = sharing),
      );
      await _plan(tester);
      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<LocationSharing>),
      );
      await tester.tap(find.byType(DropdownButtonFormField<LocationSharing>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('After a missed check-in').last);
      await tester.pumpAndSettle();
      await _tap(tester, 'Review AI draft');
      expect(find.text('Location visible after an alert'), findsOneWidget);
      await _tap(tester, 'Confirm and start');
      expect(sent, LocationSharing.afterAlert);
    },
  );

  testWidgets('new draft clears prior context and location selection', (
    tester,
  ) async {
    final contexts = <List<String>>[];
    await tester.pumpWidget(
      _form(
        onStart: (_, _, _, _, _) async {},
        propose: (_, history) async {
          contexts.add(history);
          return _draft();
        },
      ),
    );
    await _plan(tester);
    await _tap(tester, 'New draft');
    expect(find.text('Draft ready for review'), findsNothing);
    await _plan(tester);
    expect(contexts, [<String>[], <String>[]]);
  });

  testWidgets('server rejection stays visible without automatically retrying', (
    tester,
  ) async {
    var starts = 0;
    await tester.pumpWidget(
      _form(
        onStart: (_, _, _, _, _) async {
          starts++;
          throw SafeCheckException(
            message: 'Review a new time.',
            code: 'validation',
          );
        },
      ),
    );
    await _plan(tester);
    await _tap(tester, 'Review AI draft');
    await _tap(tester, 'Confirm and start');
    expect(starts, 1);
    expect(find.text('Review a new time.'), findsOneWidget);
  });

  testWidgets('AI review fits a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _form(textScale: 1.5, onStart: (_, _, _, _, _) async {}),
    );
    await _plan(tester);
    await _tap(tester, 'Review AI draft');
    expect(tester.takeException(), isNull);
    await _tap(tester, 'Edit details');
    expect(tester.takeException(), isNull);
  });
}
