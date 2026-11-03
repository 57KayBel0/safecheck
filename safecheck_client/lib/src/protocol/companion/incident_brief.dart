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

/// Facts and unknowns are assembled by the server. Meta may prioritize them.
abstract class IncidentBrief
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentBrief._({
    required this.source,
    required this.overview,
    required this.facts,
    required this.unknowns,
    required this.nextSteps,
    required this.generatedAt,
  });

  factory IncidentBrief({
    required String source,
    required String overview,
    required List<String> facts,
    required List<String> unknowns,
    required List<String> nextSteps,
    required DateTime generatedAt,
  }) = _IncidentBriefImpl;

  factory IncidentBrief.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentBrief(
      source: jsonSerialization['source'] as String,
      overview: jsonSerialization['overview'] as String,
      facts: _iusok08q.Protocol().deserialize<List<String>>(
        jsonSerialization['facts'],
      ),
      unknowns: _iusok08q.Protocol().deserialize<List<String>>(
        jsonSerialization['unknowns'],
      ),
      nextSteps: _iusok08q.Protocol().deserialize<List<String>>(
        jsonSerialization['nextSteps'],
      ),
      generatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
    );
  }

  String source;

  String overview;

  List<String> facts;

  List<String> unknowns;

  List<String> nextSteps;

  DateTime generatedAt;

  /// Returns a shallow copy of this [IncidentBrief]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentBrief copyWith({
    String? source,
    String? overview,
    List<String>? facts,
    List<String>? unknowns,
    List<String>? nextSteps,
    DateTime? generatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentBrief',
      'source': source,
      'overview': overview,
      'facts': facts.toJson(),
      'unknowns': unknowns.toJson(),
      'nextSteps': nextSteps.toJson(),
      'generatedAt': generatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentBrief',
      'source': source,
      'overview': overview,
      'facts': facts.toJson(),
      'unknowns': unknowns.toJson(),
      'nextSteps': nextSteps.toJson(),
      'generatedAt': generatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _IncidentBriefImpl extends IncidentBrief {
  _IncidentBriefImpl({
    required String source,
    required String overview,
    required List<String> facts,
    required List<String> unknowns,
    required List<String> nextSteps,
    required DateTime generatedAt,
  }) : super._(
         source: source,
         overview: overview,
         facts: facts,
         unknowns: unknowns,
         nextSteps: nextSteps,
         generatedAt: generatedAt,
       );

  /// Returns a shallow copy of this [IncidentBrief]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentBrief copyWith({
    String? source,
    String? overview,
    List<String>? facts,
    List<String>? unknowns,
    List<String>? nextSteps,
    DateTime? generatedAt,
  }) {
    return IncidentBrief(
      source: source ?? this.source,
      overview: overview ?? this.overview,
      facts: facts ?? this.facts.map((e0) => e0).toList(),
      unknowns: unknowns ?? this.unknowns.map((e0) => e0).toList(),
      nextSteps: nextSteps ?? this.nextSteps.map((e0) => e0).toList(),
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
