import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

/// The exact label every simulated message carries.
const demoSmsLabel = 'Demo — SMS not sent';

/// Small pill showing the status stored for an alert message.
class MessageStatusBadge extends StatelessWidget {
  const MessageStatusBadge({
    super.key,
    required this.status,
    required this.channel,
  });

  final MessageStatus status;
  final MessageChannel channel;

  String get label => switch (status) {
    MessageStatus.simulated =>
      channel == MessageChannel.sms ? demoSmsLabel : 'Demo — WhatsApp not sent',
    MessageStatus.sent => 'Accepted by provider',
    MessageStatus.delivered => 'Delivered',
    MessageStatus.failed => 'Not sent',
    MessageStatus.pending => 'Pending',
    MessageStatus.sending => 'Sending',
    MessageStatus.skipped => 'Skipped',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sms_failed_outlined,
            size: 16,
            color: colors.onTertiaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Explains what SMS provider statuses mean without implying all messages
/// are simulated when live sending is configured.
class MessageStatusBanner extends StatelessWidget {
  const MessageStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colors.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Message statuses reflect the server record. “Accepted by '
              'provider” means the SMS was submitted; “Delivered” means the '
              'provider confirmed delivery. Simulated messages were not sent.',
              style: TextStyle(color: colors.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
