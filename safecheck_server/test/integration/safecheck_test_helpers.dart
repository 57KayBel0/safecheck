import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const aliceId = '11111111-1111-4111-8111-111111111111';
const bobId = '22222222-2222-4222-8222-222222222222';

TestSessionBuilder signedIn(TestSessionBuilder builder, String userId) =>
    builder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(userId, {}),
    );

/// Gives [userId] a profile and [contactCount] trusted contacts.
Future<void> setUpTraveller(
  TestEndpoints endpoints,
  TestSessionBuilder session, {
  String name = 'Thandi',
  String phone = '082 000 0001',
  int contactCount = 2,
}) async {
  await endpoints.profile.saveProfile(session, name, phone);
  for (var i = 0; i < contactCount; i++) {
    await endpoints.contact.add(
      session,
      'Contact $i',
      '083 000 00${10 + i}',
      i == 0 ? 'Sister' : null,
    );
  }
}

/// Moves [tripId]'s deadline into the past, as if the trip had run out.
Future<void> expireTrip(TestSessionBuilder builder, int tripId) async {
  final session = builder.build();
  final trip = (await Trip.db.findById(session, tripId))!;
  await Trip.db.updateRow(
    session,
    trip.copyWith(
      deadline: DateTime.now().toUtc().subtract(const Duration(seconds: 1)),
    ),
  );
}

Matcher throwsSafeCheck(String code) => throwsA(
  isA<SafeCheckException>().having((e) => e.code, 'code', code),
);
