import 'dart:convert';
import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../common/validation.dart';
import '../generated/protocol.dart';
import '../planning/planning_service.dart';
import 'companion_ai.dart';

abstract final class SafetyPlanService {
  static CompanionAi Function(Session) aiFor = (session) => CompanionAi(
    apiKey:
        session.serverpod.getPassword('metaModelApiKey') ??
        Platform.environment['MODEL_API_KEY'],
  );

  static Future<String> prepare(
    Session session,
    String ownerId,
    TripType type,
    String description,
    DateTime deadline,
    int graceMinutes,
  ) async {
    final text = cleanText(
      description,
      field: 'Journey description',
      maxLength: 200,
    );
    validateGrace(graceMinutes);
    final now = DateTime.now().toUtc();
    final remaining = deadline.toUtc().difference(now);
    if (remaining < const Duration(minutes: 1) ||
        remaining > const Duration(hours: 24)) {
      throw validationError(
        'Choose a check-in time between one minute and 24 hours from now.',
      );
    }
    try {
      final ai = aiFor(session);
      if (!ai.isConfigured) return jsonEncode(standardPlan());
      await PlanningService.reserveRequest(session, ownerId);
      final raw = await ai.preparePlan({
        'tripType': type.name,
        'travellerProvidedDescription': text,
        'checkInAtUtc': deadline.toUtc().toIso8601String(),
        'graceMinutes': graceMinutes,
        'currentTimeUtc': now.toIso8601String(),
        'timeZone': 'Africa/Johannesburg',
      });
      return jsonEncode(validateSafetyPlan({...raw, 'source': 'meta'}));
    } catch (_) {
      return jsonEncode(standardPlan());
    }
  }

  static void validateGrace(int minutes) {
    if (minutes < 0 || minutes > 10) {
      throw validationError('Grace period must be between 0 and 10 minutes.');
    }
  }
}
