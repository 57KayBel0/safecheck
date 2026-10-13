/// Selects the optional foreground feedback for a check-in reminder.
enum CheckInReminderMode { silent, vibration, sound }

/// Claims the single reminder for each server trip ID.
///
/// Time is supplied by the caller so countdowns and reminders use the same
/// server-adjusted clock, and tests can exercise the boundary deterministically.
class CheckInReminderGate {
  static const leadTime = Duration(seconds: 60);

  final Set<int> _remindedTripIds = {};
  int? _visibleTripId;

  bool isVisibleFor(int tripId) => _visibleTripId == tripId;

  bool claim({
    required int tripId,
    required DateTime deadline,
    required DateTime serverNow,
  }) {
    final startsAt = deadline.subtract(leadTime);
    if (serverNow.isBefore(startsAt) || !serverNow.isBefore(deadline)) {
      return false;
    }
    if (!_remindedTripIds.add(tripId)) return false;
    _visibleTripId = tripId;
    return true;
  }

  /// Hides the banner after check-in or when the server reports an ended trip.
  /// The claimed ID remains recorded so a stale response cannot show it again.
  void cancel(int tripId) {
    if (_visibleTripId == tripId) _visibleTripId = null;
  }
}
