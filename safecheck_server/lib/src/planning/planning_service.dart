import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../common/owner_lock.dart';
import '../generated/protocol.dart';
import 'meta_trip_planner.dart';

/// An authenticated, quota-bound proposal service. Has no trip or messaging
/// operations. A separate explicit confirmation starts the trip.
abstract final class PlanningService {
  static const windowLimit = 5;
  static const dayLimit = 30;
  static const windowLength = Duration(minutes: 10);

  // Injectable for tests; the production resolver reads server credentials only.
  static MetaTripPlanner Function(Session) plannerFor = _configuredPlanner;
  static DateTime Function() clock = DateTime.now;

  static MetaTripPlanner _configuredPlanner(Session session) => MetaTripPlanner(
    apiKey:
        session.serverpod.getPassword('metaModelApiKey') ??
        Platform.environment['MODEL_API_KEY'],
  );

  static bool isAvailable(Session session) => plannerFor(session).isConfigured;

  static Future<String> plan(
    Session session,
    String ownerId,
    String input,
    List<String> history,
  ) async {
    final turns = [
      for (var i = 0; i < history.length; i++)
        if (i.isEven)
          PlanningTurn.user(history[i])
        else
          PlanningTurn.assistant(history[i]),
    ];
    try {
      MetaTripPlanner.validateInput(input.trim(), turns);
      final planner = plannerFor(session);
      if (!planner.isConfigured) {
        throw const TripPlanningException(
          PlanningFailure.notConfigured,
          'AI planning is not configured. You can still create a trip manually.',
        );
      }
      // Reserve before the external call. Failures also consume a request:
      // retries must not bypass the bound or duplicate uncertain billed calls.
      await reserveRequest(session, ownerId);
      final draft = await planner.plan(input, history: turns);
      return jsonEncode(draft.toJson());
    } on TripPlanningException catch (error) {
      throw SafeCheckException(
        message: error.message,
        code: 'planning_${error.failure.name}',
      );
    }
  }

  static Future<void> reserveRequest(Session session, String ownerId) async {
    await session.db.transaction((transaction) async {
      await lockOwner(session, ownerId, transaction);
      final now = clock().toUtc();
      final day = DateTime.utc(now.year, now.month, now.day);
      var quota = await PlanningQuota.db.findFirstRow(
        session,
        where: (t) => t.ownerId.equals(ownerId),
        transaction: transaction,
      );
      if (quota == null) {
        await PlanningQuota.db.insertRow(
          session,
          PlanningQuota(
            ownerId: ownerId,
            windowStartedAt: now,
            windowCount: 1,
            dayStartedAt: day,
            dayCount: 1,
          ),
          transaction: transaction,
        );
        return;
      }
      if (quota.dayStartedAt != day) {
        quota = quota.copyWith(dayStartedAt: day, dayCount: 0);
      }
      if (now.difference(quota.windowStartedAt) >= windowLength) {
        quota = quota.copyWith(windowStartedAt: now, windowCount: 0);
      }
      if (quota.dayCount >= dayLimit || quota.windowCount >= windowLimit) {
        throw SafeCheckException(
          message: quota.dayCount >= dayLimit
              ? 'You have reached today’s AI planning limit. Use manual setup.'
              : 'You have made several AI requests. Wait 10 minutes or use manual setup.',
          code: 'planning_rateLimited',
        );
      }
      await PlanningQuota.db.updateRow(
        session,
        quota.copyWith(
          windowCount: quota.windowCount + 1,
          dayCount: quota.dayCount + 1,
        ),
        transaction: transaction,
      );
    });
  }
}
