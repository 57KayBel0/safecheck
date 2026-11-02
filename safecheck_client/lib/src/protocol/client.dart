/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:safecheck_client/src/protocol/alerts/alert_message.dart'
    as _inhs2hqy;
import 'package:safecheck_client/src/protocol/alerts/safety_alert.dart'
    as _ipl1wex2;
import 'package:safecheck_client/src/protocol/contacts/contact_invite.dart'
    as _iceljf2i;
import 'package:safecheck_client/src/protocol/contacts/trusted_contact.dart'
    as _ihgbcfsn;
import 'package:safecheck_client/src/protocol/profile/user_profile.dart'
    as _itjebnja;
import 'package:safecheck_client/src/protocol/tracking/location_point.dart'
    as _if9xc140;
import 'package:safecheck_client/src/protocol/tracking/location_sharing.dart'
    as _igcyrgmn;
import 'package:safecheck_client/src/protocol/tracking/tracking_link_info.dart'
    as _iw00f363;
import 'package:safecheck_client/src/protocol/tracking/trip_location.dart'
    as _iulcqs4y;
import 'package:safecheck_client/src/protocol/trips/trip.dart' as _i4r1fixk;
import 'package:safecheck_client/src/protocol/trips/trip_snapshot.dart'
    as _iifp4bsx;
import 'package:safecheck_client/src/protocol/trips/trip_type.dart'
    as _ietnx8jp;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// Lists the alerts raised for the signed-in user's missed check-ins and the
/// messages created for their contacts.
/// {@category Endpoint}
class EndpointAlert extends _isc.EndpointRef {
  EndpointAlert(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'alert';

  /// The caller's alerts, newest first.
  _ida.Future<List<_ipl1wex2.SafetyAlert>> listAlerts() =>
      caller.callServerEndpoint<List<_ipl1wex2.SafetyAlert>>(
        'alert',
        'listAlerts',
        {},
      );

  /// Messages for the caller's alerts, newest first. In this version every
  /// message has status `simulated`: nothing was sent.
  _ida.Future<List<_inhs2hqy.AlertMessage>> listMessages() =>
      caller.callServerEndpoint<List<_inhs2hqy.AlertMessage>>(
        'alert',
        'listMessages',
        {},
      );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// Exposes Serverpod's server-verified Google identity-provider flow.
/// {@category Endpoint}
class EndpointGoogleIdp extends _iaic.EndpointGoogleIdpBase {
  EndpointGoogleIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleIdp';

  /// Public readiness metadata for the sign-in screen, before authentication.
  _ida.Future<Map<String, String>> getConfiguration() =>
      caller.callServerEndpoint<Map<String, String>>(
        'googleIdp',
        'getConfiguration',
        {},
      );

  /// Validates a Google ID token and either logs in the associated user or
  /// creates a new user account if the Google account ID is not yet known.
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String idToken,
    required String? accessToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'login',
    {
      'idToken': idToken,
      'accessToken': accessToken,
    },
  );

  /// Validates a Google authorization code from the web OAuth2 PKCE flow and
  /// either logs in the associated user or creates a new account.
  ///
  /// This is the web counterpart of [login], which accepts an ID token directly
  /// (used on native platforms via the `google_sign_in` package).
  ///
  /// If a new user is created an associated [UserProfile] is also created.
  @override
  _ida.Future<_iacc.AuthSuccess> loginWithCode({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'googleIdp',
    'loginWithCode',
    {
      'code': code,
      'codeVerifier': codeVerifier,
      'redirectUri': redirectUri,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'googleIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// Manages the signed-in user's trusted contacts (at most five).
/// {@category Endpoint}
class EndpointContact extends _isc.EndpointRef {
  EndpointContact(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'contact';

  /// Lists the caller's trusted contacts, oldest first.
  _ida.Future<List<_ihgbcfsn.TrustedContact>> list() =>
      caller.callServerEndpoint<List<_ihgbcfsn.TrustedContact>>(
        'contact',
        'list',
        {},
      );

  /// Adds a trusted contact. Fails if the caller already has five.
  _ida.Future<_ihgbcfsn.TrustedContact> add(
    String name,
    String phoneNumber,
    String? relationship,
  ) => caller.callServerEndpoint<_ihgbcfsn.TrustedContact>(
    'contact',
    'add',
    {
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
    },
  );

  /// Updates one of the caller's trusted contacts. Trips that already started
  /// keep the contact details they were started with.
  _ida.Future<_ihgbcfsn.TrustedContact> update(
    int contactId,
    String name,
    String phoneNumber,
    String? relationship,
  ) => caller.callServerEndpoint<_ihgbcfsn.TrustedContact>(
    'contact',
    'update',
    {
      'contactId': contactId,
      'name': name,
      'phoneNumber': phoneNumber,
      'relationship': relationship,
    },
  );

  /// Returns the invite link for one of the caller's contacts, with a
  /// suggested message. The caller shares it from their own phone (e.g. a
  /// personal WhatsApp chat); SafeCheck does not send invites itself.
  _ida.Future<_iceljf2i.ContactInvite> getInvite(int contactId) =>
      caller.callServerEndpoint<_iceljf2i.ContactInvite>(
        'contact',
        'getInvite',
        {'contactId': contactId},
      );

  /// Removes one of the caller's trusted contacts.
  _ida.Future<void> remove(int contactId) => caller.callServerEndpoint<void>(
    'contact',
    'remove',
    {'contactId': contactId},
  );
}

/// Prepares read-only trip drafts for signed-in users. Never starts a trip.
/// {@category Endpoint}
class EndpointPlanning extends _isc.EndpointRef {
  EndpointPlanning(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'planning';

  _ida.Future<bool> isAvailable() => caller.callServerEndpoint<bool>(
    'planning',
    'isAvailable',
    {},
  );

  /// [history] alternates user text and the returned draft JSON, at most
  /// three completed exchanges. It is context only, never an authority to act.
  _ida.Future<String> propose(
    String input,
    List<String> history,
  ) => caller.callServerEndpoint<String>(
    'planning',
    'propose',
    {
      'input': input,
      'history': history,
    },
  );
}

/// Reads and updates the signed-in user's own profile.
/// {@category Endpoint}
class EndpointProfile extends _isc.EndpointRef {
  EndpointProfile(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'profile';

  /// Returns the caller's profile, or null if they have not set one up yet.
  _ida.Future<_itjebnja.UserProfile?> getProfile() =>
      caller.callServerEndpoint<_itjebnja.UserProfile?>(
        'profile',
        'getProfile',
        {},
      );

  /// Creates or updates the caller's profile.
  _ida.Future<_itjebnja.UserProfile> saveProfile(
    String displayName,
    String phoneNumber,
  ) => caller.callServerEndpoint<_itjebnja.UserProfile>(
    'profile',
    'saveProfile',
    {
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    },
  );
}

/// Receives GPS fixes from the signed-in user's phone during a trip.
/// {@category Endpoint}
class EndpointLocation extends _isc.EndpointRef {
  EndpointLocation(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'location';

  /// Stores a batch of fixes for the caller's trip [tripId]. Returns how many
  /// were stored. Safe to retry with the same points.
  _ida.Future<int> recordLocations(
    int tripId,
    List<_if9xc140.LocationPoint> points,
  ) => caller.callServerEndpoint<int>(
    'location',
    'recordLocations',
    {
      'tripId': tripId,
      'points': points,
    },
  );

  /// Returns the stored route for one of the caller's trips.
  _ida.Future<List<_iulcqs4y.TripLocation>> getTripLocations(int tripId) =>
      caller.callServerEndpoint<List<_iulcqs4y.TripLocation>>(
        'location',
        'getTripLocations',
        {'tripId': tripId},
      );
}

/// Starts trips, checks in and lists trip history for the signed-in user.
/// {@category Endpoint}
class EndpointTrip extends _isc.EndpointRef {
  EndpointTrip(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'trip';

  /// Returns the caller's active trip (if any) and the server time.
  _ida.Future<_iifp4bsx.TripSnapshot> getActiveTrip() =>
      caller.callServerEndpoint<_iifp4bsx.TripSnapshot>(
        'trip',
        'getActiveTrip',
        {},
      );

  /// Starts a trip. The deadline is computed on the server from
  /// [durationMinutes]. Fails if the caller already has an active trip.
  /// [locationSharing] decides whether contacts can see the trip's location.
  _ida.Future<_iifp4bsx.TripSnapshot> startTrip(
    _ietnx8jp.TripType tripType,
    String description,
    int durationMinutes, [
    _igcyrgmn.LocationSharing? locationSharing,
  ]) => caller.callServerEndpoint<_iifp4bsx.TripSnapshot>(
    'trip',
    'startTrip',
    {
      'tripType': tripType,
      'description': description,
      'durationMinutes': durationMinutes,
      'locationSharing': locationSharing,
    },
  );

  /// Starts a reviewed plan at its approved absolute deadline. The server
  /// revalidates the time at confirmation; it never shifts a stale draft.
  _ida.Future<_iifp4bsx.TripSnapshot> startPlannedTrip(
    _ietnx8jp.TripType tripType,
    String description,
    DateTime checkInAtUtc,
    _igcyrgmn.LocationSharing locationSharing,
  ) => caller.callServerEndpoint<_iifp4bsx.TripSnapshot>(
    'trip',
    'startPlannedTrip',
    {
      'tripType': tripType,
      'description': description,
      'checkInAtUtc': checkInAtUtc,
      'locationSharing': locationSharing,
    },
  );

  /// Checks in safely on the caller's active trip [tripId].
  _ida.Future<_iifp4bsx.TripSnapshot> checkIn(int tripId) =>
      caller.callServerEndpoint<_iifp4bsx.TripSnapshot>(
        'trip',
        'checkIn',
        {'tripId': tripId},
      );

  /// Lists the caller's 50 most recent trips, newest first.
  _ida.Future<List<_i4r1fixk.Trip>> history() =>
      caller.callServerEndpoint<List<_i4r1fixk.Trip>>(
        'trip',
        'history',
        {},
      );

  /// Each contact's tracking link for the caller's trip [tripId], for the
  /// caller to share. Empty when the trip does not share location.
  _ida.Future<List<_iw00f363.TrackingLinkInfo>> getTrackingLinks(int tripId) =>
      caller.callServerEndpoint<List<_iw00f363.TrackingLinkInfo>>(
        'trip',
        'getTrackingLinks',
        {'tripId': tripId},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    alert = EndpointAlert(this);
    emailIdp = EndpointEmailIdp(this);
    googleIdp = EndpointGoogleIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    contact = EndpointContact(this);
    planning = EndpointPlanning(this);
    profile = EndpointProfile(this);
    location = EndpointLocation(this);
    trip = EndpointTrip(this);
    modules = Modules(this);
  }

  late final EndpointAlert alert;

  late final EndpointEmailIdp emailIdp;

  late final EndpointGoogleIdp googleIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointContact contact;

  late final EndpointPlanning planning;

  late final EndpointProfile profile;

  late final EndpointLocation location;

  late final EndpointTrip trip;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'alert': alert,
    'emailIdp': emailIdp,
    'googleIdp': googleIdp,
    'jwtRefresh': jwtRefresh,
    'contact': contact,
    'planning': planning,
    'profile': profile,
    'location': location,
    'trip': trip,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
