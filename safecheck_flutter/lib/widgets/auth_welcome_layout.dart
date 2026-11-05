import 'package:flutter/material.dart';
import 'safety_design.dart';

/// Presentation around the existing Serverpod forms, including recovery/OTP.
class AuthWelcomeLayout extends StatelessWidget {
  const AuthWelcomeLayout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafetyBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1000;
              final form = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(wide ? 32 : 22),
                    child: child,
                  ),
                ),
              );
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 48 : 20,
                  vertical: wide ? 48 : 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: SafetyReveal(
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 72,
                                      top: 20,
                                    ),
                                    child: _WelcomeStory(wide: wide),
                                  ),
                                ),
                                Flexible(child: form),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const BrandMark(),
                                const SizedBox(height: 32),
                                Text(
                                  'Your journey.\nA clearer check-in.',
                                  style: theme.textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'A thoughtful way to plan your journey and stay connected to your trusted people.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Align(alignment: Alignment.center, child: form),
                                const SizedBox(height: 20),
                                Text(
                                  'Your deadline. Your contacts. Your choice.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomeStory extends StatelessWidget {
  const _WelcomeStory({required this.wide});
  final bool wide;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandMark(),
        const SizedBox(height: 52),
        const SafetyTag(
          label: 'PERSONAL SAFETY, THOUGHTFULLY PLANNED',
          icon: Icons.route_outlined,
        ),
        const SizedBox(height: 28),
        Text(
          'Your journey.\nYour people.\nYour check-in.',
          style: theme.textTheme.displaySmall?.copyWith(
            fontSize: 52,
            fontWeight: FontWeight.w600,
            letterSpacing: -2,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Set a check-in time before you travel. If you miss it, SafeCheck raises an alert for your trusted contacts.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 36),
        for (final item in const [
          (
            Icons.schedule_rounded,
            'A plan you control',
            'Review every deadline before your journey starts.',
          ),
          (
            Icons.people_outline_rounded,
            'Your trusted circle',
            'Choose the people included in each journey.',
          ),
          (
            Icons.auto_awesome_outlined,
            'AI, with clear boundaries',
            'Practical suggestions. Never predictions of danger.',
          ),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$1, color: colors.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$2, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 3),
                      Text(item.$3, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        Text(
          'Designed for journeys in South Africa.\nNot an emergency service.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
