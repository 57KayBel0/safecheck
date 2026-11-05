import 'dart:convert';
import 'package:flutter/material.dart';
import 'safety_design.dart';

class SafetyPlanCard extends StatelessWidget {
  const SafetyPlanCard({
    super.key,
    required this.planJson,
    this.atStart = false,
  });
  final String? planJson;
  final bool atStart;
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? plan;
    try {
      if (planJson != null) {
        plan = jsonDecode(planJson!) as Map<String, dynamic>;
      }
    } catch (_) {
      plan = null;
    }
    if (plan == null) return const SizedBox.shrink();
    final meta = plan['source'] == 'meta';
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  meta ? Icons.auto_awesome_rounded : Icons.shield_outlined,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  '${meta ? 'AI safety plan' : 'Standard safety plan'}${atStart ? ' · at journey start' : ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SafetyTag(
                  label: meta ? 'Meta suggestions' : 'Standard guidance',
                  icon: meta
                      ? Icons.auto_awesome_outlined
                      : Icons.menu_book_outlined,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan['checkInAdvice'] as String? ?? '',
              style: theme.textTheme.bodyLarge,
            ),
            SafetyFactGroup(
              title: 'Practical precautions',
              values: (plan['precautions'] as List? ?? const [])
                  .map((e) => e.toString())
                  .toList(),
              icon: Icons.checklist_rounded,
            ),
            SafetyFactGroup(
              title: 'Keep in mind',
              values: (plan['uncertainties'] as List? ?? const [])
                  .map((e) => e.toString())
                  .toList(),
              icon: Icons.info_outline,
              tone: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 8),
            Text(
              meta
                  ? 'Suggestions, not predictions of danger. Your reviewed server deadline controls alerts.'
                  : 'AI was unavailable or not used. The server still monitors the confirmed check-in.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
