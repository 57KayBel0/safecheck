import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';
import '../util/format.dart';
import 'safety_design.dart';

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
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: SafetyTag(
            label: resolved ? 'Incident resolved' : 'Incident open',
            icon: resolved ? Icons.task_alt_rounded : Icons.info_outline,
            color: resolved ? colors.primary : colors.error,
          ),
        ),
        const SizedBox(height: 12),
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
          Text(brief.overview, style: Theme.of(context).textTheme.bodyLarge),
          SafetyFactGroup(
            title: 'Recorded facts',
            values: brief.facts,
            icon: Icons.fact_check_outlined,
          ),
          SafetyFactGroup(
            title: 'What is uncertain',
            values: brief.unknowns,
            icon: Icons.help_outline_rounded,
            tone: colors.secondary,
          ),
          SafetyFactGroup(
            title: 'Suggested next steps',
            values: brief.nextSteps,
            icon: Icons.playlist_add_check_rounded,
          ),
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
          Text(
            'Resolution stops pending messages. Messages already submitted cannot be recalled.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
