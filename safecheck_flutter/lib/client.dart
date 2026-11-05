import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'auth/session_manager.dart';
import 'auth/google_web_configuration.dart';

// When you are running the app on a physical device, you need to set the
// server URL to the IP address of your computer. You can find the IP
// address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
//
// You can set the variable when running or building your app like this:
// E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`.
//
// Otherwise, the server URL is fetched from the assets/config.json file or
// defaults to http://$localhost:8080/ if not found.
final serverUrl = getServerUrl();

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

const googleWebClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
const googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
);
const googleServerProviderConfigured = bool.fromEnvironment(
  'GOOGLE_IDP_CONFIGURED',
);
const googleWebRedirectUri = String.fromEnvironment(
  'GOOGLE_WEB_REDIRECT_URI',
);

bool googleSignInReady = false;
// Development diagnostics contain reasons only, never OAuth credential values.
String googleSignInDiagnostic = 'Google setup has not started';
Uri publicWebOrigin = Uri.parse('https://safecheck.serverpod.space');

Future<void> initializeClient() async {
  final resolvedServerUrl = await serverUrl;
  client = Client(resolvedServerUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = createSafeCheckSessionManager();
  try {
    await client.auth.initialize();
  } catch (_) {
    // A temporary startup failure must not keep email sign-in from appearing.
  }

  try {
    googleSignInDiagnostic = 'Requesting Google configuration';
    if (kDebugMode) {
      debugPrint(
        'Google readiness: API origin ${Uri.parse(resolvedServerUrl).origin}',
      );
    }
    final configuration = await client.googleIdp.getConfiguration().timeout(
      const Duration(seconds: 5),
    );
    final origin = Uri.tryParse(configuration['webOrigin'] ?? '');
    if (origin != null && origin.hasAuthority) publicWebOrigin = origin;
    final googleWeb = resolveGoogleWebConfiguration(
      serverConfiguration: configuration,
      release: kReleaseMode,
      clientIdOverride: googleWebClientId,
      redirectOverride: googleWebRedirectUri,
    );
    googleSignInDiagnostic = googleWeb != null
        ? 'Configuration accepted; initializing Google'
        : (configuration['googleClientId'] ?? '').isEmpty
        ? 'Backend Google client is unavailable'
        : googleWebClientId.isNotEmpty &&
              googleWebClientId != configuration['googleClientId']
        ? 'Build client ID differs from backend client ID'
        : 'Callback or web origin rejected by configuration resolver';
    if (kDebugMode) {
      debugPrint('Google readiness: $googleSignInDiagnostic');
      if (kIsWeb) {
        debugPrint('Google readiness: browser origin ${Uri.base.origin}');
      }
      debugPrint(
        'Google readiness: metadata received; '
        'client present=${(configuration['googleClientId'] ?? '').isNotEmpty}; '
        'client matches=${googleWebClientId.isEmpty || googleWebClientId == configuration['googleClientId']}; '
        'configuration accepted=${googleWeb != null}',
      );
    }
    if (kIsWeb && googleWeb != null) {
      await client.auth.initializeGoogleSignIn(
        clientId: googleWeb.clientId,
        redirectUri: googleWeb.redirect.toString(),
      );
      googleSignInReady = true;
      googleSignInDiagnostic = 'Google initialization succeeded';
      if (kDebugMode)
        debugPrint('Google readiness: web initialization succeeded');
    } else if (googleServerProviderConfigured &&
        !kIsWeb &&
        (configuration['googleClientId'] ?? '').isNotEmpty &&
        googleWebClientId.isNotEmpty &&
        googleServerClientId.isNotEmpty) {
      await client.auth.initializeGoogleSignIn(
        clientId: googleWebClientId,
        serverClientId: googleServerClientId,
      );
      googleSignInReady = true;
    }
  } catch (error) {
    // Keep email sign-in available if optional Google setup is incomplete.
    googleSignInReady = false;
    googleSignInDiagnostic = error is TimeoutException
        ? 'Google configuration request timed out after 5 seconds'
        : 'Google setup failed (${error.runtimeType})';
    if (kDebugMode) {
      debugPrint(
        'Google readiness: initialization failed (${error.runtimeType})',
      );
    }
  }
}
