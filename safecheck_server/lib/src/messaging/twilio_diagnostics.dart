import 'dart:convert';

/// Only numeric provider metadata crosses this boundary, never response text.
int? twilioErrorCode(String body) {
  if (body.length > 16384) return null;
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map) return null;
    final value = decoded['code'] ?? decoded['error_code'];
    final code = int.tryParse(value?.toString() ?? '');
    return code != null && code >= 10000 && code < 1000000 ? code : null;
  } catch (_) {
    return null;
  }
}

String twilioRejectionReason(int httpStatus, String body) {
  final code = twilioErrorCode(body);
  return 'Twilio rejected the request (HTTP $httpStatus${code == null ? '' : ', code $code'}).';
}
