import 'dart:async';
import 'dart:convert';
import 'package:safecheck_server/src/companion/companion_ai.dart';
import 'package:safecheck_server/src/companion/incident_service.dart';
import 'package:safecheck_server/src/generated/protocol.dart';
import 'package:safecheck_server/src/planning/meta_trip_planner.dart';
import 'package:test/test.dart';

class _Transport implements PlannerTransport {
  String response = '';
  int status = 200;
  int calls = 0;
  Map<String, dynamic>? request;
  Duration? timeoutUsed;
  Uri? endpointUsed;
  bool hang = false;
  @override
  Future<PlannerHttpResponse> post(
    Uri endpoint, {
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    calls++;
    timeoutUsed = timeout;
    endpointUsed = endpoint;
    request = jsonDecode(body) as Map<String, dynamic>;
    if (hang) return Completer<PlannerHttpResponse>().future;
    return PlannerHttpResponse(status, response);
  }

  void reply(Object data) {
    response = jsonEncode({
      'choices': [
        {
          'finish_reason': 'stop',
          'message': {'role': 'assistant', 'content': jsonEncode(data)},
        },
      ],
    });
  }
}

void main() {
  test(
    'incident requests use the verified endpoint and a bounded 45-second budget',
    () async {
      final transport = _Transport()
        ..reply({
          'overviewFacts': [0],
          'factOrder': [0],
          'actionCodes': ['callTraveller'],
        });
      await CompanionAi(
        apiKey: 'synthetic',
        transport: transport,
      ).organizeIncident({});
      expect(
        transport.endpointUsed,
        Uri.parse('https://api.meta.ai/v1/chat/completions'),
      );
      expect(transport.timeoutUsed, const Duration(seconds: 45));
      expect(transport.request!['max_completion_tokens'], 1200);
      expect(transport.calls, 1);
    },
  );
  test('invalid timeout configurations are rejected', () {
    for (final timeout in [Duration.zero, const Duration(seconds: 61)]) {
      expect(
        () => CompanionAi(apiKey: null, incidentTimeout: timeout),
        throwsArgumentError,
      );
      expect(
        () => CompanionAi(apiKey: null, planTimeout: timeout),
        throwsArgumentError,
      );
    }
  });
  test('a stalled incident request times out safely without retry', () async {
    final transport = _Transport()..hang = true;
    await expectLater(
      CompanionAi(
        apiKey: 'synthetic-secret',
        transport: transport,
        incidentTimeout: const Duration(milliseconds: 5),
      ).organizeIncident({}),
      throwsA(
        isA<TripPlanningException>()
            .having((e) => e.failure, 'failure', PlanningFailure.timedOut)
            .having(
              (e) => e.message,
              'redacted',
              isNot(contains('synthetic-secret')),
            ),
      ),
    );
    expect(transport.calls, 1);
  });
  for (final entry in {
    401: PlanningFailure.notConfigured,
    403: PlanningFailure.notConfigured,
    429: PlanningFailure.rateLimited,
    503: PlanningFailure.unavailable,
  }.entries) {
    test('HTTP ${entry.key} has a safe classified failure', () async {
      final transport = _Transport()
        ..status = entry.key
        ..response = 'private response';
      await expectLater(
        CompanionAi(
          apiKey: 'synthetic',
          transport: transport,
        ).organizeIncident({}),
        throwsA(
          isA<TripPlanningException>()
              .having((e) => e.failure, 'failure', entry.value)
              .having(
                (e) => e.message,
                'redacted',
                isNot(contains('private response')),
              ),
        ),
      );
      expect(transport.calls, 1);
    });
  }
  for (final body in ['not json', '[]', '{"choices":null}', 'x' * 32769]) {
    test(
      'malformed or oversized companion response is rejected safely (${body.length})',
      () async {
        final transport = _Transport()..response = body;
        await expectLater(
          CompanionAi(
            apiKey: 'synthetic',
            transport: transport,
          ).preparePlan({}),
          throwsA(
            isA<TripPlanningException>().having(
              (e) => e.failure,
              'failure',
              PlanningFailure.invalidResponse,
            ),
          ),
        );
      },
    );
  }
  test(
    'safety plans use bounded Meta structured output without action tools',
    () async {
      final transport = _Transport()
        ..reply({
          'checkInAdvice': 'Review your deadline.',
          'precautions': ['Check transport details.'],
          'uncertainties': ['No danger prediction.'],
        });
      final result = await CompanionAi(
        apiKey: 'synthetic',
        transport: transport,
      ).preparePlan({'description': 'Pretoria to Mamelodi'});
      expect(
        validateSafetyPlan({...result, 'source': 'meta'})['source'],
        'meta',
      );
      expect(transport.request!['model'], 'muse-spark-1.3');
      expect(transport.request!['tools'], isNull);
      expect(
        transport.request!['response_format']['json_schema']['strict'],
        isTrue,
      );
      expect(transport.calls, 1);
    },
  );
  test(
    'provider failure is redacted and never automatically retried',
    () async {
      final transport = _Transport()
        ..status = 401
        ..response = 'Private provider error';
      await expectLater(
        CompanionAi(
          apiKey: 'synthetic-secret',
          transport: transport,
        ).preparePlan({}),
        throwsA(
          isA<TripPlanningException>().having(
            (e) => e.toString(),
            'safe message',
            allOf(
              isNot(contains('synthetic-secret')),
              isNot(contains('Private provider')),
            ),
          ),
        ),
      );
      expect(transport.calls, 1);
    },
  );
  test('invalid safety plans are rejected', () {
    for (final value in [
      null,
      {},
      {...standardPlan(), 'extra': 'unknown'},
      {
        ...standardPlan(),
        'precautions': ['x' * 241],
      },
      {...standardPlan(), 'source': 'made-up'},
    ]) {
      expect(() => validateSafetyPlan(value), throwsFormatException);
    }
  });
  final base = IncidentBrief(
    source: 'standard',
    overview: 'Unconfirmed check-in.',
    facts: [
      'The check-in was not recorded.',
      'Traveller-reported journey: Walk home.',
      'Deadline recorded by the server.',
    ],
    unknowns: ['Safety is unconfirmed.'],
    nextSteps: [incidentActions['callTraveller']!],
    generatedAt: DateTime.utc(2026, 11, 3),
  );
  test('AI organization preserves every server fact and unknown', () {
    final result = IncidentService.organizeBrief(base, {
      'overviewFacts': [0, 2],
      'factOrder': [2, 0],
      'actionCodes': ['callTraveller', 'checkTiming'],
    });
    expect(result.source, 'meta');
    expect(result.facts, containsAll(base.facts));
    expect(result.overview, '${base.facts[0]} ${base.facts[2]}');
    expect(result.unknowns, base.unknowns);
  });
  test('AI cannot invent facts, actions or a location', () {
    for (final response in [
      {
        'overviewFacts': [9],
        'factOrder': [0],
        'actionCodes': ['callTraveller'],
      },
      {
        'overviewFacts': [0, 0],
        'factOrder': [0],
        'actionCodes': ['callTraveller'],
      },
      {
        'overviewFacts': [0],
        'factOrder': [0],
        'actionCodes': ['reviewLocation'],
      },
      {
        'overviewFacts': [0],
        'factOrder': [0],
        'actionCodes': ['confrontSomeone'],
      },
      {
        'overviewFacts': [0],
        'factOrder': [0],
        'actionCodes': ['callTraveller'],
        'accusation': 'danger',
      },
    ]) {
      expect(
        () => IncidentService.organizeBrief(base, response),
        throwsFormatException,
      );
    }
  });
}
