import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'state_views.dart';

/// Finds the tracking URL stored in an alert message, preserving its exact text.
String? trackingUrlInMessage(String body) {
  // The server appends the recipient's tracking link after the description.
  // Search backwards so a URL mentioned in the description cannot replace it.
  final urls = RegExp(r'''https?://[^\s<>"']+''').allMatches(body).toList();
  for (final match in urls.reversed) {
    final original = match.group(0)!;
    final uri = Uri.tryParse(original);
    if (uri != null &&
        uri.host.isNotEmpty &&
        uri.pathSegments.length == 2 &&
        uri.pathSegments.first == 't' &&
        uri.pathSegments.last.isNotEmpty) {
      return original;
    }
  }
  return null;
}

class CopyTrackingLinkButton extends StatelessWidget {
  const CopyTrackingLinkButton({super.key, required this.messageBody});

  final String messageBody;

  @override
  Widget build(BuildContext context) {
    final url = trackingUrlInMessage(messageBody);
    if (url == null) {
      return const SizedBox.shrink();
    }
    return TextButton.icon(
      icon: const Icon(Icons.copy),
      label: const Text('Copy tracking link'),
      onPressed: () async {
        try {
          await Clipboard.setData(ClipboardData(text: url));
          if (context.mounted) {
            showSnack(context, 'Tracking link copied.');
          }
        } catch (_) {
          if (context.mounted) {
            showSnack(
              context,
              'Could not copy tracking link. Please try again.',
              error: true,
            );
          }
        }
      },
    );
  }
}
