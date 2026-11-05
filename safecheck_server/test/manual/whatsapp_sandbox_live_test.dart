// Explicit opt-in only: this test submits one real WhatsApp message.
import 'dart:convert';
import 'dart:io';

import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/common/validation.dart';
import 'package:safecheck_server/src/messaging/bulk_sms_message_sender.dart';
import 'package:safecheck_server/src/messaging/message_dispatcher.dart';
import 'package:safecheck_server/src/messaging/twilio_whatsapp_message_sender.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../integration/safecheck_test_helpers.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import 'twilio_verification_utils.dart';

class _RecordingTransport implements BulkSmsTransport {
  final _inner = IoBulkSmsTransport();
  String? sid;
  var submissions = 0;

  @override
  Future<BulkSmsHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    submissions++;
    final response = await _inner.post(uri: uri, headers: headers, body: body);
    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 400 && decoded is Map<String, dynamic>) {
        final code = decoded['code'];
        if (code is int && code >= 10000 && code < 100000) {
          stderr.writeln(
            'Twilio rejected the test submission: HTTP ${response.statusCode}, code $code.',
          );
        }
      }
      if (decoded is Map<String, dynamic> && decoded['sid'] is String) {
        final candidate = decoded['sid'] as String;
        if (RegExp(r'^SM[0-9a-fA-F]{32}$').hasMatch(candidate)) sid = candidate;
      }
    } catch (_) {
      // Never print private provider responses.
    }
    return response;
  }
}

Future<Map<String, dynamic>> _get(Uri uri, String authorization) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    return await (() async {
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      request.headers.set(HttpHeaders.authorizationHeader, authorization);
      final response = await request.close();
      if (response.statusCode != 200) {
        throw StateError('Twilio verification request was rejected.');
      }
      final bytes = <int>[];
      await for (final chunk in response) {
        if (bytes.length + chunk.length > 65536) {
          throw StateError('Twilio verification response exceeded its limit.');
        }
        bytes.addAll(chunk);
      }
      return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    })().timeout(const Duration(seconds: 20));
  } catch (_) {
    throw StateError(
      'Twilio verification failed; inspect the private console.',
    );
  } finally {
    client.close(force: true);
  }
}

void main() {
  if (Platform.environment['SAFECHECK_REAL_WHATSAPP_TEST'] != '1') {
    test(
      'controlled real Sandbox missed-check-in delivery',
      () {},
      skip:
          'Requires explicit SAFECHECK_REAL_WHATSAPP_TEST=1 and private configuration.',
    );
    return;
  }

  withServerpod('Controlled real Sandbox delivery', (builder, endpoints) {
    late String account;
    late String token;
    late String from;
    late String recipient;
    late String authorization;
    late MessageSender original;
    final transport = _RecordingTransport();
    final user = signedIn(builder, aliceId);

    setUpAll(() async {
      final passwords =
          loadYaml(File('config/passwords.yaml').readAsStringSync()) as Map;
      final values = <dynamic, dynamic>{
        ...?passwords['shared'] as Map?,
        ...?passwords['development'] as Map?,
      };
      String requiredValue(String name) {
        final value = values[name]?.toString().trim() ?? '';
        if (value.isEmpty) {
          throw StateError('Missing private configuration: $name');
        }
        return value;
      }

      if (requiredValue('twilioWhatsAppMode') != 'sandbox') {
        throw StateError('Sandbox mode must be enabled explicitly.');
      }
      account = requiredValue('twilioAccountSid');
      token = requiredValue('twilioAuthToken');
      from = requiredValue('twilioWhatsAppFrom');
      if (!RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(from)) {
        throw StateError('The configured WhatsApp test sender must be E.164.');
      }
      final recipients = requiredValue(
        'twilioWhatsAppSandboxRecipients',
      ).split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      if (recipients.length != 1) {
        throw StateError('Configure exactly one enrolled test recipient.');
      }
      recipient = normalizeSaPhone(recipients.single);
      authorization = 'Basic ${base64Encode(utf8.encode('$account:$token'))}';
      final inbound = await _get(
        Uri.https(
          'api.twilio.com',
          '/2010-04-01/Accounts/$account/Messages.json',
          {
            'From': 'whatsapp:$recipient',
            'To': 'whatsapp:$from',
            'PageSize': '1',
          },
        ),
        authorization,
      );
      final messages = inbound['messages'] as List? ?? [];
      if (messages.isEmpty) {
        throw StateError(
          'The enrolled recipient must first message this Sandbox.',
        );
      }
      final inboundRow = messages.first as Map;
      if (inboundRow['from'] != 'whatsapp:$recipient' ||
          inboundRow['to'] != 'whatsapp:$from' ||
          inboundRow['direction'] != 'inbound') {
        throw StateError(
          'The configured sender and recipient were not verified.',
        );
      }
      final sentAt =
          (inboundRow['date_sent'] ?? inboundRow['date_created']) as String?;
      if (sentAt == null ||
          DateTime.now().toUtc().difference(parseTwilioTimestamp(sentAt)) >=
              const Duration(hours: 24)) {
        throw StateError(
          'The recipient must reopen the 24-hour conversation window.',
        );
      }
    });

    setUp(() {
      original = MessageDispatcher.sender;
      MessageDispatcher.sender = TwilioWhatsAppMessageSender(
        accountSid: account,
        authToken: token,
        from: from,
        recipients: {recipient},
        transport: transport,
        fallback: const DemoMessageSender(),
      );
    });
    tearDown(() => MessageDispatcher.sender = original);

    test(
      'one fictional missed check-in reaches the enrolled recipient',
      () async {
        await endpoints.profile.saveProfile(
          user,
          'DEMO TEST - no emergency',
          recipient == '+27820000001' ? '+27820000002' : '+27820000001',
        );
        await endpoints.contact.add(
          user,
          'Consenting Sandbox tester',
          recipient,
          null,
        );
        final contact = (await endpoints.contact.list(user)).single;
        await TrustedContact.db.updateRow(
          builder.build(),
          contact.copyWith(
            optInStatus: ContactOptInStatus.accepted,
            notifyByWhatsapp: true,
            notifyBySms: false,
          ),
        );
        final trip = (await endpoints.trip.startTrip(
          user,
          TripType.walking,
          'Controlled fictional missed-check-in test; no emergency.',
          2,
        )).trip!;
        await expireTrip(builder, trip.id!);
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          trip.id!,
        );
        final rows = await endpoints.alert.listMessages(user);
        expect(rows.length, 1);
        expect(rows.single.channel, MessageChannel.whatsapp);
        expect([
          MessageStatus.sent,
          MessageStatus.delivered,
        ], contains(rows.single.status));
        expect(transport.submissions, 1);
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          trip.id!,
        );
        await MessageDispatcher.dispatchPending(builder.build());
        expect(transport.submissions, 1);
        expect((await endpoints.alert.listAlerts(user)).length, 1);
        final sid = transport.sid;
        if (sid == null) {
          throw StateError('Provider submission was not confirmed.');
        }
        String? status;
        for (var attempt = 0; attempt < 8; attempt++) {
          if (attempt > 0) {
            await Future<void>.delayed(const Duration(seconds: 3));
          }
          final result = await _get(
            Uri.https(
              'api.twilio.com',
              '/2010-04-01/Accounts/$account/Messages/$sid.json',
            ),
            authorization,
          );
          status = result['status'] as String?;
          if (['delivered', 'read', 'failed', 'undelivered'].contains(status)) {
            break;
          }
        }
        expect(
          ['delivered', 'read'],
          contains(status),
          reason:
              'Queued/submitted is not confirmed delivery. Check the private Twilio console.',
        );
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
