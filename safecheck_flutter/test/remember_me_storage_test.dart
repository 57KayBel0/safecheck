import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_flutter/auth/remember_me_storage.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

class MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? value;

  @override
  Future<AuthSuccess?> get() async => value;

  @override
  Future<void> set(AuthSuccess? data) async => value = data;
}

class CachedMemoryAuthStorage extends CachedClientAuthSuccessStorage {
  CachedMemoryAuthStorage(this.memoryStorage) : super(delegate: memoryStorage);

  final MemoryAuthStorage memoryStorage;
}

class MemoryKeyValueStorage implements RememberMeKeyValueStorage {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

AuthSuccess fakeAuthSuccess() => AuthSuccess(
  authStrategy: 'jwt',
  token: 'test-access-token',
  refreshToken: 'test-refresh-token',
  tokenExpiresAt: DateTime.utc(2030),
  authUserId: UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
  scopeNames: {},
);

void main() {
  test('unchecked login is temporary and does not retain email', () async {
    final persistent = MemoryAuthStorage();
    final local = MemoryKeyValueStorage();
    final storage = RememberMeAuthSuccessStorage(
      persistentAuthStorage: persistent,
      keyValueStorage: local,
    );
    final credentials = fakeAuthSuccess();

    expect(await storage.get(), isNull);
    await storage.set(credentials);
    await storage.rememberEmailAfterSignIn('person@example.com');

    expect(await storage.get(), credentials);
    expect(persistent.value, isNull);
    expect(await storage.getRememberedEmail(), isNull);

    final afterPageReload = RememberMeAuthSuccessStorage(
      persistentAuthStorage: persistent,
      keyValueStorage: local,
    );
    expect(await afterPageReload.get(), isNull);
  });

  test('remembered login restores session and email from secure store', () async {
    final persistent = MemoryAuthStorage();
    final local = MemoryKeyValueStorage();
    final storage = RememberMeAuthSuccessStorage(
      persistentAuthStorage: persistent,
      keyValueStorage: local,
    );
    final credentials = fakeAuthSuccess();

    await storage.setRememberMe(true);
    await storage.set(credentials);
    await storage.rememberEmailAfterSignIn('person@example.com');

    final nextVisit = RememberMeAuthSuccessStorage(
      persistentAuthStorage: persistent,
      keyValueStorage: local,
    );
    expect(await nextVisit.get(), credentials);
    expect(await nextVisit.getRememberedEmail(), 'person@example.com');
  });

  test('remembered storage observes refresh-token rotation from another tab', () async {
    final persistent = CachedMemoryAuthStorage(MemoryAuthStorage());
    final local = MemoryKeyValueStorage();
    final storage = RememberMeAuthSuccessStorage(
      persistentAuthStorage: persistent,
      keyValueStorage: local,
    );
    final credentials = fakeAuthSuccess();
    await storage.setRememberMe(true);
    await storage.set(credentials);

    await persistent.memoryStorage.set(
      credentials.copyWith(token: 'rotated-access-token'),
    );
    await storage.clearCache();

    expect(
      (await storage.get())?.token,
      'rotated-access-token',
    );
  });

  test('explicit sign-out clears persisted or temporary credentials', () async {
    for (final remember in [false, true]) {
      final persistent = MemoryAuthStorage();
      final local = MemoryKeyValueStorage();
      final storage = RememberMeAuthSuccessStorage(
        persistentAuthStorage: persistent,
        keyValueStorage: local,
      );
      await storage.setRememberMe(remember);
      await storage.set(fakeAuthSuccess());
      if (remember) await storage.rememberEmailAfterSignIn('person@example.com');

      await storage.set(null);

      expect(persistent.value, isNull);
      expect(await storage.get(), isNull);
    }
  });

  test('turning Remember me off deletes existing email and saved session', () async {
    final persistent = MemoryAuthStorage();
    final local = MemoryKeyValueStorage();
    final storage = RememberMeAuthSuccessStorage(
      persistentAuthStorage: persistent,
      keyValueStorage: local,
    );
    await storage.setRememberMe(true);
    await storage.set(fakeAuthSuccess());
    await storage.rememberEmailAfterSignIn('person@example.com');

    await storage.setRememberMe(false);

    expect(persistent.value, isNull);
    expect(await storage.getRememberedEmail(), isNull);
  });
}
