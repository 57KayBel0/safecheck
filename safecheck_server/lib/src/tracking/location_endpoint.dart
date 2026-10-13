import 'package:serverpod/serverpod.dart';

import '../common/validation.dart';
import '../generated/protocol.dart';
import 'tracking_service.dart';

/// Receives GPS fixes from the signed-in user's phone during a trip.
class LocationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Stores a batch of fixes for the caller's trip [tripId]. Returns how many
  /// were stored. Safe to retry with the same points.
  Future<int> recordLocations(
    Session session,
    int tripId,
    List<LocationPoint> points,
  ) {
    return TrackingService.record(
      session,
      ownerIdOf(session),
      tripId,
      points,
    );
  }

  /// Returns the stored route for one of the caller's trips.
  Future<List<TripLocation>> getTripLocations(
    Session session,
    int tripId,
  ) {
    return TrackingService.ownerLocations(
      session,
      ownerIdOf(session),
      tripId,
    );
  }
}
