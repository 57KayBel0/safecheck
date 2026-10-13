import 'dart:convert';

import 'package:serverpod_auth_idp_server/providers/google.dart';

/// Only public metadata leaves the server; never return the credential JSON.
Map<String, String> publicConfigurationFor({
  required Uri webOrigin,
  String? googleClientSecret,
}) {
  var clientId = '';
  var redirects = <String>[];
  if (googleClientSecret != null && googleClientSecret.trim().isNotEmpty) {
    try {
      final credentials = GoogleClientSecret.fromJsonString(googleClientSecret);
      if (credentials.clientSecret.trim().isNotEmpty &&
          credentials.clientId.trim().isNotEmpty) {
        clientId = credentials.clientId;
        redirects = credentials.redirectUris;
      }
    } catch (_) {
      // Configuration errors must not expose credential contents in feedback.
    }
  }
  return {
    'webOrigin': webOrigin.origin,
    'googleClientId': clientId,
    'googleRedirectUris': jsonEncode(redirects),
  };
}
