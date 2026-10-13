import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../client.dart';
import 'state_views.dart';

class PrivacyPolicyLink extends StatelessWidget {
  const PrivacyPolicyLink({super.key});

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      try {
        final opened = await launchUrl(publicWebOrigin.resolve('/privacy'));
        if (!opened && context.mounted) {
          showSnack(context, 'Could not open the privacy policy.', error: true);
        }
      } catch (_) {
        if (context.mounted) {
          showSnack(context, 'Could not open the privacy policy.', error: true);
        }
      }
    },
    child: const Text('Privacy policy'),
  );
}
