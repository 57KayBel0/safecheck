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
import 'package:safecheck_server/src/generated/protocol.dart' as _iwfhb10e;
import 'package:serverpod/serverpod.dart' as _is;
import '../tracking/location_sharing.dart' as _ixmrytkl;
import '../trips/trip_type.dart' as _ix6rm8oc;

abstract class JourneyRequest
    implements _is.SerializableModel, _is.ProtocolSerialization {
  JourneyRequest._({
    required this.tripType,
    required this.description,
    required this.checkInAtUtc,
    required this.contactIds,
    int? graceMinutes,
    _ixmrytkl.LocationSharing? locationSharing,
    this.safetyPlanJson,
    bool? useAiIncidentSummary,
    bool? allowContactResolution,
  }) : graceMinutes = graceMinutes ?? 0,
       locationSharing = locationSharing ?? _ixmrytkl.LocationSharing.off,
       useAiIncidentSummary = useAiIncidentSummary ?? false,
       allowContactResolution = allowContactResolution ?? false;

  factory JourneyRequest({
    required _ix6rm8oc.TripType tripType,
    required String description,
    required DateTime checkInAtUtc,
    required List<int> contactIds,
    int? graceMinutes,
    _ixmrytkl.LocationSharing? locationSharing,
    String? safetyPlanJson,
    bool? useAiIncidentSummary,
    bool? allowContactResolution,
  }) = _JourneyRequestImpl;

  factory JourneyRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return JourneyRequest(
      tripType: _ix6rm8oc.TripType.fromJson(
        (jsonSerialization['tripType'] as String),
      ),
      description: jsonSerialization['description'] as String,
      checkInAtUtc: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['checkInAtUtc'],
      ),
      contactIds: _iwfhb10e.Protocol().deserialize<List<int>>(
        jsonSerialization['contactIds'],
      ),
      graceMinutes: jsonSerialization['graceMinutes'] as int?,
      locationSharing: jsonSerialization['locationSharing'] == null
          ? null
          : _ixmrytkl.LocationSharing.fromJson(
              (jsonSerialization['locationSharing'] as String),
            ),
      safetyPlanJson: jsonSerialization['safetyPlanJson'] as String?,
      useAiIncidentSummary: jsonSerialization['useAiIncidentSummary'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['useAiIncidentSummary'],
            ),
      allowContactResolution:
          jsonSerialization['allowContactResolution'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['allowContactResolution'],
            ),
    );
  }

  _ix6rm8oc.TripType tripType;

  String description;

  DateTime checkInAtUtc;

  List<int> contactIds;

  int graceMinutes;

  _ixmrytkl.LocationSharing locationSharing;

  String? safetyPlanJson;

  bool useAiIncidentSummary;

  bool allowContactResolution;

  /// Returns a shallow copy of this [JourneyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  JourneyRequest copyWith({
    _ix6rm8oc.TripType? tripType,
    String? description,
    DateTime? checkInAtUtc,
    List<int>? contactIds,
    int? graceMinutes,
    _ixmrytkl.LocationSharing? locationSharing,
    String? safetyPlanJson,
    bool? useAiIncidentSummary,
    bool? allowContactResolution,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'JourneyRequest',
      'tripType': tripType.toJson(),
      'description': description,
      'checkInAtUtc': checkInAtUtc.toJson(),
      'contactIds': contactIds.toJson(),
      'graceMinutes': graceMinutes,
      'locationSharing': locationSharing.toJson(),
      if (safetyPlanJson != null) 'safetyPlanJson': safetyPlanJson,
      'useAiIncidentSummary': useAiIncidentSummary,
      'allowContactResolution': allowContactResolution,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'JourneyRequest',
      'tripType': tripType.toJson(),
      'description': description,
      'checkInAtUtc': checkInAtUtc.toJson(),
      'contactIds': contactIds.toJson(),
      'graceMinutes': graceMinutes,
      'locationSharing': locationSharing.toJson(),
      if (safetyPlanJson != null) 'safetyPlanJson': safetyPlanJson,
      'useAiIncidentSummary': useAiIncidentSummary,
      'allowContactResolution': allowContactResolution,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JourneyRequestImpl extends JourneyRequest {
  _JourneyRequestImpl({
    required _ix6rm8oc.TripType tripType,
    required String description,
    required DateTime checkInAtUtc,
    required List<int> contactIds,
    int? graceMinutes,
    _ixmrytkl.LocationSharing? locationSharing,
    String? safetyPlanJson,
    bool? useAiIncidentSummary,
    bool? allowContactResolution,
  }) : super._(
         tripType: tripType,
         description: description,
         checkInAtUtc: checkInAtUtc,
         contactIds: contactIds,
         graceMinutes: graceMinutes,
         locationSharing: locationSharing,
         safetyPlanJson: safetyPlanJson,
         useAiIncidentSummary: useAiIncidentSummary,
         allowContactResolution: allowContactResolution,
       );

  /// Returns a shallow copy of this [JourneyRequest]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  JourneyRequest copyWith({
    _ix6rm8oc.TripType? tripType,
    String? description,
    DateTime? checkInAtUtc,
    List<int>? contactIds,
    int? graceMinutes,
    _ixmrytkl.LocationSharing? locationSharing,
    Object? safetyPlanJson = _Undefined,
    bool? useAiIncidentSummary,
    bool? allowContactResolution,
  }) {
    return JourneyRequest(
      tripType: tripType ?? this.tripType,
      description: description ?? this.description,
      checkInAtUtc: checkInAtUtc ?? this.checkInAtUtc,
      contactIds: contactIds ?? this.contactIds.map((e0) => e0).toList(),
      graceMinutes: graceMinutes ?? this.graceMinutes,
      locationSharing: locationSharing ?? this.locationSharing,
      safetyPlanJson: safetyPlanJson is String?
          ? safetyPlanJson
          : this.safetyPlanJson,
      useAiIncidentSummary: useAiIncidentSummary ?? this.useAiIncidentSummary,
      allowContactResolution:
          allowContactResolution ?? this.allowContactResolution,
    );
  }
}
