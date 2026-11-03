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
  @override
  Future<PlannerHttpResponse> post(
    Uri endpoint, {
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    calls++;
    request = jsonDecode(body) as Map<String, dynamic>;
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
