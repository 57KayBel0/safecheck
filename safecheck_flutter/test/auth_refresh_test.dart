import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/client.dart' as app;
import 'package:safecheck_flutter/auth/session_manager.dart';
import 'package:safecheck_flutter/screens/sign_in_screen.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}

// Intercepts every endpoint call: these tests never contact a real server.
class RejectingRefreshClient extends Client {
  RejectingRefreshClient() : super('http://localhost:1/');
  bool rejectSignOut = false;
  bool temporaryRefreshFailure = false;
  final List<String> calls = [];

  // These tests open no streams. The SDK's real stream manager caches a
  // completed listener future in the first widget test's FakeAsync zone;
  // awaiting it in another test's zone hangs during an identity change.
  @override
  Future<void> closeStreamingMethodConnections({
    Object? exception = const WebSocketClosedException(),
  }) async {
    calls.add('closeStreamingMethodConnections');
  }

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    calls.add('$endpoint.$method');
    if (method == 'refreshAccessToken') {
      if (temporaryRefreshFailure) throw Exception('Fake offline failure');
      throw RefreshTokenNotFoundException();
    }
    if (method == 'signOutDevice') {
      if (rejectSignOut) throw Exception('Fake sign-out network failure');
      return null as T;
    }
    throw StateError('Unexpected call: $endpoint.$method');
  }
}

void main() {
  final fake = RejectingRefreshClient();
  late MemoryAuthStorage storage;
  late FlutterAuthSessionManager manager;
  app.client = fake;
  setUp(() {
    storage = MemoryAuthStorage();
    manager = createSafeCheckSessionManager(storage: storage);
    fake.authSessionManager = manager;
    fake.rejectSignOut = false;
    fake.temporaryRefreshFailure = false;
    fake.calls.clear();
  });

  Future<T> authOperation<T>(
    WidgetTester tester,
    String label,
    Future<T> Function() operation,
  ) async {
    // A timeout inside FakeAsync cannot fire while awaiting without pumping.
    // Start the operation AND watchdog in runAsync's real timer zone. Widget
    // pumps stay outside it. No endpoint reaches a real transport in this fake.
    final result = await tester.runAsync(() async {
      final value = await operation().timeout(
        const Duration(seconds: 2),
        onTimeout: () => throw TimeoutException(
          '$label stalled. Fake calls: ${fake.calls.join(', ')}',
        ),
      );
      return (value: value);
    });
    if (result == null) {
      fail(
        '$label failed; see runAsync error. Fake calls: ${fake.calls.join(', ')}',
      );
    }
    return result.value;
  }

  testWidgets(
    'runtime refresh rejection clears the unusable session and returns to sign-in',
    (tester) async {
      await authOperation(
        tester,
        'runtime rejection setup',
        () => manager.updateSignedInUser(
          AuthSuccess(
            authStrategy: 'jwt',
            token: 'fake-expired-token',
            refreshToken: 'fake-invalid-refresh',
            tokenExpiresAt: DateTime.utc(2000),
            authUserId: UuidValue.fromString(
              '11111111-1111-4111-8111-111111111111',
            ),
            scopeNames: {},
          ),
        ),
      );
      await tester.pumpWidget(
        const MaterialApp(home: SignInScreen(child: Text('Private content'))),
      );
      expect(find.text('Private content'), findsOneWidget);
      expect(
        await authOperation(
          tester,
          'permanent runtime refresh',
          () => manager.refreshAuthKey(force: true),
        ),
        RefreshAuthKeyResult.failedUnauthorized,
      );
      await tester.pump();
      expect(
        manager.isAuthenticated,
        isFalse,
        reason: 'A permanently rejected runtime refresh must sign out',
      );
      expect(storage.value, isNull);
      expect(find.text('Private content'), findsNothing);
      expect(find.byType(SignInWidget), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'temporary runtime refresh failure keeps private content and stored session',
    (tester) async {
      fake.temporaryRefreshFailure = true;
      try {
        await authOperation(
          tester,
          'temporary failure setup',
          () => manager.updateSignedInUser(
            AuthSuccess(
              authStrategy: 'jwt',
              token: 'fake-expired-token',
              refreshToken: 'retryable',
              tokenExpiresAt: DateTime.utc(2000),
              authUserId: UuidValue.fromString(
                '11111111-1111-4111-8111-111111111111',
              ),
              scopeNames: {},
            ),
          ),
        );
        await tester.pumpWidget(
          const MaterialApp(home: SignInScreen(child: Text('Private content'))),
        );
        expect(
          await authOperation(
            tester,
            'temporary runtime refresh',
            () => manager.refreshAuthKey(force: true),
          ),
          RefreshAuthKeyResult.failedOther,
        );
        await tester.pump();
        expect(manager.isAuthenticated, isTrue);
        expect(storage.value, isNotNull);
        expect(storage.value?.refreshToken, 'retryable');
        expect(manager.authInfo, storage.value);
        expect(
          fake.calls.where((call) => call.endsWith('.refreshAccessToken')),
          hasLength(1),
        );
        expect(
          fake.calls.where((call) => call.endsWith('.signOutDevice')),
          isEmpty,
        );
        expect(find.text('Private content'), findsOneWidget);
        expect(find.byType(SignInWidget), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        fake.temporaryRefreshFailure = false;
      }
    },
  );
  for (final signOutFails in [false, true]) {
    testWidgets(
      'rejected refresh clears storage and returns to sign-in; sign-out fails=$signOutFails',
      (tester) async {
        fake.rejectSignOut = signOutFails;
        fake.calls.clear();
        await authOperation(
          tester,
          'validation setup',
          () => manager.updateSignedInUser(
            AuthSuccess(
              authStrategy: 'jwt',
              token: 'fake-expired-token',
              refreshToken: 'fake-invalid-refresh',
              tokenExpiresAt: DateTime.utc(2000),
              authUserId: UuidValue.fromString(
                '11111111-1111-4111-8111-111111111111',
              ),
              scopeNames: {},
            ),
          ),
        );
        await tester.pumpWidget(
          const MaterialApp(home: SignInScreen(child: Text('Private content'))),
        );
        expect(find.text('Private content'), findsOneWidget);
        await authOperation(
          tester,
          'authentication validation',
          () => manager.validateAuthentication(),
        );
        await tester.pump();
        expect(manager.authInfo, isNull);
        expect(manager.isAuthenticated, isFalse);
        expect(storage.value, isNull);
        expect(
          await authOperation(
            tester,
            'signed-out auth header',
            () => manager.authHeaderValue,
          ),
          isNull,
        );
        expect(
          fake.calls.where((c) => c.endsWith('.refreshAccessToken')),
          hasLength(1),
        );
        expect(find.text('Private content'), findsNothing);
        expect(find.byType(SignInWidget), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets('email account navigation fits mobile and desktop constraints', (
    tester,
  ) async {
    await authOperation(
      tester,
      'navigation setup',
      () => manager.updateSignedInUser(null),
    );
    for (final width in [320.0, 360.0, 440.0, 800.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: width,
              child: const SignInScreen(child: Text('Private content')),
            ),
          ),
        ),
      );
      expect(find.text('Already have an account?'), findsOneWidget);
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
      expect(find.text("Don't have an account?"), findsOneWidget);
      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
      expect(find.text('Already have an account?'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
