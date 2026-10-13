import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Uses memory by default and Serverpod secure storage only after the user
/// explicitly selects Remember me. `client.auth.initialize()` still validates
/// any restored session with the server before treating it as signed in.
class RememberMeAuthSuccessStorage extends CachedClientAuthSuccessStorage {
  factory RememberMeAuthSuccessStorage({
    ClientAuthSuccessStorage? persistentAuthStorage,
    RememberMeKeyValueStorage? keyValueStorage,
  }) {
    final policy = _RememberMeStoragePolicy(
      persistentAuthStorage ?? SecureClientAuthSuccessStorage(),
      keyValueStorage ?? FlutterRememberMeKeyValueStorage(),
    );
    return RememberMeAuthSuccessStorage._(policy);
  }

  RememberMeAuthSuccessStorage._(this._policy) : super(delegate: _policy);

  final _RememberMeStoragePolicy _policy;

  static const _rememberedSessionKey = 'safecheck_remembered_session';
  static const _rememberedEmailKey = 'safecheck_remembered_email';

  Future<void> setRememberMe(bool selected) async {
    await _policy.setRememberMe(selected);
    if (!selected) await clearCache();
  }

  Future<String?> getRememberedEmail() => _policy.getRememberedEmail();

  Future<void> rememberEmailAfterSignIn(String email) async {
    await _policy.rememberEmailAfterSignIn(email);
  }
}

class _RememberMeStoragePolicy implements ClientAuthSuccessStorage {
  _RememberMeStoragePolicy(this._persistentAuthStorage, this._keyValueStorage);

  final ClientAuthSuccessStorage _persistentAuthStorage;
  final RememberMeKeyValueStorage _keyValueStorage;

  AuthSuccess? _temporaryAuth;
  bool _rememberOnNextSuccess = false;

  @override
  Future<AuthSuccess?> get() async {
    final shouldRestore =
        await _keyValueStorage.read(
          RememberMeAuthSuccessStorage._rememberedSessionKey,
        ) ==
        'true';
    _rememberOnNextSuccess = shouldRestore;
    if (shouldRestore) {
      // Serverpod invalidates this outer storage cache when a refresh token
      // rotates in another tab. Clear the secure delegate cache too.
      if (_persistentAuthStorage is CachedClientAuthSuccessStorage) {
        await _persistentAuthStorage.clearCache();
      }
      return _persistentAuthStorage.get();
    }

    // Remove sessions written by older app versions that persisted every
    // login, so an unchecked user is never silently restored from legacy data.
    await _persistentAuthStorage.set(null);
    return _temporaryAuth;
  }

  @override
  Future<void> set(AuthSuccess? data) async {
    if (data == null) {
      await _persistentAuthStorage.set(null);
      await _keyValueStorage.write(
        RememberMeAuthSuccessStorage._rememberedSessionKey,
        null,
      );
      _temporaryAuth = null;
      _rememberOnNextSuccess = false;
      return;
    }

    if (_rememberOnNextSuccess) {
      await _persistentAuthStorage.set(data);
      await _keyValueStorage.write(
        RememberMeAuthSuccessStorage._rememberedSessionKey,
        'true',
      );
      _temporaryAuth = null;
    } else {
      await _persistentAuthStorage.set(null);
      await _keyValueStorage.write(
        RememberMeAuthSuccessStorage._rememberedSessionKey,
        null,
      );
      await _keyValueStorage.write(
        RememberMeAuthSuccessStorage._rememberedEmailKey,
        null,
      );
      _temporaryAuth = data;
    }
  }

  Future<void> setRememberMe(bool selected) async {
    _rememberOnNextSuccess = selected;
    if (!selected) {
      await _persistentAuthStorage.set(null);
      await _keyValueStorage.write(
        RememberMeAuthSuccessStorage._rememberedSessionKey,
        null,
      );
      await _keyValueStorage.write(
        RememberMeAuthSuccessStorage._rememberedEmailKey,
        null,
      );
    }
  }

  Future<String?> getRememberedEmail() =>
      _keyValueStorage.read(RememberMeAuthSuccessStorage._rememberedEmailKey);

  Future<void> rememberEmailAfterSignIn(String email) async {
    if (_rememberOnNextSuccess) {
      await _keyValueStorage.write(
        RememberMeAuthSuccessStorage._rememberedEmailKey,
        email,
      );
    }
  }
}

/// Small seam for testing the remember policy without a platform plugin.
abstract interface class RememberMeKeyValueStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String? value);
}

class FlutterRememberMeKeyValueStorage implements RememberMeKeyValueStorage {
  FlutterRememberMeKeyValueStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      await _storage.delete(key: key);
    } else {
      await _storage.write(key: key, value: value);
    }
  }
}
