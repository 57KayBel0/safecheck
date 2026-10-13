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

/// One GPS fix reported by the traveller's phone during a trip.
abstract class TripLocation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TripLocation._({
    this.id,
    required this.ownerId,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.recordedAt,
    required this.receivedAt,
  });

  factory TripLocation({
    int? id,
    required String ownerId,
    required int tripId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    required DateTime recordedAt,
    required DateTime receivedAt,
  }) = _TripLocationImpl;

  factory TripLocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return TripLocation(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      tripId: jsonSerialization['tripId'] as int,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      accuracyMeters: (jsonSerialization['accuracyMeters'] as num?)?.toDouble(),
      recordedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['recordedAt'],
      ),
      receivedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The auth user identifier (UUID) of the traveller.
  String ownerId;

  int tripId;

  double latitude;

  double longitude;

  /// Horizontal accuracy radius in metres, if the device reported one.
  double? accuracyMeters;

  /// When the device took the fix.
  DateTime recordedAt;

  /// When the server stored it.
  DateTime receivedAt;

  /// Returns a shallow copy of this [TripLocation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TripLocation copyWith({
    int? id,
    String? ownerId,
    int? tripId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    DateTime? recordedAt,
    DateTime? receivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TripLocation',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripId': tripId,
      'latitude': latitude,
      'longitude': longitude,
      if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
      'recordedAt': recordedAt.toJson(),
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TripLocation',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripId': tripId,
      'latitude': latitude,
      'longitude': longitude,
      if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
      'recordedAt': recordedAt.toJson(),
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TripLocationImpl extends TripLocation {
  _TripLocationImpl({
    int? id,
    required String ownerId,
    required int tripId,
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    required DateTime recordedAt,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         ownerId: ownerId,
         tripId: tripId,
         latitude: latitude,
         longitude: longitude,
         accuracyMeters: accuracyMeters,
         recordedAt: recordedAt,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [TripLocation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TripLocation copyWith({
    Object? id = _Undefined,
    String? ownerId,
    int? tripId,
    double? latitude,
    double? longitude,
    Object? accuracyMeters = _Undefined,
    DateTime? recordedAt,
    DateTime? receivedAt,
  }) {
    return TripLocation(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      tripId: tripId ?? this.tripId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters is double?
          ? accuracyMeters
          : this.accuracyMeters,
      recordedAt: recordedAt ?? this.recordedAt,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
