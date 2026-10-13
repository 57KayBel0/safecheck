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
import 'package:serverpod/serverpod.dart' as _is;

/// A GPS fix sent by the app. Validated before it becomes a [TripLocation].
abstract class LocationPoint
    implements _is.SerializableModel, _is.ProtocolSerialization {
  LocationPoint._({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    required this.recordedAt,
  });

  factory LocationPoint({
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    required DateTime recordedAt,
  }) = _LocationPointImpl;

  factory LocationPoint.fromJson(Map<String, dynamic> jsonSerialization) {
    return LocationPoint(
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      accuracyMeters: (jsonSerialization['accuracyMeters'] as num?)?.toDouble(),
      recordedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['recordedAt'],
      ),
    );
  }

  double latitude;

  double longitude;

  double? accuracyMeters;

  DateTime recordedAt;

  /// Returns a shallow copy of this [LocationPoint]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LocationPoint copyWith({
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    DateTime? recordedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LocationPoint',
      'latitude': latitude,
      'longitude': longitude,
      if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
      'recordedAt': recordedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LocationPoint',
      'latitude': latitude,
      'longitude': longitude,
      if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
      'recordedAt': recordedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LocationPointImpl extends LocationPoint {
  _LocationPointImpl({
    required double latitude,
    required double longitude,
    double? accuracyMeters,
    required DateTime recordedAt,
  }) : super._(
         latitude: latitude,
         longitude: longitude,
         accuracyMeters: accuracyMeters,
         recordedAt: recordedAt,
       );

  /// Returns a shallow copy of this [LocationPoint]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LocationPoint copyWith({
    double? latitude,
    double? longitude,
    Object? accuracyMeters = _Undefined,
    DateTime? recordedAt,
  }) {
    return LocationPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters is double?
          ? accuracyMeters
          : this.accuracyMeters,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
