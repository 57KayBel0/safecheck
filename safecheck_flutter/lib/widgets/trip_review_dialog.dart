import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

import '../reminders/check_in_reminder.dart';
import '../util/format.dart';
import 'safety_plan_card.dart';

/// Reviews a draft only. Opening or dismissing this dialog starts no trip.
class TripReviewDialog extends StatelessWidget {
  const TripReviewDialog({
    super.key,
    required this.tripType,
    required this.description,
    required this.durationMinutes,
    required this.estimatedDeadline,
    required this.contacts,
    required this.locationSharing,
    required this.reminderMode,
    this.exactDeadline = false,
    this.graceMinutes = 0,
    this.safetyPlanJson,
    this.useAiIncidentSummary = false,
    this.allowContactResolution = false,
  });

  final TripType tripType;
  final String description;
  final int durationMinutes;
  final DateTime estimatedDeadline;
  final List<TrustedContact> contacts;
  final LocationSharing locationSharing;
  final CheckInReminderMode reminderMode;
  final bool exactDeadline;
  final int graceMinutes;
  final String? safetyPlanJson;
  final bool useAiIncidentSummary;
  final bool allowContactResolution;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      scrollable: true,
      title: const Text('Review your trip'),
      content: SizedBox(
        width: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewDetail(
              icon: tripTypeIcon(tripType),
              label: tripTypeLabel(tripType),
              value: description,
            ),
            _ReviewDetail(
              icon: Icons.schedule,
              label: exactDeadline
                  ? 'Check-in deadline'
                  : 'Check in within ${formatDurationShort(durationMinutes)}',
              value: exactDeadline
                  ? '${formatSastDateTime(context, estimatedDeadline)}. '
                        'This exact time is kept when you confirm. '
                        'If it becomes too close, choose a new time.'
                  : 'Around ${formatDateTime(context, estimatedDeadline)} '
                        '(your local time). The countdown starts when you confirm; '
                        'the server sets the exact deadline.',
            ),
            _ReviewDetail(
              icon: locationSharing == LocationSharing.off
                  ? Icons.location_off_outlined
                  : Icons.location_on_outlined,
              label: switch (locationSharing) {
                LocationSharing.off => 'Location off',
                LocationSharing.live => 'Location shared during the trip',
                LocationSharing.afterAlert => 'Location visible after an alert',
              },
              value: switch (locationSharing) {
                LocationSharing.off => 'No location will be recorded.',
                LocationSharing.live =>
                  'Records points while the app is running. Anyone with a '
                      'contact tracking link can view the saved points.',
                LocationSharing.afterAlert =>
                  'Records points while the app is running. Contacts can view '
                      'the saved points only after a missed check-in.',
              },
            ),
            _ReviewDetail(
              icon: Icons.notifications_none,
              label: 'Reminder',
              value: switch (reminderMode) {
                CheckInReminderMode.silent => 'Silent, while the app is open.',
                CheckInReminderMode.vibration =>
                  'Vibration, while the app is open.',
                CheckInReminderMode.sound => 'Sound, while the app is open.',
              },
            ),
            const Divider(height: 24),
            if (graceMinutes > 0)
              Text(
                'Grace period: $graceMinutes minutes. Alert time: ${formatSastDateTime(context, estimatedDeadline.add(Duration(minutes: graceMinutes)))}.',
              ),
            if (useAiIncidentSummary)
              const Text(
                'Meta may organize an incident brief after an alert. Standard guidance is available immediately if AI fails.',
              ),
            if (allowContactResolution)
              const Text(
                'Accepted contacts with a private incident link may resolve the incident. Anyone holding that link has the same permission for 48 hours.',
              ),
            SafetyPlanCard(planJson: safetyPlanJson),
            Text(
              'Trusted contacts (${contacts.length})',
              style: text.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final contact in contacts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${contact.name} · ${contact.phoneNumber}'),
              ),
            Text(
              'The server saves your current contact list when the trip starts. '
              'Later contact edits do not change that trip.',
              style: text.bodySmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'If you miss the deadline, an alert is created. Check Alerts for '
              'each message\'s status. Simulated messages are not sent.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Edit details'),
        ),
        FilledButton.icon(
          onPressed: contacts.isEmpty
              ? null
              : () => Navigator.pop(context, true),
          icon: const Icon(Icons.check),
          label: const Text('Confirm and start'),
        ),
      ],
    );
  }
}

class _ReviewDetail extends StatelessWidget {
  const _ReviewDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.titleSmall),
                const SizedBox(height: 4),
                Text(value, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
