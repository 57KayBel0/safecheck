import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/util/errors.dart';
import 'package:safecheck_flutter/util/format.dart';
import 'package:safecheck_flutter/widgets/demo_notice.dart';

void main() {
  test('countdown formatting', () {
    expect(formatCountdown(const Duration(minutes: 4, seconds: 9)), '04:09');
    expect(
      formatCountdown(const Duration(hours: 1, minutes: 4, seconds: 9)),
      '01:04:09',
    );
    expect(formatCountdown(const Duration(seconds: -3)), '00:00');
    expect(
      describeCountdown(const Duration(hours: 1, minutes: 1)),
      '1 hour 1 minute left to check in',
    );
  });

  test('duration labels', () {
    expect(formatDurationShort(15), '15 min');
    expect(formatDurationShort(60), '1 h');
    expect(formatDurationShort(90), '1 h 30 min');
  });

  test('server validation messages are shown as-is', () {
    final error = SafeCheckException(message: 'Bad number', code: 'validation');
    expect(friendlyError(error), 'Bad number');
    expect(friendlyError(Exception('x')), contains('Something went wrong'));
  });

  testWidgets('message badge reflects simulated and live statuses', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageStatusBadge(
            status: MessageStatus.simulated,
            channel: MessageChannel.sms,
          ),
        ),
      ),
    );
    expect(find.text('Demo — SMS not sent'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MessageStatusBadge(
            status: MessageStatus.sent,
            channel: MessageChannel.sms,
          ),
        ),
      ),
    );
    expect(find.text('Accepted by provider'), findsOneWidget);
    expect(find.text('Demo — SMS not sent'), findsNothing);
  });
}
