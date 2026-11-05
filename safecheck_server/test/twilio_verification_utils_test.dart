import 'dart:io';

import 'package:test/test.dart';

import 'manual/twilio_verification_utils.dart';

void main() {
  test('Twilio numeric UTC offset parses without changing the instant', () {
    expect(
      parseTwilioTimestamp('Wed, 04 Nov 2026 12:00:00 +0000'),
      DateTime.utc(2026, 11, 4, 12),
    );
  });

  test('Twilio GMT timestamp remains supported', () {
    expect(
      parseTwilioTimestamp('Wed, 04 Nov 2026 12:00:00 GMT'),
      DateTime.utc(2026, 11, 4, 12),
    );
  });

  test('Malformed Twilio timestamps fail closed', () {
    expect(
      () => parseTwilioTimestamp('not-a-date'),
      throwsA(isA<HttpException>()),
    );
  });
}
