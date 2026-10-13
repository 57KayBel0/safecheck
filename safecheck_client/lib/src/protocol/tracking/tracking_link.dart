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

/// A secret per-contact link to a trip's location page. Created when a trip
/// starts with location sharing on. Whether it currently shows a location
/// depends on the trip's sharing mode and state (see TrackingService).
abstract class TrackingLink
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TrackingLink._({
    this.id,
    required this.token,
    required this.ownerId,
    required this.tripId,
    required this.contactName,
    required this.contactPhone,
    required this.createdAt,
  });

  factory TrackingLink({
    int? id,
    required String token,
    required String ownerId,
    required int tripId,
    required String contactName,
    required String contactPhone,
    required DateTime createdAt,
  }) = _TrackingLinkImpl;

  factory TrackingLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return TrackingLink(
      id: jsonSerialization['id'] as int?,
      token: jsonSerialization['token'] as String,
      ownerId: jsonSerialization['ownerId'] as String,
      tripId: jsonSerialization['tripId'] as int,
      contactName: jsonSerialization['contactName'] as String,
      contactPhone: jsonSerialization['contactPhone'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Unguessable token in the URL. No endpoint returns this model; the
  /// owner only receives the share URL through [TrackingLinkInfo].
  String token;

  String ownerId;

  int tripId;

  String contactName;

  String contactPhone;

  DateTime createdAt;

  /// Returns a shallow copy of this [TrackingLink]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TrackingLink copyWith({
    int? id,
    String? token,
    String? ownerId,
    int? tripId,
    String? contactName,
    String? contactPhone,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TrackingLink',
      if (id != null) 'id': id,
      'token': token,
      'ownerId': ownerId,
      'tripId': tripId,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TrackingLink',
      if (id != null) 'id': id,
      'token': token,
      'ownerId': ownerId,
      'tripId': tripId,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TrackingLinkImpl extends TrackingLink {
  _TrackingLinkImpl({
    int? id,
    required String token,
    required String ownerId,
    required int tripId,
    required String contactName,
    required String contactPhone,
    required DateTime createdAt,
  }) : super._(
         id: id,
         token: token,
         ownerId: ownerId,
         tripId: tripId,
         contactName: contactName,
         contactPhone: contactPhone,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TrackingLink]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TrackingLink copyWith({
    Object? id = _Undefined,
    String? token,
    String? ownerId,
    int? tripId,
    String? contactName,
    String? contactPhone,
    DateTime? createdAt,
  }) {
    return TrackingLink(
      id: id is int? ? id : this.id,
      token: token ?? this.token,
      ownerId: ownerId ?? this.ownerId,
      tripId: tripId ?? this.tripId,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
