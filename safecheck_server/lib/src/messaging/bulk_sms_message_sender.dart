import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../common/validation.dart';
import '../generated/protocol.dart';
import 'message_dispatcher.dart';

const _bulkSmsBaseUri = 'https://api.bulksms.com/v1/messages';
const _deduplicationWindow = Duration(hours: 12);
const _requestTimeout = Duration(seconds: 20);

/// HTTP response from the BulkSMS transport, isolated for deterministic tests.
class BulkSmsHttpResponse {
  const BulkSmsHttpResponse({
    required this.statusCode,
    required this.body,
    this.contentType,
  });

  final int statusCode;
  final String body;
  final String? contentType;
}

/// The only HTTP operation the sender needs, allowing tests to avoid network
/// access entirely.
abstract interface class BulkSmsTransport {
  Future<BulkSmsHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  });
}

/// Production HTTPS transport for BulkSMS's JSON API.
class IoBulkSmsTransport implements BulkSmsTransport {
  IoBulkSmsTransport({
    HttpClient? client,
    this.timeout = _requestTimeout,
  }) : _client = client ?? HttpClient() {
    _client.connectionTimeout = timeout;
  }

  final HttpClient _client;
  final Duration timeout;

  @override
  Future<BulkSmsHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    HttpClientRequest? request;
    try {
      return await (() async {
        request = await _client.postUrl(uri);
        headers.forEach((name, value) => request!.headers.set(name, value));
        request!.write(body);
        final response = await request!.close();
        final responseBody = await utf8.decoder.bind(response).join();
        return BulkSmsHttpResponse(
          statusCode: response.statusCode,
          body: responseBody,
          contentType: response.headers.contentType?.mimeType,
        );
      })().timeout(timeout);
    } on TimeoutException {
      request?.abort();
      rethrow;
    }
  }
}

/// Sends SMS through BulkSMS. WhatsApp remains explicitly simulated, so the
/// dispatcher proceeds to SMS rather than mistaking a demo result for success.
class BulkSmsMessageSender implements MessageSender {
  BulkSmsMessageSender({
    required String tokenId,
    required String tokenSecret,
    BulkSmsTransport? transport,
    DateTime Function()? now,
  }) : _authorization = base64Encode(utf8.encode('$tokenId:$tokenSecret')),
       _transport = transport ?? IoBulkSmsTransport(),
       _now = now ?? DateTime.now,
       _activatedAt = (now ?? DateTime.now)().toUtc() {
    if (tokenId.trim().isEmpty || tokenSecret.trim().isEmpty) {
      throw ArgumentError('BulkSMS API token credentials are required.');
    }
  }

  final String _authorization;
  final BulkSmsTransport _transport;
  final DateTime Function() _now;
  final DateTime _activatedAt;

  @override
  Future<SendResult> send(Session session, AlertMessage message) =>
      sendMessage(message);

  /// Submits one persisted message. A timeout is left pending for a retry with
  /// the same provider deduplication ID; no provider response body is logged
  /// or copied into the message failure reason.
  Future<SendResult> sendMessage(AlertMessage message) async {
    if (message.channel != MessageChannel.sms) {
      return const SendResult(MessageStatus.simulated);
    }

    final messageId = message.id;
    if (messageId == null || messageId < 1 || messageId > 2147483647) {
      return const SendResult(
        MessageStatus.failed,
        failureReason:
            'SMS could not be submitted because its message ID is invalid.',
      );
    }

    if (message.createdAt.toUtc().isBefore(_activatedAt)) {
      return const SendResult(
        MessageStatus.failed,
        failureReason:
            'SMS was created before live sending was enabled; it was not submitted.',
      );
    }

    if (_now().toUtc().difference(message.createdAt.toUtc()) >
        _deduplicationWindow) {
      return const SendResult(
        MessageStatus.failed,
        failureReason:
            'SMS expired before live dispatch; it was not submitted.',
      );
    }

    late final String recipient;
    try {
      recipient = normalizeSaPhone(message.recipientPhone);
    } on SafeCheckException {
      return const SendResult(
        MessageStatus.failed,
        failureReason: 'SMS recipient number is invalid.',
      );
    }

    final uri = Uri.parse(_bulkSmsBaseUri).replace(
      queryParameters: {'deduplication-id': '$messageId'},
    );
    final headers = <String, String>{
      HttpHeaders.authorizationHeader: 'Basic $_authorization',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    // POST /messages accepts a batch array, including for a single message.
    // A simple object is only accepted by the separate /messages/send route.
    final body = jsonEncode([
      {
        'to': [recipient],
        'body': message.body,
      },
    ]);

    late final BulkSmsHttpResponse response;
    try {
      response = await _transport
          .post(uri: uri, headers: headers, body: body)
          .timeout(_requestTimeout);
    } on TimeoutException {
      return const SendResult(
        MessageStatus.pending,
        failureReason:
            'BulkSMS submission timed out; its outcome is uncertain and will be retried safely.',
      );
    } catch (_) {
      return const SendResult(
        MessageStatus.pending,
        failureReason:
            'BulkSMS could not be reached; its outcome is uncertain and will be retried safely.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return _rejectedResponse(response);
    }

    return _acceptedResponse(response);
  }

  SendResult _rejectedResponse(BulkSmsHttpResponse response) {
    if (response.statusCode == 408 ||
        response.statusCode == 429 ||
        response.statusCode >= 500) {
      return const SendResult(
        MessageStatus.pending,
        failureReason:
            'BulkSMS could not confirm the submission; it will be retried safely.',
      );
    }

    final errorType = _errorType(response.body);
    if (response.statusCode == 401) {
      return const SendResult(
        MessageStatus.failed,
        failureReason: 'BulkSMS rejected the API credentials.',
      );
    }
    if (_hasErrorType(errorType, 'insufficient-credits')) {
      return const SendResult(
        MessageStatus.failed,
        failureReason: 'BulkSMS account has insufficient credits.',
      );
    }
    if (_hasErrorType(errorType, 'insufficient-quota')) {
      return const SendResult(
        MessageStatus.failed,
        failureReason: 'BulkSMS account has insufficient sending quota.',
      );
    }
    if (response.statusCode == 400) {
      return const SendResult(
        MessageStatus.failed,
        failureReason: 'BulkSMS rejected the recipient or message.',
      );
    }

    return const SendResult(
      MessageStatus.failed,
      failureReason: 'BulkSMS rejected the SMS submission.',
    );
  }

  SendResult _acceptedResponse(BulkSmsHttpResponse response) {
    if (response.contentType?.toLowerCase().contains('json') != true) {
      return _uncertainResponse();
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.length != 1) {
        return _uncertainResponse();
      }
      final entry = decoded.single;
      if (entry is! Map<String, dynamic>) return _uncertainResponse();
      final status = entry['status'];
      if (status is! Map<String, dynamic> || status['type'] is! String) {
        return _uncertainResponse();
      }

      switch ((status['type'] as String).toUpperCase()) {
        case 'ACCEPTED':
        case 'SENT':
          return const SendResult(MessageStatus.sent);
        case 'DELIVERED':
          return const SendResult(MessageStatus.delivered);
        case 'FAILED':
          return const SendResult(
            MessageStatus.failed,
            failureReason:
                'BulkSMS accepted the request but reports that delivery failed.',
          );
        default:
          return _uncertainResponse();
      }
    } catch (_) {
      return _uncertainResponse();
    }
  }

  SendResult _uncertainResponse() => const SendResult(
    MessageStatus.pending,
    failureReason:
        'BulkSMS returned an unreadable submission response; its outcome is uncertain and will be retried safely.',
  );

  String _errorType(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['type'] is String) {
        return decoded['type'] as String;
      }
    } catch (_) {
      // Provider error content is deliberately not copied into logs or rows.
    }
    return '';
  }

  bool _hasErrorType(String value, String code) {
    final normalized = value.toLowerCase();
    return normalized == code ||
        normalized.endsWith('/$code') ||
        normalized.endsWith('#$code');
  }
}

/// Builds the sender from explicitly named Serverpod password values. Missing
/// mode or credentials always leaves the no-send demo sender active.
MessageSender messageSenderForConfig({
  required String? mode,
  required String? tokenId,
  required String? tokenSecret,
  BulkSmsTransport? transport,
  DateTime Function()? now,
}) {
  if (mode?.trim().toLowerCase() != 'live' ||
      tokenId?.trim().isNotEmpty != true ||
      tokenSecret?.trim().isNotEmpty != true) {
    return const DemoMessageSender();
  }

  return BulkSmsMessageSender(
    tokenId: tokenId!,
    tokenSecret: tokenSecret!,
    transport: transport,
    now: now,
  );
}
