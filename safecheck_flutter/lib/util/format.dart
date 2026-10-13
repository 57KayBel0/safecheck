import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

String tripTypeLabel(TripType type) => switch (type) {
  TripType.walking => 'Walking',
  TripType.minibusTaxi => 'Minibus taxi',
  TripType.rideHailing => 'Ride-hailing',
  TripType.driving => 'Driving',
  TripType.publicTransport => 'Bus or train',
  TripType.meetingSomeone => 'Meeting someone',
  TripType.other => 'Other',
};

IconData tripTypeIcon(TripType type) => switch (type) {
  TripType.walking => Icons.directions_walk,
  TripType.minibusTaxi => Icons.airport_shuttle,
  TripType.rideHailing => Icons.local_taxi,
  TripType.driving => Icons.directions_car,
  TripType.publicTransport => Icons.directions_bus,
  TripType.meetingSomeone => Icons.people,
  TripType.other => Icons.place,
};

/// "14:05" in the device's locale and time zone.
String formatTime(BuildContext context, DateTime time) {
  final local = time.toLocal();
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
}

/// "Wed, 1 Oct 2026 · 14:05"
String formatDateTime(BuildContext context, DateTime time) {
  final local = time.toLocal();
  final date = MaterialLocalizations.of(context).formatMediumDate(local);
  return '$date · ${formatTime(context, time)}';
}

/// "1 h 05 min" / "12 min" / "45 s"
String formatDurationShort(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h h' : '$h h ${m.toString().padLeft(2, '0')} min';
}

/// "01:04:09" or "04:09" for a countdown.
String formatCountdown(Duration remaining) {
  final total = remaining.isNegative ? 0 : remaining.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Spoken version of a countdown for screen readers.
String describeCountdown(Duration remaining) {
  final total = remaining.isNegative ? 0 : remaining.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final parts = [
    if (h > 0) '$h ${h == 1 ? 'hour' : 'hours'}',
    if (m > 0 || h > 0) '$m ${m == 1 ? 'minute' : 'minutes'}',
    if (h == 0 && m == 0) '${total % 60} seconds',
  ];
  return '${parts.join(' ')} left to check in';
}
