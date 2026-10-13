import 'package:serverpod/serverpod.dart';

import 'trip_service.dart';

/// Persistent future calls that raise alerts for missed check-in deadlines.
/// Scheduled calls are stored in the database, so they survive restarts.
class TripDeadlineFutureCall extends FutureCall {
  /// Runs at a trip's deadline. Does nothing if the owner already checked in
  /// or the deadline was already processed.
  Future<void> processDeadline(Session session, int tripId) async {
    await TripService.processDeadline(session, tripId);
  }

  /// Recurring safety net that processes any overdue active trips.
  Future<void> sweepOverdue(Session session) async {
    await TripService.sweepOverdue(session);
  }
}
