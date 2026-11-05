import 'dart:convert';
import 'dart:io';

import '../common/validation.dart';
import 'bulk_sms_message_sender.dart';
import 'twilio_diagnostics.dart';

enum TrialProbeStatus {
  dryRun,
  accepted,
  delivered,
  rejected,
  unknown,
  blocked,
}

/// A connectivity result, deliberately not a MessageSender/SendResult or model.
class TrialProbeResult {
  const TrialProbeResult(
    this.status, {
    this.httpStatus,
    this.errorCode,
    required this.reason,
  });
  final TrialProbeStatus status;
  final int? httpStatus;
  final int? errorCode;
  final String reason;

  Map<String, Object?> toSafeJson() => {
    'status': status.name,
    'httpStatus': httpStatus,
    'errorCode': errorCode,
    'reason': reason,
    'safetyAlertDelivered': false,
  };
}

/// Explicit, single-use template connectivity probe. It never reads or writes
/// safety alerts, messages, contacts, trips or SMS state.
class TwilioTrialProbe {
  TwilioTrialProbe({
    required String accountSid,
    required String authToken,
    required String from,
    required Set<String> recipients,
    BulkSmsTransport? transport,
  }) : _accountSid = accountSid.trim(),
       _authorization = base64Encode(
         utf8.encode('${accountSid.trim()}:${authToken.trim()}'),
       ),
       _from = from.trim(),
       _recipients = Set.unmodifiable(recipients.map(normalizeSaPhone)),
       _transport = transport ?? IoBulkSmsTransport() {
    if (!RegExp(r'^AC[0-9a-fA-F]{32}$').hasMatch(_accountSid) ||
        authToken.trim().isEmpty ||
        !RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(_from) ||
        _recipients.isEmpty) {
      throw ArgumentError(
        'Valid server-side trial probe configuration is required.',
      );
    }
  }
  final String _accountSid;
  final String _authorization;
  final String _from;
  final Set<String> _recipients;
  final BulkSmsTransport _transport;
  bool _attempted = false;

  Future<TrialProbeResult> submit({
    required String recipient,
    required String contentSid,
    bool approveRealSend = false,
  }) async {
    String normalized;
    try {
      normalized = normalizeSaPhone(recipient);
    } catch (_) {
      return const TrialProbeResult(
        TrialProbeStatus.blocked,
        reason: 'Invalid trial recipient.',
      );
    }
    if (!_recipients.contains(normalized) ||
        !RegExp(r'^HX[0-9a-fA-F]{32}$').hasMatch(contentSid)) {
      return const TrialProbeResult(
        TrialProbeStatus.blocked,
        reason:
            'An allowlisted recipient and Console-provided ContentSid are required.',
      );
    }
    if (!approveRealSend) {
      return const TrialProbeResult(
        TrialProbeStatus.dryRun,
        reason:
            'Validated locally. No request made; explicit send approval is required.',
      );
    }
    if (_attempted) {
      return const TrialProbeResult(
        TrialProbeStatus.blocked,
        reason:
            'This probe has already attempted a submission. No retry was made.',
      );
    }
    _attempted = true;
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
                'To': 'whatsapp:$normalized',
                'ContentSid': contentSid,
              },
            ).query,
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return TrialProbeResult(
          TrialProbeStatus.rejected,
          httpStatus: response.statusCode,
          errorCode: twilioErrorCode(response.body),
          reason: twilioRejectionReason(response.statusCode, response.body),
        );
      }
      if (response.body.length <= 16384) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map &&
            decoded['sid'] is String &&
            RegExp(
              r'^(SM|MM)[0-9a-fA-F]{32}$',
            ).hasMatch(decoded['sid'] as String)) {
          final status = decoded['status'];
          if (['delivered', 'read'].contains(status)) {
            return TrialProbeResult(
              TrialProbeStatus.delivered,
              httpStatus: response.statusCode,
              reason: 'Trial template delivered; this was not a safety alert.',
            );
          }
          if (['accepted', 'queued', 'sending', 'sent'].contains(status)) {
            return TrialProbeResult(
              TrialProbeStatus.accepted,
              httpStatus: response.statusCode,
              reason:
                  'Trial template accepted; delivery is unconfirmed and no safety alert was sent.',
            );
          }
          if (['failed', 'undelivered', 'canceled'].contains(status)) {
            return TrialProbeResult(
              TrialProbeStatus.rejected,
              httpStatus: response.statusCode,
              errorCode: twilioErrorCode(response.body),
              reason: 'Trial template delivery failed.',
            );
          }
        }
      }
    } catch (_) {
      /* Never expose headers, provider bodies or raw exceptions. */
    }
    return const TrialProbeResult(
      TrialProbeStatus.unknown,
      reason:
          'Trial submission outcome is unknown. No automatic retry was made.',
    );
  }
}
