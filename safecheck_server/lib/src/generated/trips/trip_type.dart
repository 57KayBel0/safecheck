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

/// The kind of trip the traveller is taking.
enum TripType implements _is.SerializableModel {
  walking,
  minibusTaxi,
  rideHailing,
  driving,
  publicTransport,
  meetingSomeone,
  other;

  static TripType fromJson(String name) {
    switch (name) {
      case 'walking':
        return TripType.walking;
      case 'minibusTaxi':
        return TripType.minibusTaxi;
      case 'rideHailing':
        return TripType.rideHailing;
      case 'driving':
        return TripType.driving;
      case 'publicTransport':
        return TripType.publicTransport;
      case 'meetingSomeone':
        return TripType.meetingSomeone;
      case 'other':
        return TripType.other;
      default:
        throw ArgumentError('Value "$name" cannot be converted to "TripType"');
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
