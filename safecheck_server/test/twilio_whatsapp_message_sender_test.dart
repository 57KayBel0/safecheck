import 'dart:async';
import 'dart:convert';

import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/messaging/bulk_sms_message_sender.dart';
import 'package:safecheck_server/src/messaging/message_dispatcher.dart';
import 'package:safecheck_server/src/messaging/twilio_whatsapp_message_sender.dart';
import 'package:test/test.dart';

class FakeTransport implements BulkSmsTransport {
  FakeTransport(this.result);
  final Object result;
  final calls = <({Uri uri, Map<String, String> headers, String body})>[];

  @override
  Future<BulkSmsHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    calls.add((uri: uri, headers: headers, body: body));
    if (result is Exception) throw result;
    return result as BulkSmsHttpResponse;
  }
}

void main() {
  final now = DateTime.utc(2026, 11, 3);
  final account = 'AC${List.filled(32, 'a').join()}';
  final sid = 'SM${List.filled(32, 'b').join()}';
  AlertMessage message({String phone = '0821234567', DateTime? createdAt}) =>
      AlertMessage(
        id: 1,
        ownerId: 'owner',
        alertId: 1,
        tripId: 1,
        recipientName: 'Contact',
        recipientPhone: phone,
        body: 'SafeCheck: missed check-in.\nhttps://example.com/incident/token',
        channel: MessageChannel.whatsapp,
        status: MessageStatus.pending,
        createdAt: createdAt ?? now,
      );
  TwilioWhatsAppMessageSender sender(FakeTransport transport) =>
      TwilioWhatsAppMessageSender(
        accountSid: account,
        authToken: 'fake-secret',
        from: '+14155238886',
        recipients: {'+27821234567'},
        fallback: const DemoMessageSender(),
        transport: transport,
        now: () => now,
      );

  test('Sandbox requires explicit mode and complete configuration', () {
    const demo = DemoMessageSender();
    expect(
      twilioSandboxSenderForConfig(
        fallback: demo,
        mode: null,
        accountSid: account,
        authToken: 'fake-secret',
        from: '+14155238886',
        recipients: '+27821234567',
      ),
      same(demo),
    );
    expect(
      twilioSandboxSenderForConfig(
        fallback: demo,
        mode: 'sandbox',
        accountSid: account,
        authToken: null,
        from: '+14155238886',
        recipients: '+27821234567',
      ),
      same(demo),
    );
  });

  test('submits form with WhatsApp addresses and exact body', () async {
    final transport = FakeTransport(
      BulkSmsHttpResponse(
        statusCode: 201,
        body: jsonEncode({'sid': sid, 'status': 'queued'}),
      ),
    );
    final result = await sender(transport).sendMessage(message());
    expect(result.status, MessageStatus.sent);
    expect(result.status, isNot(MessageStatus.delivered));
    final call = transport.calls.single;
    expect(call.uri.host, 'api.twilio.com');
    expect(call.uri.path, '/2010-04-01/Accounts/$account/Messages.json');
    expect(
      call.headers['authorization'],
      'Basic ${base64Encode(utf8.encode('$account:fake-secret'))}',
    );
    final form = Uri.splitQueryString(call.body);
    expect(form['From'], 'whatsapp:+14155238886');
    expect(form['To'], 'whatsapp:+27821234567');
    expect(form['Body'], message().body);
  });

  test('unlisted contacts and old messages make no request', () async {
    final transport = FakeTransport(TimeoutException('unused'));
    final configured = sender(transport);
    expect(
      (await configured.sendMessage(message(phone: '0831234567'))).status,
      MessageStatus.failed,
    );
    expect(
      (await configured.sendMessage(
        message(
          createdAt: now.subtract(const Duration(seconds: 1)),
        ),
      )).status,
      MessageStatus.failed,
    );
    expect(transport.calls, isEmpty);
  });

  test(
    'ambiguous and rejected submissions are sanitized and terminal',
    () async {
      for (final response in <Object>[
        TimeoutException('fake-secret'),
        const BulkSmsHttpResponse(statusCode: 401, body: 'fake-secret'),
        const BulkSmsHttpResponse(statusCode: 201, body: 'fake-secret'),
      ]) {
        final transport = FakeTransport(response);
        final result = await sender(transport).sendMessage(message());
        expect(result.status, MessageStatus.failed);
        expect(result.failureReason, isNot(contains('fake-secret')));
        expect(transport.calls, hasLength(1));
      }
    },
  );
}
