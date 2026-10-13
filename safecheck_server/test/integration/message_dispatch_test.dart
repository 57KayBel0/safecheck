import 'dart:async';
import 'dart:convert';

import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/messaging/bulk_sms_message_sender.dart';
import 'package:safecheck_server/src/messaging/message_dispatcher.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'safecheck_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

class FakeSender implements MessageSender {
  FakeSender(this.whatsappStatus, {this.delay = Duration.zero});
  final MessageStatus whatsappStatus;
  final Duration delay;
  final List<AlertMessage> calls = [];
  @override
  Future<SendResult> send(Session session, AlertMessage message) async {
    calls.add(message);
    if (message.channel == MessageChannel.whatsapp) {
      await Future<void>.delayed(delay);
      return SendResult(whatsappStatus);
    }
    return const SendResult(MessageStatus.sent);
  }
}

class FakeBulkSmsTransport implements BulkSmsTransport {
  final calls = <({Uri uri, Map<String, String> headers, String body})>[];

  @override
  Future<BulkSmsHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
  }) async {
    calls.add((uri: uri, headers: headers, body: body));
    return const BulkSmsHttpResponse(
      statusCode: 200,
      contentType: 'application/json',
      body: '[{"id":"provider-id","status":{"type":"ACCEPTED"}}]',
    );
  }
}

void main() {
  withServerpod(
    'Demo-only dispatch with fake senders',
    rollbackDatabase: RollbackDatabase.disabled,
    (builder, endpoints) {
      const owner = '44444444-4444-4444-8444-444444444444';
      final user = signedIn(builder, owner);
      late MessageSender originalSender;
      Future<void> cleanup() async {
        final session = builder.build();
        await AlertMessage.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(owner),
        );
        await SafetyAlert.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(owner),
        );
        await Trip.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(owner),
        );
        await TrustedContact.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(owner),
        );
        await UserProfile.db.deleteWhere(
          session,
          where: (t) => t.ownerId.equals(owner),
        );
      }

      setUp(() async {
        originalSender = MessageDispatcher.sender;
        await cleanup();
      });
      tearDown(() async {
        MessageDispatcher.sender = originalSender;
        await cleanup();
      });
      Future<int> alert({required bool sms}) async {
        await setUpTraveller(endpoints, user, contactCount: 1);
        final contact = (await TrustedContact.db.find(
          builder.build(),
          where: (t) => t.ownerId.equals(owner),
        )).single;
        await TrustedContact.db.updateRow(
          builder.build(),
          contact.copyWith(
            optInStatus: ContactOptInStatus.accepted,
            notifyByWhatsapp: true,
            notifyBySms: sms,
          ),
        );
        final trip = (await endpoints.trip.startTrip(
          user,
          TripType.walking,
          'Fake delivery test',
          30,
        )).trip!;
        await expireTrip(builder, trip.id!);
        await endpoints.futureCalls.tripDeadline.processDeadline(
          builder,
          trip.id!,
        );
        return (await endpoints.alert.listAlerts(user)).single.id!;
      }

      test(
        'WhatsApp success skips SMS and repeated dispatch sends nothing again',
        () async {
          final fake = FakeSender(MessageStatus.sent);
          MessageDispatcher.sender = fake;
          final id = await alert(sms: true);
          expect(fake.calls.map((m) => m.channel), [MessageChannel.whatsapp]);
          final rows = await endpoints.alert.listMessages(user);
          expect(rows, hasLength(2));
          expect(
            rows.singleWhere((m) => m.channel == MessageChannel.sms).status,
            MessageStatus.skipped,
          );
          for (var i = 0; i < 3; i++) {
            await MessageDispatcher.dispatchPending(
              builder.build(),
              alertId: id,
            );
          }
          expect(fake.calls, hasLength(1));
        },
      );
      for (final sms in [false, true]) {
        test('WhatsApp failure uses SMS only when enabled: $sms', () async {
          final fake = FakeSender(MessageStatus.failed);
          MessageDispatcher.sender = fake;
          final id = await alert(sms: sms);
          expect(fake.calls.map((m) => m.channel), [
            MessageChannel.whatsapp,
            if (sms) MessageChannel.sms,
          ]);
          expect(
            await endpoints.alert.listMessages(user),
            hasLength(sms ? 2 : 1),
          );
          await MessageDispatcher.dispatchPending(builder.build(), alertId: id);
          expect(fake.calls, hasLength(sms ? 2 : 1));
        });
      }
      for (final status in [MessageStatus.sent, MessageStatus.failed]) {
        test(
          'concurrent dispatch claims each channel once with WhatsApp ${status.name}',
          () async {
            MessageDispatcher.sender = FakeSender(MessageStatus.failed);
            final id = await alert(sms: true);
            await AlertMessage.db.updateWhere(
              builder.build(),
              columnValues: (t) => [t.status(MessageStatus.pending)],
              where: (t) => t.alertId.equals(id),
            );
            final fake = FakeSender(
              status,
              delay: const Duration(milliseconds: 100),
            );
            MessageDispatcher.sender = fake;
            await Future.wait([
              for (var i = 0; i < 12; i++)
                MessageDispatcher.dispatchPending(builder.build(), alertId: id),
            ]);
            await MessageDispatcher.dispatchPending(
              builder.build(),
              alertId: id,
            );
            expect(
              fake.calls.where((m) => m.channel == MessageChannel.whatsapp),
              hasLength(1),
            );
            expect(
              fake.calls.where((m) => m.channel == MessageChannel.sms),
              hasLength(status == MessageStatus.sent ? 0 : 1),
            );
            final rows = await endpoints.alert.listMessages(user);
            expect(rows, hasLength(2));
            expect(
              rows.where((m) => m.status == MessageStatus.sending),
              isEmpty,
            );
            expect(
              rows.map((m) => '${m.recipientPhone}:${m.channel.name}').toSet(),
              hasLength(2),
            );
            expect(
              rows.singleWhere((m) => m.channel == MessageChannel.sms).status,
              status == MessageStatus.sent
                  ? MessageStatus.skipped
                  : MessageStatus.sent,
            );
          },
        );
      }
      test(
        'simulated WhatsApp does not suppress live SMS and concurrent dispatch is deduplicated',
        () async {
          MessageDispatcher.sender = FakeSender(MessageStatus.failed);
          final id = await alert(sms: true);
          const exactBody =
              'Check in with the traveller. Exact tracking URL: '
              'https://safecheck.example/t/exact-stored-token';
          await AlertMessage.db.updateWhere(
            builder.build(),
            columnValues: (t) => [
              t.status(MessageStatus.pending),
              t.body(exactBody),
            ],
            where: (t) => t.alertId.equals(id),
          );

          final createdAt = (await AlertMessage.db.find(
            builder.build(),
            where: (t) => t.alertId.equals(id),
          )).first.createdAt;
          final transport = FakeBulkSmsTransport();
          MessageDispatcher.sender = messageSenderForConfig(
            mode: 'live',
            tokenId: 'test-token-id',
            tokenSecret: 'test-token-secret',
            transport: transport,
            now: () => createdAt.subtract(const Duration(seconds: 1)),
          );
          await Future.wait([
            for (var i = 0; i < 12; i++)
              MessageDispatcher.dispatchPending(builder.build(), alertId: id),
          ]);

          expect(transport.calls, hasLength(1));
          expect(
            transport.calls.single.uri.queryParameters['deduplication-id'],
            isNotEmpty,
          );
          expect(
            ((jsonDecode(transport.calls.single.body) as List).single
                as Map<String, dynamic>)['body'],
            exactBody,
          );
          final rows = await endpoints.alert.listMessages(user);
          expect(
            rows
                .singleWhere((m) => m.channel == MessageChannel.whatsapp)
                .status,
            MessageStatus.simulated,
          );
          expect(
            rows.singleWhere((m) => m.channel == MessageChannel.sms).status,
            MessageStatus.sent,
          );
        },
      );
      test(
        'default demo sender simulates both channels without delivery',
        () async {
          MessageDispatcher.sender = const DemoMessageSender();
          await alert(sms: true);
          expect(
            (await endpoints.alert.listMessages(user)).map((m) => m.status),
            everyElement(MessageStatus.simulated),
          );
        },
      );
    },
  );
}
