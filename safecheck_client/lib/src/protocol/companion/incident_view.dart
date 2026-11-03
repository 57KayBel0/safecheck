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
import '../companion/incident_brief.dart' as _i2a7cxt8;

abstract class IncidentView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentView._({
    required this.travellerName,
    required this.journeyDescription,
    required this.deadline,
    required this.createdAt,
    required this.reason,
    required this.brief,
    required this.canResolve,
    this.resolvedAt,
    this.resolutionActor,
    this.resolutionNote,
    this.trackingUrl,
  });

  factory IncidentView({
    required String travellerName,
    required String journeyDescription,
    required DateTime deadline,
    required DateTime createdAt,
    required _ijoowf6j.AlertReason reason,
    required _i2a7cxt8.IncidentBrief brief,
    required bool canResolve,
    DateTime? resolvedAt,
    String? resolutionActor,
    String? resolutionNote,
    String? trackingUrl,
  }) = _IncidentViewImpl;

  factory IncidentView.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentView(
      travellerName: jsonSerialization['travellerName'] as String,
      journeyDescription: jsonSerialization['journeyDescription'] as String,
      deadline: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['deadline'],
      ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      reason: _ijoowf6j.AlertReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
      brief: _iusok08q.Protocol().deserialize<_i2a7cxt8.IncidentBrief>(
        jsonSerialization['brief'],
      ),
      canResolve: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['canResolve'],
      ),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resolvedAt'],
            ),
      resolutionActor: jsonSerialization['resolutionActor'] as String?,
      resolutionNote: jsonSerialization['resolutionNote'] as String?,
      trackingUrl: jsonSerialization['trackingUrl'] as String?,
    );
  }

  String travellerName;

  String journeyDescription;

  DateTime deadline;

  DateTime createdAt;

  _ijoowf6j.AlertReason reason;

  _i2a7cxt8.IncidentBrief brief;

  bool canResolve;

  DateTime? resolvedAt;

  String? resolutionActor;

  String? resolutionNote;

  String? trackingUrl;

  /// Returns a shallow copy of this [IncidentView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentView copyWith({
    String? travellerName,
    String? journeyDescription,
    DateTime? deadline,
    DateTime? createdAt,
    _ijoowf6j.AlertReason? reason,
    _i2a7cxt8.IncidentBrief? brief,
    bool? canResolve,
    DateTime? resolvedAt,
    String? resolutionActor,
    String? resolutionNote,
    String? trackingUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentView',
      'travellerName': travellerName,
      'journeyDescription': journeyDescription,
      'deadline': deadline.toJson(),
      'createdAt': createdAt.toJson(),
      'reason': reason.toJson(),
      'brief': brief.toJson(),
      'canResolve': canResolve,
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (resolutionActor != null) 'resolutionActor': resolutionActor,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
      if (trackingUrl != null) 'trackingUrl': trackingUrl,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentView',
      'travellerName': travellerName,
      'journeyDescription': journeyDescription,
      'deadline': deadline.toJson(),
      'createdAt': createdAt.toJson(),
      'reason': reason.toJson(),
      'brief': brief.toJsonForProtocol(),
      'canResolve': canResolve,
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (resolutionActor != null) 'resolutionActor': resolutionActor,
      if (resolutionNote != null) 'resolutionNote': resolutionNote,
      if (trackingUrl != null) 'trackingUrl': trackingUrl,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentViewImpl extends IncidentView {
  _IncidentViewImpl({
    required String travellerName,
    required String journeyDescription,
    required DateTime deadline,
    required DateTime createdAt,
    required _ijoowf6j.AlertReason reason,
    required _i2a7cxt8.IncidentBrief brief,
    required bool canResolve,
    DateTime? resolvedAt,
    String? resolutionActor,
    String? resolutionNote,
    String? trackingUrl,
  }) : super._(
         travellerName: travellerName,
         journeyDescription: journeyDescription,
         deadline: deadline,
         createdAt: createdAt,
         reason: reason,
         brief: brief,
         canResolve: canResolve,
         resolvedAt: resolvedAt,
         resolutionActor: resolutionActor,
         resolutionNote: resolutionNote,
         trackingUrl: trackingUrl,
       );

  /// Returns a shallow copy of this [IncidentView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentView copyWith({
    String? travellerName,
    String? journeyDescription,
    DateTime? deadline,
    DateTime? createdAt,
    _ijoowf6j.AlertReason? reason,
    _i2a7cxt8.IncidentBrief? brief,
    bool? canResolve,
    Object? resolvedAt = _Undefined,
    Object? resolutionActor = _Undefined,
    Object? resolutionNote = _Undefined,
    Object? trackingUrl = _Undefined,
  }) {
    return IncidentView(
      travellerName: travellerName ?? this.travellerName,
      journeyDescription: journeyDescription ?? this.journeyDescription,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      reason: reason ?? this.reason,
      brief: brief ?? this.brief.copyWith(),
      canResolve: canResolve ?? this.canResolve,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      resolutionActor: resolutionActor is String?
          ? resolutionActor
          : this.resolutionActor,
      resolutionNote: resolutionNote is String?
          ? resolutionNote
          : this.resolutionNote,
      trackingUrl: trackingUrl is String? ? trackingUrl : this.trackingUrl,
    );
  }
}
