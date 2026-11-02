import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

/// A trip's outcome does not establish whether a message was delivered.
class TripCompletionNotice extends StatelessWidget {
  const TripCompletionNotice({
    super.key,
    required this.status,
    required this.onDismiss,
    required this.onOpenAlerts,
  });

  final TripStatus status;
  final VoidCallback onDismiss;
  final VoidCallback onOpenAlerts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safe = status == TripStatus.checkedIn;
    final bg = safe ? colors.primaryContainer : colors.errorContainer;
    final fg = safe ? colors.onPrimaryContainer : colors.onErrorContainer;
    return Semantics(
      liveRegion: true,
      child: Card(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  safe ? Icons.verified_user : Icons.warning_amber_rounded,
                  color: fg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      safe ? "You're checked in" : 'Check-in deadline missed',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      safe
                          ? 'Your check-in was recorded. No missed-check-in '
                                'alert was raised for this trip.'
                          : 'An alert was created for this trip. Open Alerts '
                                'to check each message\'s status; an alert '
                                'does not confirm message delivery.',
                      style: TextStyle(color: fg),
                    ),
                    if (!safe) ...[
                      const SizedBox(height: 8),
                      FilledButton.tonalIcon(
                        onPressed: onOpenAlerts,
                        icon: const Icon(Icons.notifications_outlined),
                        label: const Text('View alerts'),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Dismiss',
                onPressed: onDismiss,
                icon: Icon(Icons.close, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
