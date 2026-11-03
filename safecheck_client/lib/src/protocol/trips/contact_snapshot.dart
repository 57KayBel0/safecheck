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

/// A copy of a trusted contact taken when a trip starts, so later edits to
/// the contact list do not change who a trip's alert is addressed to.
abstract class ContactSnapshot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ContactSnapshot._({
    required this.name,
    bool? canResolveIncident,
    required this.phoneNumber,
    this.relationship,
    this.optedIn,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) : canResolveIncident = canResolveIncident ?? false,
       notifyByWhatsapp = notifyByWhatsapp ?? true,
       notifyBySms = notifyBySms ?? true;

  factory ContactSnapshot({
    required String name,
    bool? canResolveIncident,
    required String phoneNumber,
    String? relationship,
    bool? optedIn,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) = _ContactSnapshotImpl;

  factory ContactSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return ContactSnapshot(
      name: jsonSerialization['name'] as String,
      canResolveIncident: jsonSerialization['canResolveIncident'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['canResolveIncident'],
            ),
      phoneNumber: jsonSerialization['phoneNumber'] as String,
      relationship: jsonSerialization['relationship'] as String?,
      optedIn: jsonSerialization['optedIn'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['optedIn']),
      notifyByWhatsapp: jsonSerialization['notifyByWhatsapp'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['notifyByWhatsapp'],
            ),
      notifyBySms: jsonSerialization['notifyBySms'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['notifyBySms']),
    );
  }

  String name;

  bool canResolveIncident;

  String phoneNumber;

  String? relationship;

  /// Whether the contact had accepted their invite when the trip started.
  /// Null for trips started before invites existed.
  bool? optedIn;

  /// Whether WhatsApp alerts were enabled when the trip started.
  bool notifyByWhatsapp;

  /// Whether SMS fallback alerts were enabled when the trip started.
  bool notifyBySms;

  /// Returns a shallow copy of this [ContactSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ContactSnapshot copyWith({
    String? name,
    bool? canResolveIncident,
    String? phoneNumber,
    String? relationship,
    bool? optedIn,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ContactSnapshot',
      'name': name,
      'canResolveIncident': canResolveIncident,
      'phoneNumber': phoneNumber,
      if (relationship != null) 'relationship': relationship,
      if (optedIn != null) 'optedIn': optedIn,
      'notifyByWhatsapp': notifyByWhatsapp,
      'notifyBySms': notifyBySms,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ContactSnapshot',
      'name': name,
      'canResolveIncident': canResolveIncident,
      'phoneNumber': phoneNumber,
      if (relationship != null) 'relationship': relationship,
      if (optedIn != null) 'optedIn': optedIn,
      'notifyByWhatsapp': notifyByWhatsapp,
      'notifyBySms': notifyBySms,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContactSnapshotImpl extends ContactSnapshot {
  _ContactSnapshotImpl({
    required String name,
    bool? canResolveIncident,
    required String phoneNumber,
    String? relationship,
    bool? optedIn,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) : super._(
         name: name,
         canResolveIncident: canResolveIncident,
         phoneNumber: phoneNumber,
         relationship: relationship,
         optedIn: optedIn,
         notifyByWhatsapp: notifyByWhatsapp,
         notifyBySms: notifyBySms,
       );

  /// Returns a shallow copy of this [ContactSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ContactSnapshot copyWith({
    String? name,
    bool? canResolveIncident,
    String? phoneNumber,
    Object? relationship = _Undefined,
    Object? optedIn = _Undefined,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) {
    return ContactSnapshot(
      name: name ?? this.name,
      canResolveIncident: canResolveIncident ?? this.canResolveIncident,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship is String? ? relationship : this.relationship,
      optedIn: optedIn is bool? ? optedIn : this.optedIn,
      notifyByWhatsapp: notifyByWhatsapp ?? this.notifyByWhatsapp,
      notifyBySms: notifyBySms ?? this.notifyBySms,
    );
  }
}
