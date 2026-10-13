import 'dart:convert';

class GoogleWebConfiguration {
  const GoogleWebConfiguration({
    required this.clientId,
    required this.redirect,
  });

  final String clientId;
  final Uri redirect;
}

/// Resolve public server metadata, keeping development overrides explicit.
GoogleWebConfiguration? resolveGoogleWebConfiguration({
  required Map<String, String> serverConfiguration,
  required bool release,
  String clientIdOverride = '',
  String redirectOverride = '',
}) {
  final serverId = serverConfiguration['googleClientId'] ?? '';
  if (serverId.isEmpty ||
      (clientIdOverride.isNotEmpty && clientIdOverride != serverId)) {
    return null;
  }
  final origin = Uri.tryParse(serverConfiguration['webOrigin'] ?? '');
  if (origin == null || !origin.hasAuthority) return null;
  final redirect = Uri.tryParse(
    redirectOverride.isEmpty
        ? origin.resolve('/auth.html').toString()
        : redirectOverride,
  );
  if (redirect == null ||
      !redirect.hasAuthority ||
      !{'http', 'https'}.contains(redirect.scheme) ||
      redirect.path != '/auth.html' ||
      redirect.hasQuery ||
      redirect.hasFragment ||
      redirect.userInfo.isNotEmpty) {
    return null;
  }
  if (release &&
      (redirect.scheme != 'https' ||
          redirect.host == 'localhost' ||
          redirect.host.endsWith('.localhost') ||
          redirect.host == '127.0.0.1' ||
          redirect.host == '::1' ||
          redirect.origin != origin.origin)) {
    return null;
  }
  try {
    final registered = jsonDecode(
      serverConfiguration['googleRedirectUris'] ?? '[]',
    );
    if (registered is! List || !registered.contains(redirect.toString())) {
      return null;
    }
  } catch (_) {
    return null;
  }
  return GoogleWebConfiguration(clientId: serverId, redirect: redirect);
}
