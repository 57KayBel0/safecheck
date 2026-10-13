// This pure Dart test uses the test package already resolved in the workspace.
// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';

import 'package:safecheck_flutter/auth/google_web_configuration.dart';
import 'package:test/test.dart';

void main() {
  const productionCallback = 'https://safecheck.serverpod.space/auth.html';
  const localCallback = 'http://localhost:55267/auth.html';
  final configured = {
    'webOrigin': 'https://safecheck.serverpod.space',
    'googleClientId': 'synthetic-client.apps.googleusercontent.com',
    'googleRedirectUris': jsonEncode([productionCallback, localCallback]),
  };

  test('release discovers the server client ID without build-time defines', () {
    final resolved = resolveGoogleWebConfiguration(
      serverConfiguration: configured,
      release: true,
    );
    expect(resolved?.clientId, configured['googleClientId']);
    expect(resolved?.redirect.toString(), productionCallback);
  });

  test(
    'missing server readiness never enables Google from build overrides',
    () {
      expect(
        resolveGoogleWebConfiguration(
          serverConfiguration: {},
          release: true,
          clientIdOverride: configured['googleClientId']!,
          redirectOverride: productionCallback,
        ),
        isNull,
      );
    },
  );

  test(
    'release rejects local, foreign, wrong-path or unregistered callbacks',
    () {
      for (final callback in [
        localCallback,
        'https://localhost/auth.html',
        'https://other.example/auth.html',
        'https://safecheck.serverpod.space/callback',
        '$productionCallback?extra=1',
      ]) {
        expect(
          resolveGoogleWebConfiguration(
            serverConfiguration: configured,
            release: true,
            redirectOverride: callback,
          ),
          isNull,
        );
      }
      expect(
        resolveGoogleWebConfiguration(
          serverConfiguration: {...configured, 'googleRedirectUris': '[]'},
          release: true,
        ),
        isNull,
      );
    },
  );

  test('mismatched build-time client cannot override the server client', () {
    expect(
      resolveGoogleWebConfiguration(
        serverConfiguration: configured,
        release: true,
        clientIdOverride: 'another-client.apps.googleusercontent.com',
      ),
      isNull,
    );
  });

  test('explicit local callback continues to work in development', () {
    final resolved = resolveGoogleWebConfiguration(
      serverConfiguration: {
        ...configured,
        'webOrigin': 'http://localhost:8082',
      },
      release: false,
      clientIdOverride: configured['googleClientId']!,
      redirectOverride: localCallback,
    );
    expect(resolved?.redirect.toString(), localCallback);
  });
}
