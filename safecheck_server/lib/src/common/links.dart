import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

final _random = Random.secure();

/// A 256-bit random token, URL-safe and without padding.
String generateToken() {
  final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Absolute URL on this server's public web server for [path].
///
/// In development this is `http://localhost:8082/...`, which only works on
/// the developer's machine. Contacts on other devices need a deployed server
/// (or a `webServer.publicHost` they can reach).
String publicWebUrl(Session session, String path) {
  final web = session.serverpod.config.webServer;
  if (web == null) {
    return configuredPublicWebUrl(
      origin: null,
      path: path,
      runMode: session.serverpod.runMode,
    );
  }
  final defaultPort =
      (web.publicScheme == 'https' && web.publicPort == 443) ||
      (web.publicScheme == 'http' && web.publicPort == 80);
  final origin = Uri(
    scheme: web.publicScheme,
    host: web.publicHost,
    port: defaultPort ? null : web.publicPort,
  );
  return configuredPublicWebUrl(
    origin: origin,
    path: path,
    runMode: session.serverpod.runMode,
  );
}

/// Uses this deployment's configured origin, never another server's hostname.
/// A production configuration error must not emit a local or relative link.
String configuredPublicWebUrl({
  required Uri? origin,
  required String path,
  required String runMode,
}) {
  if (runMode == 'production') {
    final host = origin?.host.toLowerCase() ?? '';
    final parts = host.split('.').map(int.tryParse).toList();
    final localIpv4 =
        parts.length == 4 &&
        parts.every((p) => p != null) &&
        (parts[0] == 127 ||
            parts[0] == 10 ||
            parts[0] == 0 ||
            (parts[0] == 192 && parts[1] == 168) ||
            (parts[0] == 172 && parts[1]! >= 16 && parts[1]! <= 31) ||
            (parts[0] == 169 && parts[1] == 254));
    if (origin == null ||
        origin.scheme != 'https' ||
        host.isEmpty ||
        host == 'localhost' ||
        host.endsWith('.localhost') ||
        host.endsWith('.local') ||
        host == '::1' ||
        host == '::' ||
        host.startsWith('::ffff:127.') ||
        localIpv4 ||
        origin.userInfo.isNotEmpty ||
        origin.hasQuery ||
        origin.hasFragment ||
        (origin.path.isNotEmpty && origin.path != '/')) {
      throw StateError(
        'Production public web origin must be configured as public HTTPS.',
      );
    }
  }
  if (origin == null) return path;
  return origin.replace(path: path).toString();
}

String inviteUrl(Session session, String token) =>
    publicWebUrl(session, '/c/$token');

String trackingUrl(Session session, String token) =>
    publicWebUrl(session, '/t/$token');

/// Escapes text for safe use inside HTML.
String htmlEscape(String value) => const HtmlEscape().convert(value);
