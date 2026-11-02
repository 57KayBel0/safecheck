import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/planning/trip_plan_draft.dart';
import 'package:test/test.dart';

void main() {
  test('AI trip types match the generated Serverpod protocol', () {
    expect(
      plannerTripTypes.toSet(),
      TripType.values.map((type) => type.name).toSet(),
    );
  });
}
