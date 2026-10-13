import 'dart:convert';

import 'package:safecheck_server/src/auth/public_configuration.dart';
import 'package:test/test.dart';

void main() {
  final origin = Uri.parse('https://safecheck.serverpod.space');
  String credential({String secret = 'synthetic-test-value'}) => jsonEncode({
    'web': {
      'client_id': 'synthetic-client.apps.googleusercontent.com',
      'client_secret': secret,
      'redirect_uris': [
        'https://safecheck.serverpod.space/auth.html',
        'http://localhost:55267/auth.html',
      ],
    },
  });

  test('missing, malformed or empty credentials keep Google unavailable', () {
    for (final value in [null, '', 'invalid JSON', credential(secret: '')]) {
      final public = publicConfigurationFor(
        webOrigin: origin,
        googleClientSecret: value,
      );
      expect(public['googleClientId'], isEmpty);
      expect(public['googleRedirectUris'], '[]');
      expect(public['webOrigin'], origin.origin);
    }
  });

  test('valid configuration exposes only public metadata', () {
    final private = credential();
    final public = publicConfigurationFor(
      webOrigin: origin,
      googleClientSecret: private,
    );
    expect(public.keys.toSet(), {
      'webOrigin',
      'googleClientId',
      'googleRedirectUris',
    });
    expect(
      public['googleClientId'],
      'synthetic-client.apps.googleusercontent.com',
    );
    expect(jsonDecode(public['googleRedirectUris']!), hasLength(2));
    expect(jsonEncode(public), isNot(contains('synthetic-test-value')));
    expect(jsonEncode(public), isNot(contains('client_secret')));
  });
}
