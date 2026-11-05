import 'dart:io';

/// Twilio uses RFC 2822 UTC offsets, while HttpDate expects the GMT spelling.
DateTime parseTwilioTimestamp(String value) =>
    HttpDate.parse(value.replaceFirst(RegExp(r' \+0000$'), ' GMT'));
