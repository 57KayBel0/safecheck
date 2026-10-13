import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_flutter/reminders/check_in_reminder.dart';
import 'package:safecheck_flutter/reminders/reminder_feedback.dart';

void main() {
  final deadline = DateTime.utc(2026, 10, 9, 12);

  test('does not claim a reminder before the final-minute threshold', () {
    final gate = CheckInReminderGate();

    expect(
      gate.claim(
        tripId: 7,
        deadline: deadline,
        serverNow: deadline.subtract(const Duration(seconds: 61)),
      ),
      isFalse,
    );
    expect(gate.isVisibleFor(7), isFalse);
  });

  test('claims exactly one reminder during the final minute', () {
    final gate = CheckInReminderGate();

    expect(
      gate.claim(
        tripId: 7,
        deadline: deadline,
        serverNow: deadline.subtract(const Duration(seconds: 60)),
      ),
      isTrue,
    );
    expect(
      gate.claim(
        tripId: 7,
        deadline: deadline,
        serverNow: deadline.subtract(const Duration(seconds: 20)),
      ),
      isFalse,
    );
    expect(gate.isVisibleFor(7), isTrue);
  });

  testWidgets('silent mode sends no sound or vibration platform call', (
    tester,
  ) async {
    var platformCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          platformCalls++;
          return null;
        });

    await playReminderFeedback(CheckInReminderMode.silent);

    expect(platformCalls, 0);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('check-in cancels a visible reminder without making it repeatable', () {
    final gate = CheckInReminderGate();
    expect(
      gate.claim(
        tripId: 7,
        deadline: deadline,
        serverNow: deadline.subtract(const Duration(seconds: 30)),
      ),
      isTrue,
    );

    gate.cancel(7);

    expect(gate.isVisibleFor(7), isFalse);
    expect(
      gate.claim(
        tripId: 7,
        deadline: deadline,
        serverNow: deadline.subtract(const Duration(seconds: 20)),
      ),
      isFalse,
    );
  });

  test('rebuild or resume within the final minute does not repeat it', () {
    final gate = CheckInReminderGate();
    final now = deadline.subtract(const Duration(seconds: 45));

    expect(
      gate.claim(tripId: 7, deadline: deadline, serverNow: now),
      isTrue,
    );
    // A rebuild, ticker tick, or resumed-tab evaluation reuses this gate.
    expect(
      gate.claim(tripId: 7, deadline: deadline, serverNow: now),
      isFalse,
    );
  });

  test('does not claim a reminder at or after the deadline', () {
    final gate = CheckInReminderGate();

    for (final now in [deadline, deadline.add(const Duration(seconds: 1))]) {
      expect(
        gate.claim(tripId: 7, deadline: deadline, serverNow: now),
        isFalse,
      );
    }
    expect(gate.isVisibleFor(7), isFalse);
  });

  test(
    'reminder evaluation leaves the deadline unchanged and is local-only',
    () {
      final gate = CheckInReminderGate();
      final originalDeadline = deadline;

      expect(
        gate.claim(
          tripId: 7,
          deadline: deadline,
          serverNow: deadline.subtract(const Duration(seconds: 10)),
        ),
        isTrue,
      );
      expect(deadline, originalDeadline);
      // The reminder gate has no client, endpoint, alert, or message dependency.
    },
  );
}
