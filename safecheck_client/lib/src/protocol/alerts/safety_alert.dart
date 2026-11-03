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
import '../companion/alert_reason.dart' as _ijoowf6j;
import '../companion/brief_status.dart' as _i531ttm8;
import '../companion/incident_brief.dart' as _i2a7cxt8;
import '../trips/contact_snapshot.dart' as _i0udr1y1;
import '../trips/trip_type.dart' as _ix6rm8oc;

/// Created by the server when a trip's deadline passes without a check-in.
/// At most one alert exists per trip.
abstract class SafetyAlert
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SafetyAlert._({
    this.id,
    required this.ownerId,
    required this.tripId,
    required this.travellerName,
    required this.travellerPhone,
    required this.tripType,
    required this.tripDescription,
    required this.deadline,
    required this.createdAt,
    required this.contacts,
    _ijoowf6j.AlertReason? reason,
    this.brief,
    _i531ttm8.BriefStatus? briefStatus,
    this.briefAttemptedAt,
    this.resolvedAt,
    this.resolutionActor,
    this.resolutionNote,
  }) : reason = reason ?? _ijoowf6j.AlertReason.missedCheckIn,
       briefStatus = briefStatus ?? _i531ttm8.BriefStatus.fallback;

  factory SafetyAlert({
    int? id,
    required String ownerId,
    required int tripId,
    required String travellerName,
    required String travellerPhone,
    required _ix6rm8oc.TripType tripType,
    required String tripDescription,
    required DateTime deadline,
    required DateTime createdAt,
    required List<_i0udr1y1.ContactSnapshot> contacts,
    _ijoowf6j.AlertReason? reason,
    _i2a7cxt8.IncidentBrief? brief,
    _i531ttm8.BriefStatus? briefStatus,
    DateTime? briefAttemptedAt,
    DateTime? resolvedAt,
    String? resolutionActor,
    String? resolutionNote,
  }) = _SafetyAlertImpl;

  factory SafetyAlert.fromJson(Map<String, dynamic> jsonSerialization) {
    return SafetyAlert(
      id: jsonSerialization['id'] as int?,
      ownerId: jsonSerialization['ownerId'] as String,
      tripId: jsonSerialization['tripId'] as int,
      travellerName: jsonSerialization['travellerName'] as String,
      travellerPhone: jsonSerialization['travellerPhone'] as String,
      tripType: _ix6rm8oc.TripType.fromJson(
        (jsonSerialization['tripType'] as String),
      ),
      tripDescription: jsonSerialization['tripDescription'] as String,
      deadline: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['deadline'],
      ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      contacts: _iusok08q.Protocol()
          .deserialize<List<_i0udr1y1.ContactSnapshot>>(
            jsonSerialization['contacts'],
          ),
      reason: jsonSerialization['reason'] == null
          ? null
          : _ijoowf6j.AlertReason.fromJson(
              (jsonSerialization['reason'] as String),
            ),
      brief: jsonSerialization['brief'] == null
          ? null
          : _iusok08q.Protocol().deserialize<_i2a7cxt8.IncidentBrief>(
              jsonSerialization['brief'],
            ),
      briefStatus: jsonSerialization['briefStatus'] == null
          ? null
          : _i531ttm8.BriefStatus.fromJson(
              (jsonSerialization['briefStatus'] as String),
            ),
      briefAttemptedAt: jsonSerialization['briefAttemptedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['briefAttemptedAt'],
            ),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resolvedAt'],
            ),
      resolutionActor: jsonSerialization['resolutionActor'] as String?,
      resolutionNote: jsonSerialization['resolutionNote'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The auth user identifier (UUID) of the traveller.
  String ownerId;

  int tripId;

  String travellerName;

  String travellerPhone;

  _ix6rm8oc.TripType tripType;

  String tripDescription;

  DateTime deadline;

  DateTime createdAt;

  /// Contacts the alert is addressed to, copied from the trip.
  List<_i0udr1y1.ContactSnapshot> contacts;

  _ijoowf6j.AlertReason reason;

  _i2a7cxt8.IncidentBrief? brief;

  _i531ttm8.BriefStatus briefStatus;

  DateTime? briefAttemptedAt;

  DateTime? resolvedAt;

  String? resolutionActor;

  String? resolutionNote;

  /// Returns a shallow copy of this [SafetyAlert]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SafetyAlert copyWith({
    int? id,
    String? ownerId,
    int? tripId,
    String? travellerName,
    String? travellerPhone,
    _ix6rm8oc.TripType? tripType,
    String? tripDescription,
    DateTime? deadline,
    DateTime? createdAt,
    List<_i0udr1y1.ContactSnapshot>? contacts,
    _ijoowf6j.AlertReason? reason,
    _i2a7cxt8.IncidentBrief? brief,
    _i531ttm8.BriefStatus? briefStatus,
    DateTime? briefAttemptedAt,
    DateTime? resolvedAt,
    String? resolutionActor,
    String? resolutionNote,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SafetyAlert',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripId': tripId,
      'travellerName': travellerName,
      'travellerPhone': travellerPhone,
      'tripType': tripType.toJson(),
      'tripDescription': tripDescription,
      'deadline': deadline.toJson(),
      'createdAt': createdAt.toJson(),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJson()),
      'reason': reason.toJson(),
      if (brief != null) 'brief': brief?.toJson(),
      'briefStatus': briefStatus.toJson(),
      if (briefAttemptedAt != null)
        'briefAttemptedAt': briefAttemptedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (resolutionActor != null) 'resolutionActor': resolutionActor,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SafetyAlert',
      if (id != null) 'id': id,
      'ownerId': ownerId,
      'tripId': tripId,
      'travellerName': travellerName,
      'travellerPhone': travellerPhone,
      'tripType': tripType.toJson(),
      'tripDescription': tripDescription,
      'deadline': deadline.toJson(),
      'createdAt': createdAt.toJson(),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'reason': reason.toJson(),
      if (brief != null) 'brief': brief?.toJsonForProtocol(),
      'briefStatus': briefStatus.toJson(),
      if (briefAttemptedAt != null)
        'briefAttemptedAt': briefAttemptedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (resolutionActor != null) 'resolutionActor': resolutionActor,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SafetyAlertImpl extends SafetyAlert {
  _SafetyAlertImpl({
    int? id,
    required String ownerId,
    required int tripId,
    required String travellerName,
    required String travellerPhone,
    required _ix6rm8oc.TripType tripType,
    required String tripDescription,
    required DateTime deadline,
    required DateTime createdAt,
    required List<_i0udr1y1.ContactSnapshot> contacts,
    _ijoowf6j.AlertReason? reason,
    _i2a7cxt8.IncidentBrief? brief,
    _i531ttm8.BriefStatus? briefStatus,
    DateTime? briefAttemptedAt,
    DateTime? resolvedAt,
    String? resolutionActor,
    String? resolutionNote,
  }) : super._(
         id: id,
         ownerId: ownerId,
         tripId: tripId,
         travellerName: travellerName,
         travellerPhone: travellerPhone,
         tripType: tripType,
         tripDescription: tripDescription,
         deadline: deadline,
         createdAt: createdAt,
         contacts: contacts,
         reason: reason,
         brief: brief,
         briefStatus: briefStatus,
         briefAttemptedAt: briefAttemptedAt,
         resolvedAt: resolvedAt,
         resolutionActor: resolutionActor,
         resolutionNote: resolutionNote,
       );

  /// Returns a shallow copy of this [SafetyAlert]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SafetyAlert copyWith({
    Object? id = _Undefined,
    String? ownerId,
    int? tripId,
    String? travellerName,
    String? travellerPhone,
    _ix6rm8oc.TripType? tripType,
    String? tripDescription,
    DateTime? deadline,
    DateTime? createdAt,
    List<_i0udr1y1.ContactSnapshot>? contacts,
    _ijoowf6j.AlertReason? reason,
    Object? brief = _Undefined,
    _i531ttm8.BriefStatus? briefStatus,
    Object? briefAttemptedAt = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? resolutionActor = _Undefined,
    Object? resolutionNote = _Undefined,
  }) {
    return SafetyAlert(
      id: id is int? ? id : this.id,
      ownerId: ownerId ?? this.ownerId,
      tripId: tripId ?? this.tripId,
      travellerName: travellerName ?? this.travellerName,
      travellerPhone: travellerPhone ?? this.travellerPhone,
      tripType: tripType ?? this.tripType,
      tripDescription: tripDescription ?? this.tripDescription,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      contacts: contacts ?? this.contacts.map((e0) => e0.copyWith()).toList(),
      reason: reason ?? this.reason,
      brief: brief is _i2a7cxt8.IncidentBrief? ? brief : this.brief?.copyWith(),
      briefStatus: briefStatus ?? this.briefStatus,
      briefAttemptedAt: briefAttemptedAt is DateTime?
          ? briefAttemptedAt
          : this.briefAttemptedAt,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      resolutionActor: resolutionActor is String?
          ? resolutionActor
          : this.resolutionActor,
      resolutionNote: resolutionNote is String?
          ? resolutionNote
          : this.resolutionNote,
    );
  }
}
