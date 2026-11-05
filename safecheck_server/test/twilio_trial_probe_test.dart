import 'dart:async';
import 'dart:convert';

import 'package:safecheck_server/src/messaging/bulk_sms_message_sender.dart';
import 'package:safecheck_server/src/messaging/message_dispatcher.dart';
import 'package:safecheck_server/src/messaging/twilio_trial_probe.dart';
import 'package:safecheck_server/src/messaging/twilio_diagnostics.dart';
import 'package:test/test.dart';

class _Transport implements BulkSmsTransport {
  Object result = BulkSmsHttpResponse(
    statusCode: 201,
    body: jsonEncode({'sid': 'SM${'b' * 32}', 'status': 'queued'}),
  );
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
  final sid = 'HX${'a' * 32}';
  TwilioTrialProbe probe(_Transport transport) => TwilioTrialProbe(
    accountSid: 'AC${'a' * 32}',
    authToken: 'synthetic-secret',
    from: '+14155550000',
    recipients: {'+27821234567'},
    transport: transport,
  );

  test(
    'default probe validates without sending and cannot be an outbox sender',
    () async {
      final transport = _Transport();
      final subject = probe(transport);
      final result = await subject.submit(
        recipient: '0821234567',
        contentSid: sid,
      );
      expect(result.status, TrialProbeStatus.dryRun);
      expect(transport.calls.length, 0);
      expect(subject, isNot(isA<MessageSender>()));
      expect(result.toSafeJson()['safetyAlertDelivered'], false);
    },
  );
  test('approved mock submission sends only trial fields', () async {
    final transport = _Transport();
    final result = await probe(
      transport,
    ).submit(recipient: '0821234567', contentSid: sid, approveRealSend: true);
    expect(result.status, TrialProbeStatus.accepted);
    final call = transport.calls.single;
    final form = Uri.splitQueryString(call.body);
    expect(form.keys.toSet(), {'From', 'To', 'ContentSid'});
    expect(form['ContentSid'], sid);
    expect(form.containsKey('Body'), false);
    expect(form.containsKey('ContentVariables'), false);
    expect(call.uri.host, 'api.twilio.com');
    expect(result.toSafeJson()['safetyAlertDelivered'], false);
  });
  test(
    'bad template or non-allowlisted recipient never reaches transport',
    () async {
      final transport = _Transport();
      final subject = probe(transport);
      for (final request in [
        (recipient: '0821234567', template: ''),
        (recipient: '0831234567', template: sid),
      ]) {
        expect(
          (await subject.submit(
            recipient: request.recipient,
            contentSid: request.template,
            approveRealSend: true,
          )).status,
          TrialProbeStatus.blocked,
        );
      }
      expect(transport.calls.length, 0);
    },
  );
  for (final code in [21654, 572002]) {
    test(
      'rejection preserves code $code without private response content',
      () async {
        final transport = _Transport()
          ..result = BulkSmsHttpResponse(
            statusCode: 400,
            body: jsonEncode({
              'code': code,
              'message': 'synthetic-secret private-recipient private-link',
            }),
          );
        final result = await probe(transport).submit(
          recipient: '0821234567',
          contentSid: sid,
          approveRealSend: true,
        );
        expect(result.status, TrialProbeStatus.rejected);
        expect(result.errorCode, code);
        expect(
          jsonEncode(result.toSafeJson()),
          isNot(contains('synthetic-secret')),
        );
        expect(
          jsonEncode(result.toSafeJson()),
          isNot(contains('private-recipient')),
        );
        expect(
          jsonEncode(result.toSafeJson()),
          isNot(contains('private-link')),
        );
      },
    );
  }
  test('uncertain submission cannot be retried on the same probe', () async {
    final transport = _Transport()..result = TimeoutException('private-secret');
    final subject = probe(transport);
    expect(
      (await subject.submit(
        recipient: '0821234567',
        contentSid: sid,
        approveRealSend: true,
      )).status,
      TrialProbeStatus.unknown,
    );
    expect(
      (await subject.submit(
        recipient: '0821234567',
        contentSid: sid,
        approveRealSend: true,
      )).status,
      TrialProbeStatus.blocked,
    );
    expect(transport.calls.length, 1);
  });
  test('successful probe cannot make a second submission either', () async {
    final transport = _Transport();
    final subject = probe(transport);
    await subject.submit(
      recipient: '0821234567',
      contentSid: sid,
      approveRealSend: true,
    );
    expect(
      (await subject.submit(
        recipient: '0821234567',
        contentSid: sid,
        approveRealSend: true,
      )).status,
      TrialProbeStatus.blocked,
    );
    expect(transport.calls.length, 1);
  });
  test('malformed error codes do not become diagnostic data', () {
    for (final body in [
      'not-json',
      '[]',
      '{"code":"private-value"}',
      '{"code":27821234567}',
    ]) {
      expect(twilioErrorCode(body), isNull);
    }
  });
}
