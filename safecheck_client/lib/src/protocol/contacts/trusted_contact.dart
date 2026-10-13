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
import '../contacts/contact_opt_in_status.dart' as _ilcrz8k8;

/// A person who should be alerted when the owner misses a check-in.
/// A user can have at most five trusted contacts.
abstract class TrustedContact
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TrustedContact._({
    this.id,
    required this.ownerId,
    required this.name,
    required this.phoneNumber,
    this.relationship,
    required this.createdAt,
    required this.updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    this.optInRespondedAt,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) : optInStatus = optInStatus ?? _ilcrz8k8.ContactOptInStatus.pending,
       notifyByWhatsapp = notifyByWhatsapp ?? true,
       notifyBySms = notifyBySms ?? true;

  factory TrustedContact({
    int? id,
    required String ownerId,
    required String name,
    required String phoneNumber,
    String? relationship,
    required DateTime createdAt,
    required DateTime updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    DateTime? optInRespondedAt,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) = _TrustedContactImpl;

  factory TrustedContact.fromJson(Map<String, dynamic> jsonSerialization) {
    return TrustedContact(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      name: jsonSerialization['name'] as String,
      phoneNumber: jsonSerialization['phoneNumber'] as String,
      relationship: jsonSerialization['relationship'] as String?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      optInStatus: jsonSerialization['optInStatus'] == null
          ? null
          : _ilcrz8k8.ContactOptInStatus.fromJson(
              (jsonSerialization['optInStatus'] as String),
            ),
      optInRespondedAt: jsonSerialization['optInRespondedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['optInRespondedAt'],
            ),
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The auth user identifier (UUID) of the owner.
  String ownerId;

  String name;

  /// South African phone number in E.164 format (+27...).
  String phoneNumber;

  /// Optional relationship, e.g. "Sister" or "Housemate".
  String? relationship;

  DateTime createdAt;

  DateTime updatedAt;

  /// The contact's answer to their invite. Reset to `pending` when the phone
  /// number changes, because the number may belong to someone else.
  _ilcrz8k8.ContactOptInStatus optInStatus;

  /// When the contact accepted or declined.
  DateTime? optInRespondedAt;

  /// Whether this contact prefers WhatsApp alerts.
  bool notifyByWhatsapp;

  /// Whether SMS should be used as a fallback or alternate alert channel.
  bool notifyBySms;

  /// Returns a shallow copy of this [TrustedContact]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TrustedContact copyWith({
    int? id,
    String? ownerId,
    String? name,
    String? phoneNumber,
    String? relationship,
    DateTime? createdAt,
    DateTime? updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    DateTime? optInRespondedAt,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TrustedContact',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'name': name,
      'phoneNumber': phoneNumber,
      if (relationship != null) 'relationship': relationship,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'optInStatus': optInStatus.toJson(),
      if (optInRespondedAt != null)
        'optInRespondedAt': optInRespondedAt?.toJson(),
      'notifyByWhatsapp': notifyByWhatsapp,
      'notifyBySms': notifyBySms,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TrustedContact',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'name': name,
      'phoneNumber': phoneNumber,
      if (relationship != null) 'relationship': relationship,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'optInStatus': optInStatus.toJson(),
      if (optInRespondedAt != null)
        'optInRespondedAt': optInRespondedAt?.toJson(),
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

class _TrustedContactImpl extends TrustedContact {
  _TrustedContactImpl({
    int? id,
    required String ownerId,
    required String name,
    required String phoneNumber,
    String? relationship,
    required DateTime createdAt,
    required DateTime updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    DateTime? optInRespondedAt,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) : super._(
         id: id,
         ownerId: ownerId,
         name: name,
         phoneNumber: phoneNumber,
         relationship: relationship,
         createdAt: createdAt,
         updatedAt: updatedAt,
         optInStatus: optInStatus,
         optInRespondedAt: optInRespondedAt,
         notifyByWhatsapp: notifyByWhatsapp,
         notifyBySms: notifyBySms,
       );

  /// Returns a shallow copy of this [TrustedContact]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TrustedContact copyWith({
    Object? id = _Undefined,
    String? ownerId,
    String? name,
    String? phoneNumber,
    Object? relationship = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    _ilcrz8k8.ContactOptInStatus? optInStatus,
    Object? optInRespondedAt = _Undefined,
    bool? notifyByWhatsapp,
    bool? notifyBySms,
  }) {
    return TrustedContact(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship is String? ? relationship : this.relationship,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      optInStatus: optInStatus ?? this.optInStatus,
      optInRespondedAt: optInRespondedAt is DateTime?
          ? optInRespondedAt
          : this.optInRespondedAt,
      notifyByWhatsapp: notifyByWhatsapp ?? this.notifyByWhatsapp,
      notifyBySms: notifyBySms ?? this.notifyBySms,
    );
  }
}
