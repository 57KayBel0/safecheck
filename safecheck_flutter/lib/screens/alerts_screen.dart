import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

import '../app_events.dart';
import '../client.dart';
import '../util/errors.dart';
import '../util/format.dart';
import '../widgets/copy_tracking_link_button.dart';
import '../widgets/demo_notice.dart';
import '../widgets/state_views.dart';

/// Alerts raised for missed check-ins and their message statuses.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<SafetyAlert>? _alerts;
  Map<int, List<AlertMessage>> _messagesByAlert = {};
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    dataRevision.addListener(_reloadSilently);
    _load();
  }

  @override
  void dispose() {
    dataRevision.removeListener(_reloadSilently);
    super.dispose();
  }

  void _reloadSilently() => _load(silent: true);

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final results = await Future.wait([
        client.alert.listAlerts(),
        client.alert.listMessages(),
      ]);
      final messages = results[1] as List<AlertMessage>;
      final byAlert = <int, List<AlertMessage>>{};
      for (final m in messages) {
        byAlert.putIfAbsent(m.alertId, () => []).add(m);
      }
      if (!mounted) return;
      setState(() {
        _alerts = results[0] as List<SafetyAlert>;
        _messagesByAlert = byAlert;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || (silent && _alerts != null)) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(label: 'Loading alerts…');
    if (_error != null) {
      return ErrorView(message: friendlyError(_error!), onRetry: _load);
    }
    final alerts = _alerts!;
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const MessageStatusBanner(),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            const SizedBox(
              height: 360,
              child: EmptyView(
                icon: Icons.notifications_none,
                title: 'No alerts',
                message:
                    'If you miss a check-in deadline, the alert and the '
                    'messages that would be sent appear here.',
              ),
            )
          else
            for (final alert in alerts) ...[
              _AlertCard(
                alert: alert,
                messages: _messagesByAlert[alert.id] ?? const [],
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.messages});

  final SafetyAlert alert;
  final List<AlertMessage> messages;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colors.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Missed check-in',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${tripTypeLabel(alert.tripType)}: ${alert.tripDescription}',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Deadline ${formatDateTime(context, alert.deadline)}\n'
              'Alert created ${formatDateTime(context, alert.createdAt)}',
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const Divider(height: 24),
            Text(
              'Messages (${messages.length})',
              style: text.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final m in messages) _MessageTile(message: m),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final AlertMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final statusLabel = MessageStatusBadge(
      status: message.status,
      channel: message.channel,
    ).label;
    return Semantics(
      label: '$statusLabel. Message to ${message.recipientName}.',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'To ${message.recipientName} · ${message.recipientPhone}',
                  style: text.labelLarge,
                ),
                MessageStatusBadge(
                  status: message.status,
                  channel: message.channel,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message.body, style: text.bodyMedium),
            CopyTrackingLinkButton(messageBody: message.body),
          ],
        ),
      ),
    );
  }
}
