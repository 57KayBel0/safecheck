import 'dart:convert';
import 'dart:io';

import 'package:safecheck_server/src/common/validation.dart';
import 'package:safecheck_server/src/messaging/twilio_trial_probe.dart';
import 'package:yaml/yaml.dart';

/// Uses existing server credentials and a local Console reference. Dry-run
/// unless --approve-real-send is explicitly supplied after owner approval.
Future<void> main(List<String> args) async {
  try {
    final root =
        loadYaml(File('config/passwords.yaml').readAsStringSync()) as Map;
    final values = <dynamic, dynamic>{
      ...?root['shared'] as Map?,
      ...?root['development'] as Map?,
    };
    final reference = File('../.dart_tool/twilio_trial_reference.json');
    if (!reference.existsSync()) {
      stdout.writeln(
        jsonEncode({
          'probeReady': false,
          'consoleReferenceAvailable': false,
          'networkRequests': 0,
          'safetyAlertDelivered': false,
        }),
      );
      exitCode = 2;
      return;
    }
    final data = jsonDecode(reference.readAsStringSync()) as Map;
    Object? field(String name) {
      final keys = data.keys
          .where((k) => k.toString().toLowerCase() == name.toLowerCase())
          .toList();
      return keys.length == 1 ? data[keys.single] : null;
    }

    final allowedFields = data.keys.every(
      (key) =>
          {'from', 'to', 'contentsid'}.contains(key.toString().toLowerCase()),
    );
    String channelNumber(Object? value) => (value?.toString().trim() ?? '')
        .replaceFirst(RegExp(r'^whatsapp:', caseSensitive: false), '');
    final from = values['twilioWhatsAppFrom']?.toString().trim() ?? '';
    final recipient = normalizeSaPhone(channelNumber(field('To')));
    final recipients =
        (values['twilioWhatsAppSandboxRecipients']?.toString() ?? '')
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map(normalizeSaPhone)
            .toSet();
    final senderMatches = channelNumber(field('From')) == from;
    if (!allowedFields || !senderMatches || !recipients.contains(recipient)) {
      stdout.writeln(
        jsonEncode({
          'probeReady': false,
          'allowedReferenceFields': allowedFields,
          'senderMatches': senderMatches,
          'recipientAllowed': recipients.contains(recipient),
          'networkRequests': 0,
        }),
      );
      exitCode = 2;
      return;
    }
    final probe = TwilioTrialProbe(
      accountSid: values['twilioAccountSid']?.toString() ?? '',
      authToken: values['twilioAuthToken']?.toString() ?? '',
      from: from,
      recipients: recipients,
    );
    final result = await probe.submit(
      recipient: recipient,
      contentSid: field('ContentSid')?.toString().trim() ?? '',
      approveRealSend: args.contains('--approve-real-send'),
    );
    stdout.writeln(jsonEncode(result.toSafeJson()));
    if ([
      TrialProbeStatus.blocked,
      TrialProbeStatus.rejected,
      TrialProbeStatus.unknown,
    ].contains(result.status)) {
      exitCode = 1;
    }
  } catch (error) {
    stdout.writeln(
      jsonEncode({
        'safeProbeErrorType': error.runtimeType.toString(),
        'safetyAlertDelivered': false,
      }),
    );
    exitCode = 1;
  }
}
