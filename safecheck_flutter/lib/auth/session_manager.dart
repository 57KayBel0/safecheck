import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'remember_me_storage.dart';
import 'refresh_rejection_guard.dart';

final rememberMeStorage = RememberMeAuthSuccessStorage();

FlutterAuthSessionManager createSafeCheckSessionManager({
  ClientAuthSuccessStorage? storage,
}) {
  final delegates = <String, ClientAuthKeyProvider>{};
  final manager = FlutterAuthSessionManager(
    storage: storage ?? rememberMeStorage,
    authKeyProviderDelegates: delegates,
  );
  manager.authInfoListenable.addListener(
    () => guardRuntimeRefresh(manager, delegates),
  );
  return manager;
}
