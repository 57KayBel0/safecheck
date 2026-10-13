// The workspace already resolves these packages for the app's auth SDK and
// Flutter tests. This pure Dart test can run without the Flutter SDK lockfile.
// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:safecheck_client/safecheck_client.dart';
import 'package:safecheck_flutter/auth/refresh_rejection_guard.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as auth;
import 'package:test/test.dart';

class MemoryStorage implements auth.ClientAuthSuccessStorage {
  auth.AuthSuccess? value;
  @override
  Future<auth.AuthSuccess?> get() async => value;
  @override
  Future<void> set(auth.AuthSuccess? data) async {
    value = data;
  }
}

class RejectingClient extends Client {
  RejectingClient() : super('http://localhost:1/');
  bool rejectSignOut = false;
  Object refreshFailure = auth.RefreshTokenNotFoundException();
  Completer<void>? refreshStarted;
  Completer<void>? releaseRefresh;
  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (method == 'refreshAccessToken') {
      final failure = refreshFailure;
      refreshStarted?.complete();
      await releaseRefresh?.future;
      throw failure;
    }
    if (method == 'signOutDevice') {
      if (rejectSignOut) throw Exception('Fake network failure');
      return null as T;
    }
    throw StateError('Unexpected endpoint $endpoint.$method');
  }
}

auth.ClientAuthSessionManager sessionManager(MemoryStorage storage) {
  final delegates = <String, ClientAuthKeyProvider>{};
  late auth.ClientAuthSessionManager manager;
  manager = auth.ClientAuthSessionManager(
    storage: storage,
    authKeyProviderDelegates: delegates,
    onAuthInfoChanged: (_) => guardRuntimeRefresh(manager, delegates),
  );
  return manager;
}

void main() {
  for (final rejectSignOut in [false, true]) {
    test(
      'validation clears rejected session even when sign-out fails=$rejectSignOut',
      () async {
        final client = RejectingClient()..rejectSignOut = rejectSignOut;
        final storage = MemoryStorage();
        final manager = sessionManager(storage);
        manager.setCaller(client.modules.serverpod_auth_core);
        await manager.updateSignedInUser(
          auth.AuthSuccess(
            authStrategy: 'jwt',
            token: 'fake',
            refreshToken: 'invalid',
            tokenExpiresAt: DateTime.utc(2000),
            authUserId: UuidValue.fromString(
              '11111111-1111-4111-8111-111111111111',
            ),
            scopeNames: {},
          ),
        );
        await manager.validateAuthentication();
        expect(manager.authInfo, isNull);
        expect(storage.value, isNull);
        expect(await manager.authHeaderValue, isNull);
      },
    );
  }
  test('runtime refresh rejection clears unusable session', () async {
    final client = RejectingClient();
    final storage = MemoryStorage();
    final manager = sessionManager(storage);
    manager.setCaller(client.modules.serverpod_auth_core);
    await manager.updateSignedInUser(
      auth.AuthSuccess(
        authStrategy: 'jwt',
        token: 'fake',
        refreshToken: 'invalid',
        tokenExpiresAt: DateTime.utc(2000),
        authUserId: UuidValue.fromString(
          '11111111-1111-4111-8111-111111111111',
        ),
        scopeNames: {},
      ),
    );
    expect(
      await manager.refreshAuthKey(force: true),
      RefreshAuthKeyResult.failedUnauthorized,
    );
    expect(manager.isAuthenticated, isFalse);
    expect(storage.value, isNull);
    expect(await manager.authHeaderValue, isNull);
  });

  test(
    'temporary runtime refresh failure retains credentials for retry',
    () async {
      final client = RejectingClient()..refreshFailure = Exception('Offline');
      final storage = MemoryStorage();
      final manager = sessionManager(storage);
      manager.setCaller(client.modules.serverpod_auth_core);
      final credentials = auth.AuthSuccess(
        authStrategy: 'jwt',
        token: 'fake',
        refreshToken: 'retryable',
        tokenExpiresAt: DateTime.utc(2000),
        authUserId: UuidValue.fromString(
          '11111111-1111-4111-8111-111111111111',
        ),
        scopeNames: {},
      );
      await manager.updateSignedInUser(credentials);
      expect(
        await manager.refreshAuthKey(force: true),
        RefreshAuthKeyResult.failedOther,
      );
      expect(manager.isAuthenticated, isTrue);
      expect(storage.value, credentials);
      expect(await manager.authHeaderValue, isNotNull);
    },
  );

  test('late rejection does not clear a replacement sign-in', () async {
    final client = RejectingClient()
      ..refreshStarted = Completer<void>()
      ..releaseRefresh = Completer<void>();
    final storage = MemoryStorage();
    final manager = sessionManager(storage);
    manager.setCaller(client.modules.serverpod_auth_core);
    final old = auth.AuthSuccess(
      authStrategy: 'jwt',
      token: 'old',
      refreshToken: 'rejected',
      tokenExpiresAt: DateTime.utc(2000),
      authUserId: UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      scopeNames: {},
    );
    await manager.updateSignedInUser(old);
    final refresh = manager.refreshAuthKey(force: true);
    await client.refreshStarted!.future;
    final replacement = old.copyWith(token: 'new', refreshToken: 'new-refresh');
    await manager.updateSignedInUser(replacement);
    client.releaseRefresh!.complete();
    expect(await refresh, RefreshAuthKeyResult.failedUnauthorized);
    expect(manager.authInfo, replacement);
    expect(storage.value, replacement);
  });
}
