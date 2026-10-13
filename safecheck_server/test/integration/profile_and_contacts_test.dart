import 'package:test/test.dart';

import 'safecheck_test_helpers.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given the profile and contact endpoints', (
    sessionBuilder,
    endpoints,
  ) {
    final alice = signedIn(sessionBuilder, aliceId);
    final bob = signedIn(sessionBuilder, bobId);

    test('when unauthenticated then every private endpoint rejects', () async {
      final anon = sessionBuilder;
      final unauthenticated = throwsA(
        isA<ServerpodUnauthenticatedException>(),
      );
      await expectLater(
        endpoints.profile.getProfile(anon),
        unauthenticated,
      );
      await expectLater(
        endpoints.profile.saveProfile(anon, 'Name', '0821234567'),
        unauthenticated,
      );
      await expectLater(endpoints.contact.list(anon), unauthenticated);
      await expectLater(
        endpoints.contact.add(anon, 'A', '0821234567', null),
        unauthenticated,
      );
      await expectLater(endpoints.contact.remove(anon, 1), unauthenticated);
      await expectLater(endpoints.trip.getActiveTrip(anon), unauthenticated);
      await expectLater(endpoints.trip.history(anon), unauthenticated);
      await expectLater(endpoints.trip.checkIn(anon, 1), unauthenticated);
      await expectLater(endpoints.alert.listAlerts(anon), unauthenticated);
      await expectLater(endpoints.alert.listMessages(anon), unauthenticated);
    });

    test('when saving a profile then the phone is normalised', () async {
      final profile = await endpoints.profile.saveProfile(
        alice,
        '  Thandi   Nkosi ',
        '082 123-4567',
      );
      expect(profile.displayName, 'Thandi Nkosi');
      expect(profile.phoneNumber, '+27821234567');

      final updated = await endpoints.profile.saveProfile(
        alice,
        'Thandi',
        '+27 82 765 4321',
      );
      expect(updated.id, profile.id);
      expect(updated.phoneNumber, '+27827654321');
      expect((await endpoints.profile.getProfile(bob)), isNull);
    });

    test('when saving invalid profile details then they are rejected', () {
      expect(
        endpoints.profile.saveProfile(alice, 'Thandi', '12345'),
        throwsSafeCheck('validation'),
      );
      expect(
        endpoints.profile.saveProfile(alice, 'Thandi', '+44 20 7946 0958'),
        throwsSafeCheck('validation'),
      );
      expect(
        endpoints.profile.saveProfile(alice, ' ', '0821234567'),
        throwsSafeCheck('validation'),
      );
    });

    test('when adding contacts then at most five are allowed', () async {
      for (var i = 0; i < 5; i++) {
        await endpoints.contact.add(alice, 'C$i', '0830000${100 + i}', null);
      }
      await expectLater(
        endpoints.contact.add(alice, 'Sixth', '0839999999', null),
        throwsSafeCheck('conflict'),
      );
      expect(await endpoints.contact.list(alice), hasLength(5));
    });

    test(
      'when adding invalid or duplicate contacts then they are rejected',
      () async {
        await endpoints.profile.saveProfile(alice, 'Thandi', '0821234567');
        await endpoints.contact.add(alice, 'Sipho', '0831234567', 'Brother');

        await expectLater(
          endpoints.contact.add(alice, 'Bad', '083 12', null),
          throwsSafeCheck('validation'),
        );
        await expectLater(
          endpoints.contact.add(alice, '', '0831111111', null),
          throwsSafeCheck('validation'),
        );
        await expectLater(
          endpoints.contact.add(alice, 'Dup', '+27831234567', null),
          throwsSafeCheck('validation'),
        );
        await expectLater(
          endpoints.contact.add(alice, 'Me', '082 123 4567', null),
          throwsSafeCheck('validation'),
        );
        await expectLater(
          endpoints.contact.add(alice, 'Long', '0831111111', 'x' * 41),
          throwsSafeCheck('validation'),
        );
      },
    );

    test('when editing and removing contacts then changes are saved', () async {
      final c = await endpoints.contact.add(alice, 'Sipho', '0831234567', null);
      final edited = await endpoints.contact.update(
        alice,
        c.id!,
        'Sipho M',
        '0831234568',
        'Brother',
      );
      expect(edited.name, 'Sipho M');
      expect(edited.phoneNumber, '+27831234568');
      expect(edited.relationship, 'Brother');

      await endpoints.contact.remove(alice, c.id!);
      expect(await endpoints.contact.list(alice), isEmpty);
    });

    test('when another user targets a contact then it is not found', () async {
      final c = await endpoints.contact.add(alice, 'Sipho', '0831234567', null);

      expect(await endpoints.contact.list(bob), isEmpty);
      await expectLater(
        endpoints.contact.update(bob, c.id!, 'Hacked', '0830000000', null),
        throwsSafeCheck('not_found'),
      );
      await expectLater(
        endpoints.contact.remove(bob, c.id!),
        throwsSafeCheck('not_found'),
      );
      final aliceContacts = await endpoints.contact.list(alice);
      expect(aliceContacts.single.name, 'Sipho');
    });
  });
}
