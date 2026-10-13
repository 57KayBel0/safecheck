import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/cache_busting.dart';
import 'src/generated/serverpod.dart';
import 'src/messaging/bulk_sms_message_sender.dart';
import 'src/messaging/message_dispatcher.dart';
import 'src/trips/trip_service.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/safecheck_pages.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);

  // Live SMS requires an explicit mode plus both server-side API credentials.
  // Missing configuration keeps the demo sender active.
  MessageDispatcher.sender = messageSenderForConfig(
    mode: pod.getPassword('bulkSmsMode'),
    tokenId: pod.getPassword('bulkSmsTokenId'),
    tokenSecret: pod.getPassword('bulkSmsTokenSecret'),
  );

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      // The default setup works with Serverpod Cloud without configuration. In
      // development the verification codes are logged to the console, and in
      // staging and production they are sent through the Serverpod Cloud email
      // service. If you want to use a custom provider for sending emails, use
      // `EmailIdpConfigFromPasswords`.
      ServerpodCloudEmailIdpConfig(
        appDisplayName: 'safecheck',
      ),
      // Keep email authentication and server startup working until the OAuth
      // client secret is configured in passwords.yaml or the environment.
      if ((pod.getPassword('googleClientSecret') ?? '').trim().isNotEmpty)
        GoogleIdpConfigFromPasswords(),
    ],
  );

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/assets/assets/config.json',
  );

  // Public pages for trusted contacts: invite answers and trip tracking.
  pod.webServer.addRoute(
    StaticRoute.file(File('web/pages/privacy.html')),
    '/privacy',
  );
  pod.webServer.addRoute(InvitePageRoute(), '/c');
  pod.webServer.addRoute(TrackingPageRoute(), '/t');
  pod.webServer.addRoute(TrackingDataRoute(), '/t/:token');

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under /.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addMiddleware(
      FallbackMiddleware(
        fallback: defaultRoute,
        on: (response) => response.statusCode == 404,
      ).call,
      '/',
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/**',
    );
  }

  // Configure cloud storage.
  // This setup works with Serverpod Cloud without extra configuration.
  // If you want to use a custom provider for cloud storage, replace these
  // with your preferred provider.
  pod.addCloudStorage(
    await ServerpodCloudProvider.private(
      fallback: () => DatabaseCloudStorage('private'),
    ),
  );
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );

  // Start the server.
  await pod.start();

  await _scheduleOverdueTripSweep(pod);
}

/// Schedules a recurring sweep that raises alerts for any overdue trip whose
/// per-trip deadline call was lost. Each trip is processed at most once, so
/// running the sweep alongside the per-trip calls is safe.
Future<void> _scheduleOverdueTripSweep(Serverpod pod) async {
  final session = await pod.createSession(enableLogging: false);
  try {
    await pod.futureCalls.cancel(TripService.sweepCallId);
    await pod.futureCalls
        .callRecurring(identifier: TripService.sweepCallId)
        .every(const Duration(minutes: 1))
        .tripDeadline
        .sweepOverdue();
  } catch (e, stackTrace) {
    session.log(
      'Could not schedule the overdue trip sweep',
      level: LogLevel.error,
      exception: e,
      stackTrace: stackTrace,
    );
  } finally {
    await session.close();
  }
}
