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

/// Who can see a trip's location, chosen by the traveller per trip.
enum LocationSharing implements _is.SerializableModel {
  /// No location is collected.
  off,

  /// Location is collected during the trip but contacts can only see it
  /// after a missed check-in raises an alert.
  afterAlert,

  /// Contacts with the trip's link can follow the trip while it is active.
  live;

  static LocationSharing fromJson(String name) {
    switch (name) {
      case 'off':
        return LocationSharing.off;
      case 'afterAlert':
        return LocationSharing.afterAlert;
      case 'live':
        return LocationSharing.live;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "LocationSharing"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
