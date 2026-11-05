import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/auth/session_manager.dart';
import 'package:safecheck_flutter/client.dart' as app;
import 'package:safecheck_flutter/screens/app_shell.dart';
import 'package:safecheck_flutter/screens/sign_in_screen.dart';
import 'package:safecheck_flutter/screens/trip_screen.dart';
import 'package:safecheck_flutter/theme/safecheck_theme.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart'
    hide UserProfile;

class _Storage implements ClientAuthSuccessStorage {
  @override
  Future<AuthSuccess?> get() async => null;
  @override
  Future<void> set(AuthSuccess? data) async {}
}

/// Fictional fixtures only. These previews are not provider or delivery proof.
class _PreviewClient extends Client {
  _PreviewClient() : super('http://localhost:1/') {
    authSessionManager = createSafeCheckSessionManager(storage: _Storage());
  }
  final now = DateTime.now().toUtc();
  bool active = false;
  final calls = <String>[];
  List<TrustedContact> get contacts => [
    for (final name in ['Naledi', 'Thabo'])
      TrustedContact(
        id: name == 'Naledi' ? 1 : 2,
        ownerId: 'fictional',
        name: name,
        phoneNumber: '+27820000000',
        createdAt: now,
        updatedAt: now,
      ),
  ];
  String get plan => jsonEncode({
    'source': 'standard',
    'checkInAdvice': 'Use the check-in time you reviewed before starting.',
    'precautions': [
      'Keep your phone charged.',
      'Confirm your transport details.',
    ],
    'uncertainties': [
      'This plan does not predict danger or guarantee assistance.',
    ],
  });
  Trip get sampleTrip => Trip(
    id: 1,
    ownerId: 'fictional',
    tripType: TripType.walking,
    description: 'Walk from the demo library to accommodation',
    startedAt: now.subtract(const Duration(minutes: 15)),
    deadline: now.add(const Duration(minutes: 45)),
    durationMinutes: 60,
    status: TripStatus.active,
    contacts: [ContactSnapshot(name: 'Naledi', phoneNumber: '+27820000000')],
    safetyPlanJson: plan,
  );
  SafetyAlert get sampleAlert => SafetyAlert(
    id: 1,
    ownerId: 'fictional',
    tripId: 1,
    travellerName: 'Demo traveller',
    travellerPhone: '+27820000000',
    tripType: TripType.walking,
    tripDescription: 'Fictional walk home',
    deadline: now.subtract(const Duration(minutes: 5)),
    createdAt: now,
    contacts: [],
    brief: IncidentBrief(
      source: 'standard',
      overview: 'The scheduled check-in was not recorded.',
      facts: [
        'Traveller-reported journey: Fictional walk home.',
        'The check-in deadline is recorded by the server.',
      ],
      unknowns: [
        'Current safety is unconfirmed.',
        'A missed check-in is not proof of danger.',
      ],
      nextSteps: [
        'Try calling or messaging the traveller.',
        'Check the deadline and context.',
      ],
      generatedAt: now,
    ),
  );
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    final call = '$endpoint.$method';
    calls.add(call);
    final Object result = switch (call) {
      'profile.getProfile' => UserProfile(
        ownerId: 'fictional',
        displayName: 'Demo traveller',
        phoneNumber: '+27820000000',
        createdAt: now,
        updatedAt: now,
      ),
      'trip.getActiveTrip' => TripSnapshot(
        trip: active ? sampleTrip : null,
        serverTime: now,
      ),
      'contact.list' => contacts,
      'trip.history' => <Trip>[],
      'alert.listAlerts' => [sampleAlert],
      'alert.listMessages' => <AlertMessage>[],
      'planning.isAvailable' => false,
      _ => throw StateError('Unexpected fixture RPC: $call'),
    };
    return result as T;
  }
}

void main() {
  final client = _PreviewClient();
  final captureKey = GlobalKey();
  final export = Platform.environment['SAFECHECK_UI_PREVIEWS'] == '1';
  setUpAll(() async {
    app.client = client;
    if (export) {
      final root = Platform.environment['FLUTTER_ROOT'];
      if (root != null) {
        for (final font in [
          ('Roboto', 'roboto-regular.ttf'),
          ('MaterialIcons', 'materialicons-regular.otf'),
        ]) {
          final file = File(
            '$root/bin/cache/artifacts/material_fonts/${font.$2}',
          );
          final loader = FontLoader(font.$1)
            ..addFont(
              Future.value(ByteData.sublistView(file.readAsBytesSync())),
            );
          await loader.load();
        }
      }
    }
  });
  setUp(() {
    client.active = false;
    client.calls.clear();
  });
  tearDownAll(client.close);

  Future<void> show(
    WidgetTester tester,
    Widget home, {
    Size size = const Size(1280, 1000),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SafeCheckTheme.build(Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    if (!export) return;
    await tester.runAsync(() async {
      final boundary =
          captureKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final folder = Directory('../.dart_tool/design_previews')
        ..createSync(recursive: true);
      File(
        '${folder.path}/$name.png',
      ).writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
    });
  }

  test('dark safety text and primary/error actions have readable contrast', () {
    final colors = SafeCheckTheme.build(Brightness.dark).colorScheme;
    double contrast(Color a, Color b) {
      final first = a.computeLuminance();
      final second = b.computeLuminance();
      return first > second
          ? (first + .05) / (second + .05)
          : (second + .05) / (first + .05);
    }

    expect(contrast(colors.onSurface, colors.surface), greaterThan(4.5));
    expect(contrast(colors.onSurfaceVariant, colors.surface), greaterThan(4.5));
    expect(contrast(colors.onPrimary, colors.primary), greaterThan(4.5));
    expect(contrast(colors.error, colors.surface), greaterThan(4.5));
  });

  testWidgets(
    'dark authentication wraps at mobile text scale and retains email flow',
    (tester) async {
      await show(
        tester,
        const SignInScreen(
          googleSignInConfigured: false,
          child: Text('Private'),
        ),
        size: const Size(360, 1000),
        scale: 1.5,
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Remember me on this device'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('welcome and dashboard render in dark desktop layout', (
    tester,
  ) async {
    await show(
      tester,
      const SignInScreen(googleSignInConfigured: false, child: SizedBox()),
    );
    expect(tester.takeException(), isNull);
    await capture(tester, 'authentication-desktop');
    await tester.pumpWidget(const SizedBox.shrink());
    await show(
      tester,
      AppShell(themeMode: ThemeMode.dark, onThemeModeChanged: (_) {}),
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('No active journey'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'dashboard-desktop');
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Alerts'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Recorded facts'), findsOneWidget);
    expect(find.text('Standard incident brief'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await capture(tester, 'incidents-desktop');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'active journey keeps help confirmation and location-off privacy on mobile',
    (tester) async {
      client.active = true;
      await show(
        tester,
        Scaffold(
          body: TripScreen(onOpenContacts: () {}, onOpenAlerts: () {}),
        ),
        size: const Size(390, 1000),
      );
      expect(find.text('Trip active'), findsOneWidget);
      expect(find.text("I'm safe"), findsOneWidget);
      expect(find.text('Location sharing is off'), findsOneWidget);
      expect(client.calls.where((c) => c.startsWith('location.')), isEmpty);
      expect(tester.takeException(), isNull);
      await capture(tester, 'active-journey-mobile');
      await tester.ensureVisible(find.text('Request help'));
      await tester.tap(find.text('Request help'));
      await tester.pumpAndSettle();
      expect(find.text('Request help from your contacts?'), findsOneWidget);
      expect(client.calls, isNot(contains('trip.requestHelp')));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
