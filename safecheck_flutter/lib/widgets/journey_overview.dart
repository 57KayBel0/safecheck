import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';
import '../util/format.dart';
import 'safety_design.dart';

/// Displays only the existing server response; no inferred safety rating.
class JourneyOverview extends StatelessWidget {
  const JourneyOverview({
    super.key,
    required this.trip,
    required this.contacts,
    required this.onOpenContacts,
  });
  final Trip? trip;
  final List<TrustedContact> contacts;
  final VoidCallback onOpenContacts;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafetyReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafetySectionHeading(
            eyebrow: 'YOUR EVERYDAY COMPANION',
            title: trip == null
                ? 'Every journey starts with a plan.'
                : 'Your journey, at a glance.',
            subtitle: trip == null
                ? 'Choose your check-in. Bring your trusted people along.'
                : 'Your confirmed deadline and journey details, together in one place.',
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final metrics = [
                _OverviewMetric(
                  icon: Icons.shield_outlined,
                  label: 'JOURNEY STATUS',
                  value: trip == null
                      ? 'No active journey'
                      : 'Journey in progress',
                  detail: 'Based on the latest server response',
                ),
                _OverviewMetric(
                  icon: Icons.schedule_outlined,
                  label: 'NEXT CHECK-IN',
                  value: trip == null
                      ? 'Set your own time'
                      : formatSastDateTime(context, trip!.deadline),
                  detail: trip == null
                      ? 'Confirmed only when you start'
                      : 'Your server-confirmed deadline',
                ),
                _OverviewMetric(
                  icon: Icons.people_outline_rounded,
                  label: 'TRUSTED CONTACTS',
                  value:
                      '${contacts.length} ${contacts.length == 1 ? 'person' : 'people'} in your circle',
                  detail: 'Choose contacts for each journey',
                  onTap: onOpenContacts,
                ),
              ];
              if (constraints.maxWidth < 720) {
                return Column(
                  children: [
                    for (var i = 0; i < metrics.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      metrics[i],
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(child: metrics[i]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          if (contacts.isNotEmpty && trip == null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final contact in contacts)
                  Chip(
                    avatar: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        contact.name.characters.first.toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    label: Text(contact.name),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.primary, size: 21),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(value, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(detail, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
