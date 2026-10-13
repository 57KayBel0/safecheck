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
import 'package:safecheck_client/src/protocol/protocol.dart' as _iusok08q;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../tracking/location_sharing.dart' as _ixmrytkl;
import '../trips/contact_snapshot.dart' as _i0udr1y1;
import '../trips/trip_status.dart' as _i7iygem4;
import '../trips/trip_type.dart' as _ix6rm8oc;

/// A trip with a check-in deadline.
abstract class Trip
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Trip._({
    this.id,
    required this.ownerId,
    required this.tripType,
    required this.description,
    required this.durationMinutes,
    required this.startedAt,
    required this.deadline,
    required this.status,
    this.endedAt,
    required this.contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  }) : locationSharing = locationSharing ?? _ixmrytkl.LocationSharing.off;

  factory Trip({
    int? id,
    required String ownerId,
    required _ix6rm8oc.TripType tripType,
    required String description,
    required int durationMinutes,
    required DateTime startedAt,
    required DateTime deadline,
    required _i7iygem4.TripStatus status,
    DateTime? endedAt,
    required List<_i0udr1y1.ContactSnapshot> contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  }) = _TripImpl;

  factory Trip.fromJson(Map<String, dynamic> jsonSerialization) {
    return Trip(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      tripType: _ix6rm8oc.TripType.fromJson(
        (jsonSerialization['tripType'] as String),
      ),
      description: jsonSerialization['description'] as String,
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      startedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      deadline: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['deadline'],
      ),
      status: _i7iygem4.TripStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      contacts: _iusok08q.Protocol()
          .deserialize<List<_i0udr1y1.ContactSnapshot>>(
            jsonSerialization['contacts'],
          ),
      locationSharing: jsonSerialization['locationSharing'] == null
          ? null
          : _ixmrytkl.LocationSharing.fromJson(
              (jsonSerialization['locationSharing'] as String),
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The auth user identifier (UUID) of the owner.
  String ownerId;

  _ix6rm8oc.TripType tripType;

  String description;

  int durationMinutes;

  DateTime startedAt;

  /// Server-computed time by which the owner must check in.
  DateTime deadline;

  _i7iygem4.TripStatus status;

  /// When the trip ended (check-in or missed deadline processed).
  DateTime? endedAt;

  /// Trusted contacts as they were when the trip started.
  List<_i0udr1y1.ContactSnapshot> contacts;

  /// Who may see this trip's location. Chosen when the trip starts.
  _ixmrytkl.LocationSharing locationSharing;

  /// Returns a shallow copy of this [Trip]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Trip copyWith({
    int? id,
    String? ownerId,
    _ix6rm8oc.TripType? tripType,
    String? description,
    int? durationMinutes,
    DateTime? startedAt,
    DateTime? deadline,
    _i7iygem4.TripStatus? status,
    DateTime? endedAt,
    List<_i0udr1y1.ContactSnapshot>? contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Trip',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripType': tripType.toJson(),
      'description': description,
      'durationMinutes': durationMinutes,
      'startedAt': startedAt.toJson(),
      'deadline': deadline.toJson(),
      'status': status.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJson()),
      'locationSharing': locationSharing.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Trip',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripType': tripType.toJson(),
      'description': description,
      'durationMinutes': durationMinutes,
      'startedAt': startedAt.toJson(),
      'deadline': deadline.toJson(),
      'status': status.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'locationSharing': locationSharing.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TripImpl extends Trip {
  _TripImpl({
    int? id,
    required String ownerId,
    required _ix6rm8oc.TripType tripType,
    required String description,
    required int durationMinutes,
    required DateTime startedAt,
    required DateTime deadline,
    required _i7iygem4.TripStatus status,
    DateTime? endedAt,
    required List<_i0udr1y1.ContactSnapshot> contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  }) : super._(
         id: id,
         ownerId: ownerId,
         tripType: tripType,
         description: description,
         durationMinutes: durationMinutes,
         startedAt: startedAt,
         deadline: deadline,
         status: status,
         endedAt: endedAt,
         contacts: contacts,
         locationSharing: locationSharing,
       );

  /// Returns a shallow copy of this [Trip]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Trip copyWith({
    Object? id = _Undefined,
    String? ownerId,
    _ix6rm8oc.TripType? tripType,
    String? description,
    int? durationMinutes,
    DateTime? startedAt,
    DateTime? deadline,
    _i7iygem4.TripStatus? status,
    Object? endedAt = _Undefined,
    List<_i0udr1y1.ContactSnapshot>? contacts,
    _ixmrytkl.LocationSharing? locationSharing,
  }) {
    return Trip(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      tripType: tripType ?? this.tripType,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startedAt: startedAt ?? this.startedAt,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
      contacts: contacts ?? this.contacts.map((e0) => e0.copyWith()).toList(),
      locationSharing: locationSharing ?? this.locationSharing,
    );
  }
}
