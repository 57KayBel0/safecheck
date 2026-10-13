import 'dart:async';
import 'dart:convert';

import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/common/links.dart';
import 'package:safecheck_server/src/messaging/bulk_sms_message_sender.dart';
import 'package:safecheck_server/src/messaging/message_dispatcher.dart';
import 'package:safecheck_server/src/trips/trip_service.dart';
import 'package:test/test.dart';

class FakeBulkSmsTransport implements BulkSmsTransport {
  FakeBulkSmsTransport(this.results);

  final List<Object> results;
  final calls = <({Uri uri, Map<String, String> headers, String body})>[];

  @override
  Future<BulkSmsHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    calls.add((uri: uri, headers: headers, body: body));
    final result = results.removeAt(0);
    if (result is Exception) throw result;
    return result as BulkSmsHttpResponse;
  }
}

final _now = DateTime.utc(2026, 10, 9, 10);
const _trackingUrl = 'https://safecheck.example/t/exact-token-from-row';

AlertMessage _sms({
  int id = 41,
  MessageChannel channel = MessageChannel.sms,
  String recipient = '082 123 4567',
  DateTime? createdAt,
  String? body,
}) => AlertMessage(
  id: id,
  ownerId: 'owner',
  alertId: 1,
  tripId: 1,
  recipientName: 'Test Contact',
  recipientPhone: recipient,
  channel: channel,
  status: MessageStatus.pending,
  body: body ?? 'Please check in. Track here: $_trackingUrl',
  createdAt: createdAt ?? _now,
);

BulkSmsHttpResponse _acceptedResponse() => BulkSmsHttpResponse(
  statusCode: 200,
  contentType: 'application/json',
  body: jsonEncode([
    {
      'id': 'provider-message-id',
      'status': {'type': 'ACCEPTED'},
    },
  ]),
);

void main() {
  test(
    'configured production URL survives message composition and mocked submission',
    () async {
      const storedToken = 'mock-existing-token';
      final url = configuredPublicWebUrl(
        origin: Uri.parse('https://safecheck.serverpod.space'),
        path: '/t/$storedToken',
        runMode: 'production',
      );
      final body = alertMessageBody(
        travellerName: 'Mock traveller',
        trackingUrl: url,
      );
      expect(
        body,
        'SafeCheck: Mock traveller missed check-in.\nTrack:\nhttps://safecheck.serverpod.space/t/$storedToken',
      );
      final transport = FakeBulkSmsTransport([_acceptedResponse()]);
      final sender = BulkSmsMessageSender(
        tokenId: 'mock-id',
        tokenSecret: 'mock-secret',
        transport: transport,
        now: () => _now,
      );
      await sender.sendMessage(_sms(body: body));
      final payload =
          (jsonDecode(transport.calls.single.body) as List).single
              as Map<String, dynamic>;
      expect(payload['body'], body);
      expect((payload['body'] as String).split('\n').last, url);
      expect(RegExp(r'\s').hasMatch(url), false);
    },
  );
  test('missing live opt-in or credentials keeps demo mode active', () {
    expect(
      messageSenderForConfig(
        mode: null,
        tokenId: null,
        tokenSecret: null,
      ),
      isA<DemoMessageSender>(),
    );
    expect(
      messageSenderForConfig(
        mode: 'live',
        tokenId: 'test-token-id',
        tokenSecret: null,
      ),
      isA<DemoMessageSender>(),
    );
  });

  test(
    'uses token Basic Auth, E.164 phone, exact body and stable dedupe ID',
    () async {
      final transport = FakeBulkSmsTransport([_acceptedResponse()]);
      final sender = BulkSmsMessageSender(
        tokenId: 'test-token-id',
        tokenSecret: 'test-token-secret',
        transport: transport,
        now: () => _now,
      );

      final result = await sender.sendMessage(_sms());

      expect(result.status, MessageStatus.sent);
      expect(result.status, isNot(MessageStatus.delivered));
      expect(transport.calls, hasLength(1));
      final call = transport.calls.single;
      expect(call.uri.scheme, 'https');
      expect(call.uri.host, 'api.bulksms.com');
      expect(call.uri.path, '/v1/messages');
      expect(call.uri.queryParameters['deduplication-id'], '41');
      expect(
        call.headers.entries
            .singleWhere((entry) => entry.key.toLowerCase() == 'authorization')
            .value,
        'Basic ${base64Encode(utf8.encode('test-token-id:test-token-secret'))}',
      );
      final payload =
          (jsonDecode(call.body) as List).single as Map<String, dynamic>;
      expect(payload['to'], ['+27821234567']);
      expect(payload['body'], 'Please check in. Track here: $_trackingUrl');
    },
  );

  test(
    'concise alert keeps the exact URL through mocked BulkSMS submission',
    () async {
      final travellerName = List.filled(40, 'Traveller 名🙂').join();
      final longUnicodeDescription = List.filled(
        50,
        'Via the 🚕 and train 名 ',
      ).join();
      final composedBody = alertMessageBody(
        travellerName: travellerName,
        trackingUrl: _trackingUrl,
      );

      expect(composedBody, startsWith('SafeCheck: $travellerName '));
      expect(composedBody, contains('missed check-in'));
      expect(composedBody, endsWith('Track:\n$_trackingUrl'));
      expect(composedBody.split('\n').last, _trackingUrl);
      expect(RegExp(r'\s').hasMatch(composedBody.split('\n').last), false);
      expect(composedBody.split(_trackingUrl), hasLength(2));
      expect(composedBody, isNot(contains(longUnicodeDescription)));

      final transport = FakeBulkSmsTransport([_acceptedResponse()]);
      final sender = BulkSmsMessageSender(
        tokenId: 'test-token-id',
        tokenSecret: 'test-token-secret',
        transport: transport,
        now: () => _now,
      );

      final result = await sender.sendMessage(_sms(body: composedBody));

      expect(result.status, MessageStatus.sent);
      expect(transport.calls, hasLength(1));
      final payload =
          (jsonDecode(transport.calls.single.body) as List).single
              as Map<String, dynamic>;
      expect(payload['body'], composedBody);
      expect(payload['body'], endsWith('Track:\n$_trackingUrl'));
      expect((payload['body'] as String).split('\n').last, _trackingUrl);
    },
  );

  test('WhatsApp stays simulated and makes no HTTP request', () async {
    final transport = FakeBulkSmsTransport([]);
    final sender = BulkSmsMessageSender(
      tokenId: 'test-token-id',
      tokenSecret: 'test-token-secret',
      transport: transport,
      now: () => _now,
    );

    final result = await sender.sendMessage(
      _sms(channel: MessageChannel.whatsapp),
    );

    expect(result.status, MessageStatus.simulated);
    expect(transport.calls, isEmpty);
  });

  test('ambiguous timeout retries with the same provider dedupe ID', () async {
    final transport = FakeBulkSmsTransport([
      TimeoutException('test timeout'),
      _acceptedResponse(),
    ]);
    final sender = BulkSmsMessageSender(
      tokenId: 'test-token-id',
      tokenSecret: 'test-token-secret',
      transport: transport,
      now: () => _now,
    );

    expect((await sender.sendMessage(_sms())).status, MessageStatus.pending);
    expect((await sender.sendMessage(_sms())).status, MessageStatus.sent);
    expect(transport.calls, hasLength(2));
    expect(
      transport.calls.map(
        (call) => call.uri.queryParameters['deduplication-id'],
      ),
      everyElement('41'),
    );
  });

  test('insufficient credits are a sanitized terminal rejection', () async {
    const secret = 'test-token-secret';
    const trackingToken = 'exact-token-from-row';
    final transport = FakeBulkSmsTransport([
      const BulkSmsHttpResponse(
        statusCode: 403,
        contentType: 'application/problem+json',
        body:
            '{"type":"https://developer.bulksms.com/json/v1/errors#insufficient-credits",'
            '"detail":"$secret $trackingToken"}',
      ),
    ]);
    final sender = BulkSmsMessageSender(
      tokenId: 'test-token-id',
      tokenSecret: secret,
      transport: transport,
      now: () => _now,
    );

    final result = await sender.sendMessage(_sms());

    expect(result.status, MessageStatus.failed);
    expect(result.failureReason, contains('insufficient credits'));
    expect(result.failureReason, isNot(contains(secret)));
    expect(result.failureReason, isNot(contains(trackingToken)));
  });

  test(
    'malformed success response remains uncertain, never delivered',
    () async {
      final transport = FakeBulkSmsTransport([
        const BulkSmsHttpResponse(
          statusCode: 200,
          contentType: 'application/json',
          body: '{not json}',
        ),
      ]);
      final sender = BulkSmsMessageSender(
        tokenId: 'test-token-id',
        tokenSecret: 'test-token-secret',
        transport: transport,
        now: () => _now,
      );

      final result = await sender.sendMessage(_sms());

      expect(result.status, MessageStatus.pending);
      expect(result.status, isNot(MessageStatus.delivered));
      expect(result.failureReason, isNot(contains(_trackingUrl)));
    },
  );

  test(
    'old pending alerts are not submitted after the dedupe window',
    () async {
      final transport = FakeBulkSmsTransport([]);
      final sender = BulkSmsMessageSender(
        tokenId: 'test-token-id',
        tokenSecret: 'test-token-secret',
        transport: transport,
        now: () => _now,
      );

      final result = await sender.sendMessage(
        _sms(createdAt: _now.subtract(const Duration(hours: 13))),
      );

      expect(result.status, MessageStatus.failed);
      expect(transport.calls, isEmpty);
    },
  );

  test(
    'pending rows from before live mode was enabled are not submitted',
    () async {
      final transport = FakeBulkSmsTransport([]);
      final sender = BulkSmsMessageSender(
        tokenId: 'test-token-id',
        tokenSecret: 'test-token-secret',
        transport: transport,
        now: () => _now,
      );

      final result = await sender.sendMessage(
        _sms(createdAt: _now.subtract(const Duration(minutes: 1))),
      );

      expect(result.status, MessageStatus.failed);
      expect(transport.calls, isEmpty);
    },
  );
}
