import 'dart:convert';
import 'dart:io';

import 'package:safecheck_server/src/companion/companion_ai.dart';
import 'package:safecheck_server/src/companion/incident_service.dart';
import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/planning/meta_trip_planner.dart';
import 'package:yaml/yaml.dart';

class _MeasuredTransport implements PlannerTransport {
  int calls = 0;
  int? status;
  int? elapsedMilliseconds;

  @override
  Future<PlannerHttpResponse> post(
    Uri endpoint, {
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    if (calls >= 1) throw StateError('Single-inference budget exhausted.');
    calls++;
    final watch = Stopwatch()..start();
    try {
      final response = await const IoPlannerTransport(
        maxResponseBytes: CompanionAi.maxResponseBytes,
      ).post(endpoint, headers: headers, body: body, timeout: timeout);
      status = response.statusCode;
      return response;
    } finally {
      elapsedMilliseconds = watch.elapsedMilliseconds;
    }
  }
}

/// One explicitly authorized inference, using fictional data and no database.
Future<void> main(List<String> args) async {
  if (!args.contains('--approve-inference') ||
      (args.contains('--summary') == args.contains('--plan'))) {
    stdout.writeln(
      'Select --summary or --plan and pass --approve-inference. No request made.',
    );
    exitCode = 2;
    return;
  }
  final scenario = args.contains('--summary') ? 'summary' : 'plan';
  final transport = _MeasuredTransport();
  final result = <String, Object?>{
    'scenario': scenario,
    'model': MetaTripPlanner.model,
  };
  try {
    final file = File('config/passwords.yaml');
    final root = file.existsSync()
        ? loadYaml(file.readAsStringSync()) as Map
        : <String, Object?>{};
    final shared = root['shared'] as Map? ?? {};
    final development = root['development'] as Map? ?? {};
    final key =
        (development['metaModelApiKey'] ??
                shared['metaModelApiKey'] ??
                Platform.environment['MODEL_API_KEY'])
            ?.toString();
    final ai = CompanionAi(apiKey: key, transport: transport);
    if (scenario == 'summary') {
      final base = IncidentBrief(
        source: 'standard',
        overview: 'A fictional check-in was not recorded.',
        facts: [
          'A fictional scheduled check-in was not recorded.',
          'Traveller-reported journey: walking from a demo library to demo accommodation.',
          'Transport: walking.',
          'The server recorded the check-in deadline.',
          'The journey used zero grace minutes.',
        ],
        unknowns: [
          'Safety is unconfirmed.',
          'A missed check-in is not proof of danger.',
        ],
        nextSteps: [incidentActions['callTraveller']!],
        generatedAt: DateTime.now().toUtc(),
      );
      final raw = await ai.organizeIncident({
        'facts': base.facts,
        'unknowns': base.unknowns,
        'locationAvailable': false,
        'allowedActions': incidentActions.keys.toList(),
      });
      final organized = IncidentService.organizeBrief(base, raw);
      result.addAll({
        'validatedResponse': true,
        'source': organized.source,
        'allFactsPreserved':
            organized.facts.toSet().containsAll(base.facts) &&
            organized.facts.length == base.facts.length,
        'unknownsPreserved':
            jsonEncode(organized.unknowns) == jsonEncode(base.unknowns),
        'overviewFactCount': (raw['overviewFacts'] as List).length,
        'allowedActionCount': organized.nextSteps.length,
      });
    } else {
      final raw = await ai.preparePlan({
        'tripType': 'walking',
        'travellerProvidedDescription':
            'Fictional walk from a demo library to demo accommodation.',
        'checkInAtUtc': DateTime.now()
            .toUtc()
            .add(const Duration(minutes: 20))
            .toIso8601String(),
        'graceMinutes': 0,
        'currentTimeUtc': DateTime.now().toUtc().toIso8601String(),
        'timeZone': 'Africa/Johannesburg',
      });
      final plan = validateSafetyPlan({...raw, 'source': 'meta'});
      result.addAll({
        'validatedResponse': true,
        'source': plan['source'],
        'precautionCount': (plan['precautions'] as List).length,
        'uncertaintyCount': (plan['uncertainties'] as List).length,
      });
    }
  } on TripPlanningException catch (error) {
    result.addAll({
      'validatedResponse': false,
      'safeFailureCode': error.failure.name,
    });
    exitCode = 1;
  } catch (error) {
    result.addAll({
      'validatedResponse': false,
      'safeErrorType': error.runtimeType.toString(),
    });
    exitCode = 1;
  }
  result.addAll({
    'inferenceAttempts': transport.calls,
    'httpStatus': transport.status,
    'elapsedMilliseconds': transport.elapsedMilliseconds,
    'automaticRetries': 0,
  });
  stdout.writeln(jsonEncode(result));
  final report = File(
    '../.dart_tool/meta-$scenario-${DateTime.now().millisecondsSinceEpoch}.json',
  );
  report.writeAsStringSync(jsonEncode(result), flush: true);
}
