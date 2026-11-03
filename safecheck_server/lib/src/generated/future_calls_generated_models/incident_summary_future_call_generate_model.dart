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

abstract class IncidentSummaryFutureCallGenerateModel
    implements _is.SerializableModel, _is.ProtocolSerialization {
  IncidentSummaryFutureCallGenerateModel._({required this.alertId});

  factory IncidentSummaryFutureCallGenerateModel({required int alertId}) =
      _IncidentSummaryFutureCallGenerateModelImpl;

  factory IncidentSummaryFutureCallGenerateModel.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return IncidentSummaryFutureCallGenerateModel(
      alertId: jsonSerialization['alertId'] as int,
    );
  }

  int alertId;

  /// Returns a shallow copy of this [IncidentSummaryFutureCallGenerateModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IncidentSummaryFutureCallGenerateModel copyWith({int? alertId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentSummaryFutureCallGenerateModel',
      'alertId': alertId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _IncidentSummaryFutureCallGenerateModelImpl
    extends IncidentSummaryFutureCallGenerateModel {
  _IncidentSummaryFutureCallGenerateModelImpl({required int alertId})
    : super._(alertId: alertId);

  /// Returns a shallow copy of this [IncidentSummaryFutureCallGenerateModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IncidentSummaryFutureCallGenerateModel copyWith({int? alertId}) {
    return IncidentSummaryFutureCallGenerateModel(
      alertId: alertId ?? this.alertId,
    );
  }
}
