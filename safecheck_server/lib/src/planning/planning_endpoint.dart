import 'package:serverpod/serverpod.dart';

import '../common/validation.dart';
import 'planning_service.dart';
import '../generated/protocol.dart';
import '../companion/safety_plan_service.dart';

/// Prepares read-only trip drafts for signed-in users. Never starts a trip.
class PlanningEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<bool> isAvailable(Session session) async {
    ownerIdOf(session);
    return PlanningService.isAvailable(session);
  }

  Future<String> prepareSafetyPlan(
    Session session,
    TripType tripType,
    String description,
    DateTime checkInAtUtc,
    int graceMinutes,
  ) => SafetyPlanService.prepare(
    session,
    ownerIdOf(session),
    tripType,
    description,
    checkInAtUtc,
    graceMinutes,
  );

  /// [history] alternates user text and the returned draft JSON, at most
  /// three completed exchanges. It is context only, never an authority to act.
  Future<String> propose(Session session, String input, List<String> history) =>
      PlanningService.plan(session, ownerIdOf(session), input, history);
}
