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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A contact's tracking link as shown to the trip owner, so they can share
/// it themselves.
abstract class TrackingLinkInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TrackingLinkInfo._({
    required this.contactName,
    required this.contactPhone,
    required this.url,
  });

  factory TrackingLinkInfo({
    required String contactName,
    required String contactPhone,
    required String url,
  }) = _TrackingLinkInfoImpl;

  factory TrackingLinkInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return TrackingLinkInfo(
      contactName: jsonSerialization['contactName'] as String,
      contactPhone: jsonSerialization['contactPhone'] as String,
      url: jsonSerialization['url'] as String,
    );
  }

  String contactName;

  String contactPhone;

  String url;

  /// Returns a shallow copy of this [TrackingLinkInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TrackingLinkInfo copyWith({
    String? contactName,
    String? contactPhone,
    String? url,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TrackingLinkInfo',
      'contactName': contactName,
      'contactPhone': contactPhone,
      'url': url,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TrackingLinkInfo',
      'contactName': contactName,
      'contactPhone': contactPhone,
      'url': url,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TrackingLinkInfoImpl extends TrackingLinkInfo {
  _TrackingLinkInfoImpl({
    required String contactName,
    required String contactPhone,
    required String url,
  }) : super._(
         contactName: contactName,
         contactPhone: contactPhone,
         url: url,
       );

  /// Returns a shallow copy of this [TrackingLinkInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TrackingLinkInfo copyWith({
    String? contactName,
    String? contactPhone,
    String? url,
  }) {
    return TrackingLinkInfo(
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      url: url ?? this.url,
    );
  }
}
