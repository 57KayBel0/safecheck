import 'dart:convert';
import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${meta ? 'AI safety plan' : 'Standard safety plan'}${atStart ? ' · at journey start' : ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(plan['checkInAdvice'] as String? ?? ''),
            for (final step in (plan['precautions'] as List? ?? const []))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('• $step'),
              ),
            for (final unknown in (plan['uncertainties'] as List? ?? const []))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  unknown.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
