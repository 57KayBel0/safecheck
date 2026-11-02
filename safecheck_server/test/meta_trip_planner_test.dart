import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:safecheck_server/src/planning/meta_trip_planner.dart';
import 'package:safecheck_server/src/planning/trip_plan_draft.dart';
import 'package:test/test.dart';

final _now = DateTime.utc(2026, 11, 2, 10);

Map<String, dynamic> _draft() => {
  'tripType': 'minibusTaxi',
  'description': 'Taxi from Pretoria CBD to Mamelodi',
  'checkInAtUtc': '2026-11-02T11:00:00Z',
  'questions': <String>[],
};

PlannerHttpResponse _response(
  Object? draft, {
  String finishReason = 'stop',
  Map<String, dynamic> messageFields = const {},
}) => PlannerHttpResponse(
  200,
  jsonEncode({
    'choices': [
      {
        'finish_reason': finishReason,
        'message': {
          'role': 'assistant',
          'content': jsonEncode(draft),
          ...messageFields,
        },
      },
    ],
  }),
);

class _Transport implements PlannerTransport {
  _Transport(this.respond);

  final Future<PlannerHttpResponse> Function() respond;
  int calls = 0;
  Uri? endpoint;
  Map<String, String>? headers;
  Map<String, dynamic>? request;

  @override
  Future<PlannerHttpResponse> post(
    Uri endpoint, {
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) {
    calls++;
    this.endpoint = endpoint;
    this.headers = headers;
    request = jsonDecode(body) as Map<String, dynamic>;
    return respond();
  }
}

MetaTripPlanner _planner(
  _Transport transport, {
  String? key = 'test-meta-secret',
  DateTime Function()? clock,
  Duration timeout = const Duration(seconds: 30),
}) => MetaTripPlanner(
  apiKey: key,
  transport: transport,
  clock: clock ?? () => _now,
  timeout: timeout,
);

Matcher _failure(PlanningFailure failure) => isA<TripPlanningException>()
    .having((error) => error.failure, 'failure', failure);

void main() {
  test('uses Meta structured output and returns a reviewable draft', () async {
    final transport = _Transport(() async => _response(_draft()));
    final draft = await _planner(
      transport,
    ).plan('Taxi home, check in at 13:00 SAST');

    expect(draft.isReadyForReview, isTrue);
    expect(draft.checkInAtUtc, DateTime.utc(2026, 11, 2, 11));
    expect(draft.description, 'Taxi from Pretoria CBD to Mamelodi');
    expect(
      transport.endpoint.toString(),
      'https://api.meta.ai/v1/chat/completions',
    );
    expect(
      transport.headers![HttpHeaders.authorizationHeader],
      'Bearer test-meta-secret',
    );
    final request = transport.request!;
    expect(request['model'], 'muse-spark-1.3');
    expect(request['reasoning_effort'], 'low');
    expect(request['max_completion_tokens'], 2048);
    expect(request['tools'], isNull);
    expect(request['stream'], isFalse);
    final format = request['response_format'] as Map;
    expect(format['type'], 'json_schema');
    final schema = format['json_schema'] as Map;
    expect(schema['strict'], isTrue);
    expect((schema['schema'] as Map)['additionalProperties'], isFalse);
    expect(draft.toJson().keys.toSet(), TripPlanDraft.fields);
  });

  test(
    'unknown details remain a clarification, never a complete draft',
    () async {
      final transport = _Transport(
        () async => _response({
          'tripType': null,
          'description': 'Trip home',
          'checkInAtUtc': null,
          'questions': [
            'Are you leaving now?',
            'Does seven mean 07:00 or 19:00?',
          ],
        }),
      );
      final draft = await _planner(transport).plan('I am going home at seven');
      expect(draft.isReadyForReview, isFalse);
      expect(draft.checkInAtUtc, isNull);
      expect(draft.questions, hasLength(2));
      expect(() => draft.questions.add('Changed'), throwsUnsupportedError);
    },
  );

  test('server time context correctly crosses SAST midnight', () async {
    final time = DateTime.utc(2026, 11, 2, 22, 30);
    final transport = _Transport(
      () async =>
          _response({..._draft(), 'checkInAtUtc': '2026-11-02T23:30:00Z'}),
    );
    await _planner(transport, clock: () => time).plan('Taxi home in one hour');
    final messages = transport.request!['messages'] as List;
    final instructions = (messages.first as Map)['content'] as String;
    expect(instructions, contains('2026-11-03T00:30:00.000+02:00'));
    expect(instructions, contains('2026-11-02T22:30:00.000Z'));
    expect(instructions, contains('Africa/Johannesburg'));
  });

  test(
    'retains bounded user/assistant history below standing instructions',
    () async {
      final transport = _Transport(() async => _response(_draft()));
      await _planner(transport).plan(
        '19:00 today',
        history: const [
          PlanningTurn.user('Taxi home at seven'),
          PlanningTurn.assistant('Does seven mean 07:00 or 19:00?'),
        ],
      );
      final messages = transport.request!['messages'] as List;
      expect(messages.map((m) => (m as Map)['role']), [
        'developer',
        'user',
        'assistant',
        'user',
      ]);
      expect((messages.last as Map)['content'], '19:00 today');
    },
  );

  for (final text in ['', '   ', 'x' * 1501]) {
    test(
      'rejects empty or oversized input before making a request (${text.length})',
      () async {
        final transport = _Transport(() async => _response(_draft()));
        await expectLater(
          _planner(transport).plan(text),
          throwsA(_failure(PlanningFailure.invalidInput)),
        );
        expect(transport.calls, 0);
      },
    );
  }

  test('rejects invalid history order, length and total context', () async {
    final transport = _Transport(() async => _response(_draft()));
    final histories = <List<PlanningTurn>>[
      [const PlanningTurn.user('Unanswered')],
      [
        const PlanningTurn.assistant('Wrong start'),
        const PlanningTurn.user('Wrong end'),
      ],
      [
        for (var i = 0; i < 4; i++) ...[
          const PlanningTurn.user('Trip'),
          const PlanningTurn.assistant('When?'),
        ],
      ],
      [
        PlanningTurn.user('x' * 1500),
        PlanningTurn.assistant('x' * 1500),
        PlanningTurn.user('x' * 1500),
        PlanningTurn.assistant('x' * 1500),
      ],
    ];
    for (final history in histories) {
      await expectLater(
        _planner(transport).plan('Trip', history: history),
        throwsA(_failure(PlanningFailure.invalidInput)),
      );
    }
    expect(transport.calls, 0);
  });

  for (final key in <String?>[null, '   ', 'key\r\nextra-header']) {
    final label = key == null
        ? 'missing'
        : key.trim().isEmpty
        ? 'blank'
        : 'malformed';
    test('$label credentials make no provider request', () async {
      final transport = _Transport(() async => _response(_draft()));
      final planner = _planner(transport, key: key);
      expect(planner.isConfigured, isFalse);
      await expectLater(
        planner.plan('Trip home'),
        throwsA(_failure(PlanningFailure.notConfigured)),
      );
      expect(transport.calls, 0);
    });
  }

  final invalidDrafts = <String, Object?>{
    'not an object': [],
    'unknown fields': {..._draft(), 'activate': true},
    'missing field': {..._draft()}..remove('questions'),
    'unsupported travel mode': {..._draft(), 'tripType': 'autonomousJet'},
    'empty description': {..._draft(), 'description': '   '},
    'long description': {..._draft(), 'description': 'x' * 201},
    'unknown details without questions': {..._draft(), 'tripType': null},
    'non-string question': {
      ..._draft(),
      'questions': [42],
    },
    'too many questions': {
      ..._draft(),
      'questions': ['One?', 'Two?', 'Three?', 'Four?'],
    },
    'empty question': {
      ..._draft(),
      'questions': [' '],
    },
    'timezone omitted': {..._draft(), 'checkInAtUtc': '2026-11-02T11:00:00'},
    'calendar overflow': {..._draft(), 'checkInAtUtc': '2026-02-30T11:00:00Z'},
    'clock overflow': {..._draft(), 'checkInAtUtc': '2026-11-02T25:00:00Z'},
  };
  for (final entry in invalidDrafts.entries) {
    test('rejects invalid model draft: ${entry.key}', () async {
      final transport = _Transport(() async => _response(entry.value));
      await expectLater(
        _planner(transport).plan('Trip home'),
        throwsA(_failure(PlanningFailure.invalidResponse)),
      );
    });
  }

  for (final timestamp in [
    '2026-11-02T09:00:00Z',
    '2026-11-02T10:00:59Z',
    '2026-11-03T10:00:01Z',
  ]) {
    test('unsupported deadline becomes a clarification: $timestamp', () async {
      final transport = _Transport(
        () async => _response({..._draft(), 'checkInAtUtc': timestamp}),
      );
      final draft = await _planner(transport).plan('Trip home');
      expect(draft.isReadyForReview, isFalse);
      expect(draft.checkInAtUtc, isNull);
      expect(draft.questions.first, contains('one minute and 24 hours'));
    });
  }

  for (final timestamp in ['2026-11-02T10:01:00Z', '2026-11-03T10:00:00Z']) {
    test('accepts supported deadline boundary: $timestamp', () async {
      final transport = _Transport(
        () async => _response({..._draft(), 'checkInAtUtc': timestamp}),
      );
      expect(
        (await _planner(transport).plan('Trip home')).isReadyForReview,
        isTrue,
      );
    });
  }

  test('revalidates time after waiting for the model', () async {
    var clockReads = 0;
    final transport = _Transport(() async => _response(_draft()));
    final draft = await _planner(
      transport,
      clock: () {
        return clockReads++ == 0 ? _now : _now.add(const Duration(hours: 2));
      },
    ).plan('Trip home');
    expect(draft.isReadyForReview, isFalse);
    expect(draft.checkInAtUtc, isNull);
  });

  for (final status in [401, 403, 429, 400, 500, 503]) {
    test('provider error $status is sanitized and is not retried', () async {
      final transport = _Transport(
        () async => PlannerHttpResponse(
          status,
          'provider body test-meta-secret private trip',
        ),
      );
      final expected = status == 401 || status == 403
          ? PlanningFailure.notConfigured
          : status == 429
          ? PlanningFailure.rateLimited
          : PlanningFailure.unavailable;
      try {
        await _planner(transport).plan('Trip home');
        fail('Expected an error');
      } on TripPlanningException catch (error) {
        expect(error.failure, expected);
        expect(error.toString(), isNot(contains('test-meta-secret')));
        expect(error.toString(), isNot(contains('private trip')));
      }
      expect(transport.calls, 1);
    });
  }

  test('timeout is bounded and is not retried', () async {
    final pending = Completer<PlannerHttpResponse>();
    final transport = _Transport(() => pending.future);
    await expectLater(
      _planner(
        transport,
        timeout: const Duration(milliseconds: 10),
      ).plan('Trip home'),
      throwsA(_failure(PlanningFailure.timedOut)),
    );
    expect(transport.calls, 1);
  });

  test('transport exceptions cannot leak their contents', () async {
    final transport = _Transport(
      () async => throw Exception('test-meta-secret'),
    );
    await expectLater(
      _planner(transport).plan('Trip home'),
      throwsA(_failure(PlanningFailure.unavailable)),
    );
  });

  final invalidResponses = <String, PlannerHttpResponse>{
    'bad JSON': const PlannerHttpResponse(200, '{'),
    'missing choices': const PlannerHttpResponse(200, '{}'),
    'oversized body': PlannerHttpResponse(
      200,
      'x' * (MetaTripPlanner.maxResponseBytes + 1),
    ),
    'truncated content': _response(_draft(), finishReason: 'length'),
    'refusal': _response(_draft(), messageFields: {'refusal': 'No'}),
    'tool call': _response(
      _draft(),
      messageFields: {
        'tool_calls': [
          {'name': 'startTrip'},
        ],
      },
    ),
    'bad content': _response(_draft(), messageFields: {'content': '{'}),
  };
  for (final entry in invalidResponses.entries) {
    test('rejects invalid provider response: ${entry.key}', () async {
      final transport = _Transport(() async => entry.value);
      await expectLater(
        _planner(transport).plan('Trip home'),
        throwsA(_failure(PlanningFailure.invalidResponse)),
      );
    });
  }
}
