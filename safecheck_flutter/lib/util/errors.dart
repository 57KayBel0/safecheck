import 'package:safecheck_client/safecheck_client.dart';

/// Turns any error from a server call into a short message for the user.
String friendlyError(Object error) {
  if (error is SafeCheckException) return error.message;
  if (error is ServerpodClientUnauthorized) {
    return 'Your session has expired. Please sign in again.';
  }
  if (error is ServerpodClientNetworkException) {
    return "Can't reach SafeCheck. Check your connection and try again.";
  }
  if (error is ServerpodClientException) {
    return 'Something went wrong on the server. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}
