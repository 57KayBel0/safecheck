import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';
import '../util/format.dart';

class IncidentBriefCard extends StatelessWidget {
  const IncidentBriefCard({
    super.key,
    required this.alert,
    required this.onResolve,
    this.resolving = false,
  });
  final SafetyAlert alert;
  final VoidCallback onResolve;
  final bool resolving;
  @override
  Widget build(BuildContext context) {
    final brief = alert.brief;
    final resolved = alert.resolvedAt != null;
    Widget group(String label, List<String> values) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        for (final value in values)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('• $value'),
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          resolved ? 'Incident resolved' : 'Incident open',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (brief != null) ...[
          Text(
            brief.source == 'meta'
                ? 'AI-organized brief · facts from server records'
                : 'Standard incident brief',
          ),
          if (alert.briefStatus == BriefStatus.pending ||
              alert.briefStatus == BriefStatus.processing)
            const Text(
              'AI organization is pending. Recorded facts and standard steps are available now.',
            ),
          const SizedBox(height: 8),
          Text(brief.overview),
          group('Recorded facts', brief.facts),
          group('What is uncertain', brief.unknowns),
          group('Suggested next steps', brief.nextSteps),
        ],
        if (resolved) ...[
          const SizedBox(height: 12),
          Text(
            'Resolved ${formatDateTime(context, alert.resolvedAt!)} · ${alert.resolutionActor ?? 'authorized person'}',
          ),
          if (alert.resolutionNote != null) Text(alert.resolutionNote!),
        ] else ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: resolving ? null : onResolve,
            icon: const Icon(Icons.task_alt),
            label: Text(resolving ? 'Resolving…' : 'Resolve incident'),
          ),
          const Text(
            'Resolution stops pending messages. Messages already submitted cannot be recalled.',
          ),
        ],
      ],
    );
  }
}
