import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Outcome of handing one message to a [MessageSender].
class SendResult {
  const SendResult(this.status, {this.failureReason});

  final MessageStatus status;
  final String? failureReason;
}

/// Delivers [AlertMessage]s over their channel. The configured sender may be
/// demo-only or may deliver SMS through an explicitly enabled provider.
abstract interface class MessageSender {
  Future<SendResult> send(Session session, AlertMessage message);
}

/// Sends nothing. Every message is marked `simulated`, which the app shows as
/// "Demo — SMS not sent" / "Demo — WhatsApp not sent".
class DemoMessageSender implements MessageSender {
  const DemoMessageSender();

  @override
  Future<SendResult> send(Session session, AlertMessage message) async {
    session.log(
      'DEMO: not sending ${message.channel.name} message ${message.id} '
      'to ${message.recipientPhone}.',
    );
    return const SendResult(MessageStatus.simulated);
  }
}

/// Hands `pending` messages to the sender. Messages are written as `pending`
/// in the alert's transaction, so a crash between saving and sending leaves
/// them for the next dispatch (an outbox).
abstract final class MessageDispatcher {
  /// The demo sender is the default; live SMS is selected only at startup when
  /// explicitly configured with valid server-side credentials.
  static MessageSender sender = const DemoMessageSender();

  /// Messages stuck in `sending` longer than this are retried.
  static const sendingTimeout = Duration(minutes: 5);

  /// Dispatches pending messages, optionally only those of [alertId].
  ///
  /// For each recipient:
  /// 1. WhatsApp is attempted first.
  /// 2. If WhatsApp succeeds, the SMS fallback is marked `skipped`.
  /// 3. If WhatsApp fails or is only simulated, SMS is attempted.
  /// 4. If there is no WhatsApp message, SMS is sent normally.
  static Future<int> dispatchPending(
    Session session, {
    int? alertId,
  }) async {
    final pending = await AlertMessage.db.find(
      session,
      where: (t) {
        final isPending = t.status.equals(MessageStatus.pending);
        return alertId == null
            ? isPending
            : isPending & t.alertId.equals(alertId);
      },
      orderBy: (t) => t.id,
      limit: 100,
    );

    // Group pending messages by alert + recipient.
    final groups = <String, List<AlertMessage>>{};

    for (final message in pending) {
      final key = '${message.alertId}:${message.recipientPhone}';
      groups.putIfAbsent(key, () => []).add(message);
    }

    var dispatched = 0;

    for (final group in groups.values) {
      final sample = group.first;

      // Re-read all channel rows for this recipient. This is important because
      // WhatsApp may already have succeeded on a previous dispatcher run while
      // the SMS fallback is still pending.
      final allMessages = await AlertMessage.db.find(
        session,
        where: (t) =>
            t.alertId.equals(sample.alertId) &
            t.recipientPhone.equals(sample.recipientPhone),
        orderBy: (t) => t.id,
      );

      AlertMessage? whatsapp;
      AlertMessage? sms;

      for (final message in allMessages) {
        switch (message.channel) {
          case MessageChannel.whatsapp:
            whatsapp = message;
            break;
          case MessageChannel.sms:
            sms = message;
            break;
        }
      }

      var whatsappSucceeded = false;
      var whatsappStillSending = false;

      if (whatsapp != null) {
        switch (whatsapp.status) {
          case MessageStatus.sent:
          case MessageStatus.delivered:
            whatsappSucceeded = true;
            break;

          case MessageStatus.sending:
            whatsappStillSending = true;
            break;

          case MessageStatus.pending:
            final result = await _dispatchOne(session, whatsapp);
            // A lost claim says nothing about delivery. The dispatcher that
            // owns WhatsApp must finish before anyone considers its fallback.
            if (result == null) {
              continue;
            }
            dispatched++;

            whatsappSucceeded =
                result.status == MessageStatus.sent ||
                result.status == MessageStatus.delivered;
            break;

          case MessageStatus.failed:
          case MessageStatus.simulated:
          case MessageStatus.skipped:
            // WhatsApp did not actually deliver, so SMS may be used.
            break;
        }
      }

      if (sms == null) {
        continue;
      }

      if (whatsappSucceeded) {
        if (sms.status == MessageStatus.pending) {
          await AlertMessage.db.updateWhere(
            session,
            columnValues: (t) => [
              t.status(MessageStatus.skipped),
              t.statusUpdatedAt(DateTime.now().toUtc()),
              t.failureReason(null),
            ],
            where: (t) =>
                t.id.equals(sms!.id) & t.status.equals(MessageStatus.pending),
          );
        }

        continue;
      }

      // Don't fire SMS while another dispatcher is actively sending WhatsApp.
      if (whatsappStillSending) {
        continue;
      }

      if (sms.status == MessageStatus.pending) {
        if (await _dispatchOne(session, sms) != null) {
          dispatched++;
        }
      }
    }

    return dispatched;
  }

  static Future<SendResult?> _dispatchOne(
    Session session,
    AlertMessage message,
  ) async {
    final claimed = await AlertMessage.db.updateWhere(
      session,
      columnValues: (t) => [
        t.status(MessageStatus.sending),
        t.statusUpdatedAt(DateTime.now().toUtc()),
        t.failureReason(null),
      ],
      where: (t) =>
          t.id.equals(message.id) & t.status.equals(MessageStatus.pending),
    );

    if (claimed.isEmpty) {
      return null;
    }

    SendResult result;

    try {
      result = await sender.send(session, claimed.single);
    } catch (e) {
      result = SendResult(
        MessageStatus.failed,
        failureReason: '$e',
      );
    }

    await AlertMessage.db.updateWhere(
      session,
      columnValues: (t) => [
        t.status(result.status),
        t.statusUpdatedAt(DateTime.now().toUtc()),
        t.failureReason(result.failureReason),
      ],
      where: (t) => t.id.equals(message.id),
    );

    return result;
  }

  /// Returns messages stuck in `sending` (e.g. after a crash) to `pending`.
  static Future<void> releaseStuck(Session session) async {
    final cutoff = DateTime.now().toUtc().subtract(sendingTimeout);
    await AlertMessage.db.updateWhere(
      session,
      columnValues: (t) => [t.status(MessageStatus.pending)],
      where: (t) =>
          t.status.equals(MessageStatus.sending) & (t.statusUpdatedAt < cutoff),
    );
  }
}
