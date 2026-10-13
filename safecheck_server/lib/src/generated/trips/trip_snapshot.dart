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
import '../trips/trip.dart' as _iy3h1oq5;

/// The current trip state together with the server's clock, so the app can
/// show an accurate countdown even if the device clock is wrong.
abstract class TripSnapshot
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TripSnapshot._({
    this.trip,
    this.endedTrip,
    required this.serverTime,
  });

  factory TripSnapshot({
    _iy3h1oq5.Trip? trip,
    _iy3h1oq5.Trip? endedTrip,
    required DateTime serverTime,
  }) = _TripSnapshotImpl;

  factory TripSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return TripSnapshot(
      trip: jsonSerialization['trip'] == null
          ? null
          : _iwfhb10e.Protocol().deserialize<_iy3h1oq5.Trip>(
              jsonSerialization['trip'],
            ),
      endedTrip: jsonSerialization['endedTrip'] == null
          ? null
          : _iwfhb10e.Protocol().deserialize<_iy3h1oq5.Trip>(
              jsonSerialization['endedTrip'],
            ),
      serverTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverTime'],
      ),
    );
  }

  /// The active trip, or null if the user has none.
  _iy3h1oq5.Trip? trip;

  /// The trip that just ended, if this snapshot is the result of ending one.
  _iy3h1oq5.Trip? endedTrip;

  DateTime serverTime;

  /// Returns a shallow copy of this [TripSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TripSnapshot copyWith({
    _iy3h1oq5.Trip? trip,
    _iy3h1oq5.Trip? endedTrip,
    DateTime? serverTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TripSnapshot',
      if (trip != null) 'trip': trip?.toJson(),
      if (endedTrip != null) 'endedTrip': endedTrip?.toJson(),
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TripSnapshot',
      if (trip != null) 'trip': trip?.toJsonForProtocol(),
      if (endedTrip != null) 'endedTrip': endedTrip?.toJsonForProtocol(),
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TripSnapshotImpl extends TripSnapshot {
  _TripSnapshotImpl({
    _iy3h1oq5.Trip? trip,
    _iy3h1oq5.Trip? endedTrip,
    required DateTime serverTime,
  }) : super._(
         trip: trip,
         endedTrip: endedTrip,
         serverTime: serverTime,
       );

  /// Returns a shallow copy of this [TripSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TripSnapshot copyWith({
    Object? trip = _Undefined,
    Object? endedTrip = _Undefined,
    DateTime? serverTime,
  }) {
    return TripSnapshot(
      trip: trip is _iy3h1oq5.Trip? ? trip : this.trip?.copyWith(),
      endedTrip: endedTrip is _iy3h1oq5.Trip?
          ? endedTrip
          : this.endedTrip?.copyWith(),
      serverTime: serverTime ?? this.serverTime,
    );
  }
}
