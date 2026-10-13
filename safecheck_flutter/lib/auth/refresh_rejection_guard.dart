// Uses the same core auth SDK already resolved by serverpod_auth_idp_flutter.
// ignore_for_file: depend_on_referenced_packages
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

/// Adds local session cleanup to the SDK's existing refresh provider.
/// Call when auth info changes, using the map passed to the SDK manager.
void guardRuntimeRefresh(
  ClientAuthSessionManager manager,
  Map<String, ClientAuthKeyProvider> delegates,
) {
  final strategy = manager.authInfo?.authStrategy;
  if (strategy == null) {
    return;
  }
  final delegate = manager.authKeyProviderDelegate;
  if (delegate is RefresherClientAuthKeyProvider &&
      delegate is! _RefreshRejectionGuard) {
    delegates[strategy] = _RefreshRejectionGuard(manager, delegate);
  }
}

class _RefreshRejectionGuard implements RefresherClientAuthKeyProvider {
  _RefreshRejectionGuard(this.manager, this.delegate);

  final ClientAuthSessionManager manager;
  final RefresherClientAuthKeyProvider delegate;

  @override
  Future<String?> get authHeaderValue => delegate.authHeaderValue;

  @override
  Future<RefreshAuthKeyResult> refreshAuthKey({bool force = false}) async {
    final checked = manager.authInfo;
    final result = await delegate.refreshAuthKey(force: force);
    final current = manager.authInfo;
    // Do not erase a new sign-in that replaced the rejected credentials while
    // the request was in flight. SDK storage reloads may copy the auth object.
    if (result == RefreshAuthKeyResult.failedUnauthorized &&
        checked != null &&
        current != null &&
        checked.authUserId == current.authUserId &&
        checked.token == current.token &&
        checked.refreshToken == current.refreshToken) {
      await manager.updateSignedInUser(null);
    }
    // Temporary network/server failures retain the session for a later retry.
    return result;
  }
}
