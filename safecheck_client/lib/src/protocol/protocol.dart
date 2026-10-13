/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:safecheck_client/src/protocol/alerts/alert_message.dart'
    as _inhs2hqy;
import 'package:safecheck_client/src/protocol/alerts/safety_alert.dart'
    as _ipl1wex2;
import 'package:safecheck_client/src/protocol/contacts/trusted_contact.dart'
    as _ihgbcfsn;
import 'package:safecheck_client/src/protocol/tracking/location_point.dart'
    as _if9xc140;
import 'package:safecheck_client/src/protocol/tracking/tracking_link_info.dart'
    as _iw00f363;
import 'package:safecheck_client/src/protocol/tracking/trip_location.dart'
    as _iulcqs4y;
import 'package:safecheck_client/src/protocol/trips/trip.dart' as _i4r1fixk;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'alerts/alert_message.dart' as _isas3mld;
import 'alerts/safety_alert.dart' as _i79al053;
import 'common/safecheck_exception.dart' as _iontdvzq;
import 'contacts/contact_invite.dart' as _i3noworj;
import 'contacts/contact_opt_in_status.dart' as _iz3pr2uv;
import 'contacts/trusted_contact.dart' as _ixhyrlmy;
import 'messaging/message_channel.dart' as _i9p5tz3d;
import 'messaging/message_status.dart' as _i5yj6jmy;
import 'profile/user_profile.dart' as _ik2xsncp;
import 'tracking/location_point.dart' as _irmr9nnk;
import 'tracking/location_sharing.dart' as _idx5cm0c;
import 'tracking/tracking_link.dart' as _idf2vf11;
import 'tracking/tracking_link_info.dart' as _ij184lk4;
import 'tracking/trip_location.dart' as _igycq0nv;
import 'trips/contact_snapshot.dart' as _ie7zf2se;
import 'trips/trip.dart' as _i2i2066w;
import 'trips/trip_snapshot.dart' as _i7v6k0fj;
import 'trips/trip_status.dart' as _ind0qj5m;
import 'trips/trip_type.dart' as _ie9y6u8r;
export 'alerts/alert_message.dart';
export 'alerts/safety_alert.dart';
export 'common/safecheck_exception.dart';
export 'contacts/contact_invite.dart';
export 'contacts/contact_opt_in_status.dart';
export 'contacts/trusted_contact.dart';
export 'messaging/message_channel.dart';
export 'messaging/message_status.dart';
export 'profile/user_profile.dart';
export 'tracking/location_point.dart';
export 'tracking/location_sharing.dart';
export 'tracking/tracking_link.dart';
export 'tracking/tracking_link_info.dart';
export 'tracking/trip_location.dart';
export 'trips/contact_snapshot.dart';
export 'trips/trip.dart';
export 'trips/trip_snapshot.dart';
export 'trips/trip_status.dart';
export 'trips/trip_type.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _isas3mld.AlertMessage) {
      return _isas3mld.AlertMessage.fromJson(data) as T;
    }
    if (t == _i79al053.SafetyAlert) {
      return _i79al053.SafetyAlert.fromJson(data) as T;
    }
    if (t == _iontdvzq.SafeCheckException) {
      return _iontdvzq.SafeCheckException.fromJson(data) as T;
    }
    if (t == _i3noworj.ContactInvite) {
      return _i3noworj.ContactInvite.fromJson(data) as T;
    }
    if (t == _iz3pr2uv.ContactOptInStatus) {
      return _iz3pr2uv.ContactOptInStatus.fromJson(data) as T;
    }
    if (t == _ixhyrlmy.TrustedContact) {
      return _ixhyrlmy.TrustedContact.fromJson(data) as T;
    }
    if (t == _i9p5tz3d.MessageChannel) {
      return _i9p5tz3d.MessageChannel.fromJson(data) as T;
    }
    if (t == _i5yj6jmy.MessageStatus) {
      return _i5yj6jmy.MessageStatus.fromJson(data) as T;
    }
    if (t == _ik2xsncp.UserProfile) {
      return _ik2xsncp.UserProfile.fromJson(data) as T;
    }
    if (t == _irmr9nnk.LocationPoint) {
      return _irmr9nnk.LocationPoint.fromJson(data) as T;
    }
    if (t == _idx5cm0c.LocationSharing) {
      return _idx5cm0c.LocationSharing.fromJson(data) as T;
    }
    if (t == _idf2vf11.TrackingLink) {
      return _idf2vf11.TrackingLink.fromJson(data) as T;
    }
    if (t == _ij184lk4.TrackingLinkInfo) {
      return _ij184lk4.TrackingLinkInfo.fromJson(data) as T;
    }
    if (t == _igycq0nv.TripLocation) {
      return _igycq0nv.TripLocation.fromJson(data) as T;
    }
    if (t == _ie7zf2se.ContactSnapshot) {
      return _ie7zf2se.ContactSnapshot.fromJson(data) as T;
    }
    if (t == _i2i2066w.Trip) {
      return _i2i2066w.Trip.fromJson(data) as T;
    }
    if (t == _i7v6k0fj.TripSnapshot) {
      return _i7v6k0fj.TripSnapshot.fromJson(data) as T;
    }
    if (t == _ind0qj5m.TripStatus) {
      return _ind0qj5m.TripStatus.fromJson(data) as T;
    }
    if (t == _ie9y6u8r.TripType) {
      return _ie9y6u8r.TripType.fromJson(data) as T;
    }
    if (t == _isc.getType<_isas3mld.AlertMessage?>()) {
      return (data != null ? _isas3mld.AlertMessage.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i79al053.SafetyAlert?>()) {
      return (data != null ? _i79al053.SafetyAlert.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iontdvzq.SafeCheckException?>()) {
      return (data != null ? _iontdvzq.SafeCheckException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i3noworj.ContactInvite?>()) {
      return (data != null ? _i3noworj.ContactInvite.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iz3pr2uv.ContactOptInStatus?>()) {
      return (data != null ? _iz3pr2uv.ContactOptInStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixhyrlmy.TrustedContact?>()) {
      return (data != null ? _ixhyrlmy.TrustedContact.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i9p5tz3d.MessageChannel?>()) {
      return (data != null ? _i9p5tz3d.MessageChannel.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i5yj6jmy.MessageStatus?>()) {
      return (data != null ? _i5yj6jmy.MessageStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ik2xsncp.UserProfile?>()) {
      return (data != null ? _ik2xsncp.UserProfile.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_irmr9nnk.LocationPoint?>()) {
      return (data != null ? _irmr9nnk.LocationPoint.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idx5cm0c.LocationSharing?>()) {
      return (data != null ? _idx5cm0c.LocationSharing.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idf2vf11.TrackingLink?>()) {
      return (data != null ? _idf2vf11.TrackingLink.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ij184lk4.TrackingLinkInfo?>()) {
      return (data != null ? _ij184lk4.TrackingLinkInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_igycq0nv.TripLocation?>()) {
      return (data != null ? _igycq0nv.TripLocation.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ie7zf2se.ContactSnapshot?>()) {
      return (data != null ? _ie7zf2se.ContactSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i2i2066w.Trip?>()) {
      return (data != null ? _i2i2066w.Trip.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i7v6k0fj.TripSnapshot?>()) {
      return (data != null ? _i7v6k0fj.TripSnapshot.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ind0qj5m.TripStatus?>()) {
      return (data != null ? _ind0qj5m.TripStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ie9y6u8r.TripType?>()) {
      return (data != null ? _ie9y6u8r.TripType.fromJson(data) : null) as T;
    }
    if (t == List<_ie7zf2se.ContactSnapshot>) {
      return (data as List)
              .map((e) => deserialize<_ie7zf2se.ContactSnapshot>(e))
              .toList()
          as T;
    }
    if (t == List<_ipl1wex2.SafetyAlert>) {
      return (data as List)
              .map((e) => deserialize<_ipl1wex2.SafetyAlert>(e))
              .toList()
          as T;
    }
    if (t == List<_inhs2hqy.AlertMessage>) {
      return (data as List)
              .map((e) => deserialize<_inhs2hqy.AlertMessage>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<_ihgbcfsn.TrustedContact>) {
      return (data as List)
              .map((e) => deserialize<_ihgbcfsn.TrustedContact>(e))
              .toList()
          as T;
    }
    if (t == List<_if9xc140.LocationPoint>) {
      return (data as List)
              .map((e) => deserialize<_if9xc140.LocationPoint>(e))
              .toList()
          as T;
    }
    if (t == List<_iulcqs4y.TripLocation>) {
      return (data as List)
              .map((e) => deserialize<_iulcqs4y.TripLocation>(e))
              .toList()
          as T;
    }
    if (t == List<_i4r1fixk.Trip>) {
      return (data as List).map((e) => deserialize<_i4r1fixk.Trip>(e)).toList()
          as T;
    }
    if (t == List<_iw00f363.TrackingLinkInfo>) {
      return (data as List)
              .map((e) => deserialize<_iw00f363.TrackingLinkInfo>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _isas3mld.AlertMessage => 'AlertMessage',
      _i79al053.SafetyAlert => 'SafetyAlert',
      _iontdvzq.SafeCheckException => 'SafeCheckException',
      _i3noworj.ContactInvite => 'ContactInvite',
      _iz3pr2uv.ContactOptInStatus => 'ContactOptInStatus',
      _ixhyrlmy.TrustedContact => 'TrustedContact',
      _i9p5tz3d.MessageChannel => 'MessageChannel',
      _i5yj6jmy.MessageStatus => 'MessageStatus',
      _ik2xsncp.UserProfile => 'UserProfile',
      _irmr9nnk.LocationPoint => 'LocationPoint',
      _idx5cm0c.LocationSharing => 'LocationSharing',
      _idf2vf11.TrackingLink => 'TrackingLink',
      _ij184lk4.TrackingLinkInfo => 'TrackingLinkInfo',
      _igycq0nv.TripLocation => 'TripLocation',
      _ie7zf2se.ContactSnapshot => 'ContactSnapshot',
      _i2i2066w.Trip => 'Trip',
      _i7v6k0fj.TripSnapshot => 'TripSnapshot',
      _ind0qj5m.TripStatus => 'TripStatus',
      _ie9y6u8r.TripType => 'TripType',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('safecheck.', '');
    }

    switch (data) {
      case _isas3mld.AlertMessage():
        return 'AlertMessage';
      case _i79al053.SafetyAlert():
        return 'SafetyAlert';
      case _iontdvzq.SafeCheckException():
        return 'SafeCheckException';
      case _i3noworj.ContactInvite():
        return 'ContactInvite';
      case _iz3pr2uv.ContactOptInStatus():
        return 'ContactOptInStatus';
      case _ixhyrlmy.TrustedContact():
        return 'TrustedContact';
      case _i9p5tz3d.MessageChannel():
        return 'MessageChannel';
      case _i5yj6jmy.MessageStatus():
        return 'MessageStatus';
      case _ik2xsncp.UserProfile():
        return 'UserProfile';
      case _irmr9nnk.LocationPoint():
        return 'LocationPoint';
      case _idx5cm0c.LocationSharing():
        return 'LocationSharing';
      case _idf2vf11.TrackingLink():
        return 'TrackingLink';
      case _ij184lk4.TrackingLinkInfo():
        return 'TrackingLinkInfo';
      case _igycq0nv.TripLocation():
        return 'TripLocation';
      case _ie7zf2se.ContactSnapshot():
        return 'ContactSnapshot';
      case _i2i2066w.Trip():
        return 'Trip';
      case _i7v6k0fj.TripSnapshot():
        return 'TripSnapshot';
      case _ind0qj5m.TripStatus():
        return 'TripStatus';
      case _ie9y6u8r.TripType():
        return 'TripType';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AlertMessage') {
      return deserialize<_isas3mld.AlertMessage>(data['data']);
    }
    if (dataClassName == 'SafetyAlert') {
      return deserialize<_i79al053.SafetyAlert>(data['data']);
    }
    if (dataClassName == 'SafeCheckException') {
      return deserialize<_iontdvzq.SafeCheckException>(data['data']);
    }
    if (dataClassName == 'ContactInvite') {
      return deserialize<_i3noworj.ContactInvite>(data['data']);
    }
    if (dataClassName == 'ContactOptInStatus') {
      return deserialize<_iz3pr2uv.ContactOptInStatus>(data['data']);
    }
    if (dataClassName == 'TrustedContact') {
      return deserialize<_ixhyrlmy.TrustedContact>(data['data']);
    }
    if (dataClassName == 'MessageChannel') {
      return deserialize<_i9p5tz3d.MessageChannel>(data['data']);
    }
    if (dataClassName == 'MessageStatus') {
      return deserialize<_i5yj6jmy.MessageStatus>(data['data']);
    }
    if (dataClassName == 'UserProfile') {
      return deserialize<_ik2xsncp.UserProfile>(data['data']);
    }
    if (dataClassName == 'LocationPoint') {
      return deserialize<_irmr9nnk.LocationPoint>(data['data']);
    }
    if (dataClassName == 'LocationSharing') {
      return deserialize<_idx5cm0c.LocationSharing>(data['data']);
    }
    if (dataClassName == 'TrackingLink') {
      return deserialize<_idf2vf11.TrackingLink>(data['data']);
    }
    if (dataClassName == 'TrackingLinkInfo') {
      return deserialize<_ij184lk4.TrackingLinkInfo>(data['data']);
    }
    if (dataClassName == 'TripLocation') {
      return deserialize<_igycq0nv.TripLocation>(data['data']);
    }
    if (dataClassName == 'ContactSnapshot') {
      return deserialize<_ie7zf2se.ContactSnapshot>(data['data']);
    }
    if (dataClassName == 'Trip') {
      return deserialize<_i2i2066w.Trip>(data['data']);
    }
    if (dataClassName == 'TripSnapshot') {
      return deserialize<_i7v6k0fj.TripSnapshot>(data['data']);
    }
    if (dataClassName == 'TripStatus') {
      return deserialize<_ind0qj5m.TripStatus>(data['data']);
    }
    if (dataClassName == 'TripType') {
      return deserialize<_ie9y6u8r.TripType>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('safecheck', this);
    _iacc.Protocol().registerHostProtocol('safecheck', this);
  }

  @override
  String getModuleName() => 'safecheck';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
