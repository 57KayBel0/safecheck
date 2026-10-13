import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:serverpod/serverpod.dart';

import 'public_configuration.dart';

/// Exposes Serverpod's server-verified Google identity-provider flow.
class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  /// Public readiness metadata for the sign-in screen, before authentication.
  Future<Map<String, String>> getConfiguration(Session session) async {
    final web = session.serverpod.config.webServer;
    if (web == null) {
      return publicConfigurationFor(
        webOrigin: Uri.parse('https://safecheck.serverpod.space'),
      );
    }
    return publicConfigurationFor(
      webOrigin: Uri(
        scheme: web.publicScheme,
        host: web.publicHost,
        port: web.publicPort,
      ),
      googleClientSecret: session.serverpod.getPassword('googleClientSecret'),
    );
  }
}
