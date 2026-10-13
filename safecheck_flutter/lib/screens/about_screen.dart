import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/privacy_policy_link.dart';
import '../widgets/state_views.dart';

void openAboutSafeCheck(BuildContext context) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const AboutSafeCheckScreen()),
  );
}

class AboutSafeCheckScreen extends StatelessWidget {
  const AboutSafeCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About SafeCheck')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.shield_moon, size: 56),
                  const SizedBox(height: 16),
                  Text('A check-in companion', style: text.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                    'SafeCheck is a personal safety prototype for South Africa. '
                    'Before travelling, set a check-in deadline and choose your '
                    'trusted contacts. Tap “I\'m safe” before the deadline. '
                    'If you miss it, the server creates an alert.',
                  ),
                  const SizedBox(height: 24),
                  Text('Implemented features', style: text.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Email sign-up and sign-in, Google sign-in when configured, '
                    'and an optional remembered login on a trusted device. '
                    'A personal profile and up to five trusted contacts with '
                    'South African phone-number validation. Select a phone '
                    'contact on supported devices or enter details manually, '
                    'then review them before saving.\n\n'
                    'Trip deadlines, a countdown, check-in, trip history, '
                    'and alert/message history. Each trip keeps a snapshot of '
                    'its contacts so later edits do not change that trip.',
                  ),
                  const SizedBox(height: 24),
                  Text('Prototype limitations', style: text.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Demo — SMS not sent. Demo messages are simulated; '
                    'an alert in the app does not mean a contact was notified. '
                    'Phone contact selection depends on device and browser '
                    'support. Google sign-in needs OAuth configuration.\n\n'
                    'SafeCheck cannot guarantee your safety or an emergency '
                    'response. It is not an emergency service. Do not rely on '
                    'this prototype as your only safety arrangement.',
                  ),
                  const SizedBox(height: 24),
                  Text('Created and operated by', style: text.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Kabelo Motshabi Makgae'),
                  const SizedBox(height: 16),
                  const Text(
                    'The Serverpod Cloud project region and the public and '
                    'private object-storage regions are Europe.\n\n'
                    'For support, feedback or privacy requests, use the email '
                    'below. You can request access, correction or deletion of '
                    'your data. The request-handling process is not yet '
                    'established; emailing does not trigger automatic deletion '
                    'and no response time is guaranteed. This address does not '
                    'provide emergency assistance.',
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        final opened = await launchUrl(
                          Uri(
                            scheme: 'mailto',
                            path: 'kabelo.6a8fbeb6546d3829dedadcf7@gmail.com',
                          ),
                        );
                        if (!opened && context.mounted) {
                          showSnack(
                            context,
                            'Could not open your email app.',
                            error: true,
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          showSnack(
                            context,
                            'Could not open your email app.',
                            error: true,
                          );
                        }
                      }
                    },
                    child: const Text(
                      'kabelo.6a8fbeb6546d3829dedadcf7@gmail.com',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const PrivacyPolicyLink(),
                  const SizedBox(height: 24),
                  Text('Third-party acknowledgements', style: text.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Built with Flutter, Dart, Serverpod and open-source '
                    'packages. Their licence notices are available below.',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => showLicensePage(
                      context: context,
                      applicationName: 'SafeCheck',
                    ),
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Third-party licences'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
