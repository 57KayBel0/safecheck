import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../common/validation.dart';
import '../generated/protocol.dart';
import 'bulk_sms_message_sender.dart';
import 'message_dispatcher.dart';
import 'twilio_diagnostics.dart';

/// Restricted trial templates cannot carry the stored alert or incident link.
/// Failing this channel leaves the existing opted-in SMS fallback eligible.
class LimitedTrialMessageSender implements MessageSender {
  const LimitedTrialMessageSender({required this.fallback});
  final MessageSender fallback;

  @override
  Future<SendResult> send(Session session, AlertMessage message) =>
      message.channel == MessageChannel.whatsapp
      ? Future.value(
          const SendResult(
            MessageStatus.failed,
            failureReason:
                'Limited Trial cannot send SafeCheck alert content. Template probes are connectivity tests only.',
          ),
        )
      : fallback.send(session, message);
}

/// Sandbox-only WhatsApp transport. SMS retains its independently configured
/// sender. An allowlist prevents accidental submission to other contacts.
class TwilioWhatsAppMessageSender implements MessageSender {
  TwilioWhatsAppMessageSender({
    required String accountSid,
    required String authToken,
    required String from,
    required Set<String> recipients,
    required this.fallback,
    BulkSmsTransport? transport,
    DateTime Function()? now,
  }) : _accountSid = accountSid,
       _authorization = base64Encode(utf8.encode('$accountSid:$authToken')),
       _from = from,
       _recipients = Set.unmodifiable(recipients.map(normalizeSaPhone)),
       _transport = transport ?? IoBulkSmsTransport(),
       _now = now ?? DateTime.now,
       _activatedAt = (now ?? DateTime.now)().toUtc() {
    if (!RegExp(r'^AC[0-9a-fA-F]{32}$').hasMatch(accountSid) ||
        authToken.trim().isEmpty ||
        !RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(from) ||
        _recipients.isEmpty) {
      throw ArgumentError('Valid Twilio Sandbox configuration is required.');
    }
  }

  final String _accountSid;
  final String _authorization;
  final String _from;
  final Set<String> _recipients;
  final MessageSender fallback;
  final BulkSmsTransport _transport;
  final DateTime Function() _now;
  final DateTime _activatedAt;

  @override
  Future<SendResult> send(Session session, AlertMessage message) =>
      message.channel == MessageChannel.whatsapp
      ? sendMessage(message)
      : fallback.send(session, message);

  Future<SendResult> sendMessage(AlertMessage message) async {
    if (message.channel != MessageChannel.whatsapp) {
      return const SendResult(MessageStatus.simulated);
    }
    late final String recipient;
    try {
      recipient = normalizeSaPhone(message.recipientPhone);
    } on SafeCheckException {
      return _failed('WhatsApp recipient number is invalid.');
    }
    if (!_recipients.contains(recipient)) {
      return _failed('Recipient is not enabled for the WhatsApp Sandbox.');
    }
    final age = _now().toUtc().difference(message.createdAt.toUtc());
    if (message.id == null ||
        message.id! < 1 ||
        message.createdAt.toUtc().isBefore(_activatedAt) ||
        age.isNegative ||
        age > const Duration(minutes: 15)) {
      return _failed(
        'WhatsApp message is not eligible for Sandbox submission.',
      );
    }

    try {
      final response = await _transport
          .post(
            uri: Uri.https(
              'api.twilio.com',
              '/2010-04-01/Accounts/$_accountSid/Messages.json',
            ),
            headers: {
              HttpHeaders.authorizationHeader: 'Basic $_authorization',
              HttpHeaders.contentTypeHeader:
                  'application/x-www-form-urlencoded',
              HttpHeaders.acceptHeader: 'application/json',
            },
            body: Uri(
              queryParameters: {
                'From': 'whatsapp:$_from',
                'To': 'whatsapp:$recipient',
                'Body': message.body,
              },
            ).query,
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _failed(
          twilioRejectionReason(response.statusCode, response.body),
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> &&
          decoded['sid'] is String &&
          RegExp(r'^SM[0-9a-fA-F]{32}$').hasMatch(decoded['sid'] as String)) {
        switch (decoded['status']) {
          case 'accepted':
          case 'queued':
          case 'sending':
          case 'sent':
            // Existing "sent" means provider accepted, not delivered.
            return const SendResult(MessageStatus.sent);
          case 'delivered':
          case 'read':
            return const SendResult(MessageStatus.delivered);
          case 'failed':
          case 'undelivered':
            return _failed('Twilio reports WhatsApp delivery failed.');
        }
      }
    } catch (_) {
      // Never persist provider bodies, credentials, URLs or raw exceptions.
    }
    // Twilio message creation has no deduplication key here. Do not retry an
    // ambiguous POST automatically; it may already have been accepted.
    return _failed(
      'WhatsApp submission outcome is unknown; it was not retried automatically.',
    );
  }

  SendResult _failed(String reason) =>
      SendResult(MessageStatus.failed, failureReason: reason);
}

MessageSender twilioSandboxSenderForConfig({
  required MessageSender fallback,
  required String? mode,
  required String? accountSid,
  required String? authToken,
  required String? from,
  required String? recipients,
  BulkSmsTransport? transport,
  DateTime Function()? now,
}) {
  final selectedMode = mode?.trim().toLowerCase();
  if (selectedMode == 'limited-trial') {
    return LimitedTrialMessageSender(fallback: fallback);
  }
  if (selectedMode != 'sandbox' && selectedMode != 'legacy-sandbox') {
    return fallback;
  }
  try {
    return TwilioWhatsAppMessageSender(
      accountSid: accountSid ?? '',
      authToken: authToken ?? '',
      from: from ?? '',
      recipients: (recipients ?? '')
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toSet(),
      fallback: fallback,
      transport: transport,
      now: now,
    );
  } on ArgumentError {
    return fallback;
  } on SafeCheckException {
    return fallback;
  }
}
