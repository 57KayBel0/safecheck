import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

enum SafetyNotificationEvent {
  tripStarted,
  arrivedAtDestination,
  safeConfirmed,
  checkInOverdue,
  emergencyTriggered,
}

class SafetyNotificationRequest {
  final TrustedContact contact;
  final SafetyNotificationEvent event;
  final String userDisplayName;
  final DateTime occurredAt;
  final String? locationText;
  final String? trackingUrl;
  final Duration? tripDuration;

  SafetyNotificationRequest({
    required this.contact,
    required this.event,
    required this.userDisplayName,
    required this.occurredAt,
    this.locationText,
    this.trackingUrl,
    this.tripDuration,
  });
}

class SafetyNotificationService {
  static Future<void> send(
    Session session,
    SafetyNotificationRequest request,
  ) async {
    final contact = request.contact;

    if (contact.optInStatus != ContactOptInStatus.accepted) {
      session.log(
        'Skipping notification for ${contact.phoneNumber}: '
        'trusted contact has not accepted alerts.',
        level: LogLevel.info,
      );
      return;
    }

    final message = _buildMessage(request);

    var whatsappSent = false;

    if (contact.notifyByWhatsapp) {
      whatsappSent = await _sendWhatsApp(
        session,
        phoneNumber: contact.phoneNumber,
        message: message,
      );
    }

    if ((!whatsappSent || !contact.notifyByWhatsapp) && contact.notifyBySms) {
      await _sendSms(
        session,
        phoneNumber: contact.phoneNumber,
        message: message,
      );
    }
  }

  static String _buildMessage(SafetyNotificationRequest request) {
    final durationText = request.tripDuration == null
        ? null
        : '${request.tripDuration!.inMinutes} minutes';

    switch (request.event) {
      case SafetyNotificationEvent.tripStarted:
        return '''
SafeCheck update

${request.userDisplayName} has started a safety trip.
${request.locationText != null ? 'Location: ${request.locationText}' : ''}
${request.trackingUrl != null ? 'Track trip: ${request.trackingUrl}' : ''}
'''
            .trim();

      case SafetyNotificationEvent.arrivedAtDestination:
        return '''
SafeCheck update

${request.userDisplayName} appears to have arrived at the selected destination.
${durationText != null ? 'Trip duration: $durationText' : ''}
${request.locationText != null ? 'Location: ${request.locationText}' : ''}
Safe confirmation is still pending.
'''
            .trim();

      case SafetyNotificationEvent.safeConfirmed:
        return '''
SafeCheck confirmation

${request.userDisplayName} has confirmed that they are safe.
${durationText != null ? 'Trip duration: $durationText' : ''}
${request.locationText != null ? 'Location: ${request.locationText}' : ''}
'''
            .trim();

      case SafetyNotificationEvent.checkInOverdue:
        return '''
SafeCheck alert

${request.userDisplayName} has missed their expected check-in.
${durationText != null ? 'Trip duration: $durationText' : ''}
${request.locationText != null ? 'Last known location: ${request.locationText}' : ''}
${request.trackingUrl != null ? 'View live or last known location: ${request.trackingUrl}' : ''}
'''
            .trim();

      case SafetyNotificationEvent.emergencyTriggered:
        return '''
SafeCheck emergency

${request.userDisplayName} may need assistance.
${request.locationText != null ? 'Last known location: ${request.locationText}' : ''}
${request.trackingUrl != null ? 'View location and trip route: ${request.trackingUrl}' : ''}
'''
            .trim();
    }
  }

  static Future<bool> _sendWhatsApp(
    Session session, {
    required String phoneNumber,
    required String message,
  }) async {
    session.log(
      'WhatsApp placeholder -> $phoneNumber: $message',
      level: LogLevel.info,
    );

    return false;
  }

  static Future<void> _sendSms(
    Session session, {
    required String phoneNumber,
    required String message,
  }) async {
    session.log(
      'SMS placeholder -> $phoneNumber: $message',
      level: LogLevel.info,
    );
  }
}
