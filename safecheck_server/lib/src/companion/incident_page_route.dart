import 'package:serverpod/serverpod.dart';
import '../common/links.dart';
import '../trips/trip_service.dart' show formatSast;
import 'incident_service.dart';

/// A private, no-store contact page. The URL itself grants access for 48 hours.
class IncidentPageRoute extends Route {
  IncidentPageRoute()
    : super(methods: {Method.get, Method.post}, path: '/:token');
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final token = request.rawPathParameters[#token] ?? '';
    String? error;
    if (request.method == Method.post) {
      try {
        final form = Uri.splitQueryString(
          await request.readAsString(maxLength: 1500),
        );
        // No cookies authorize this action: a private bearer link and an
        // explicit confirmation field are required. Cross-origin forms rejected.
        final origin = request.headers['origin']?.firstOrNull;
        final expected = Uri.parse(publicWebUrl(session, '/')).origin;
        if (origin != null && origin != expected) throw const FormatException();
        if (form['confirm'] == 'resolve' &&
            form['proof'] == IncidentService.hashToken('resolve:$token')) {
          await IncidentService.resolveFromLink(
            session,
            token,
            form['note'] ?? '',
          );
        } else {
          throw const FormatException();
        }
      } catch (_) {
        error =
            'This action could not be completed. The link may have expired or lack permission.';
      }
    }
    final view = await IncidentService.view(session, token);
    String list(List<String> values) =>
        '<ul>${values.map((v) => '<li>${htmlEscape(v)}</li>').join()}</ul>';
    final body = view == null
        ? '<h1>Link unavailable</h1><p>Ask the traveller for a current incident link.</p>'
        : '''
<h1>${htmlEscape(view.travellerName)}’s incident</h1>
<p><strong>${view.resolvedAt == null ? 'Open incident' : 'Resolved incident'}</strong></p>
<p>${htmlEscape(view.journeyDescription)}</p>
<p>Deadline: ${htmlEscape(formatSast(view.deadline))}</p>
<h2>${view.brief.source == 'meta' ? 'AI-organized brief' : 'Standard incident brief'}</h2>
<p>${htmlEscape(view.brief.overview)}</p>
<h3>Recorded facts</h3>${list(view.brief.facts)}
<h3>What is uncertain</h3>${list(view.brief.unknowns)}
<h3>Suggested next steps</h3>${list(view.brief.nextSteps)}
${view.trackingUrl == null ? '' : '<p><a href="${htmlEscape(view.trackingUrl!)}" rel="noreferrer">View consented location and its timestamp</a></p>'}
${view.resolvedAt == null ? '' : '<p>Resolved at ${htmlEscape(formatSast(view.resolvedAt!))} by ${htmlEscape(view.resolutionActor ?? 'an authorized person')}. ${htmlEscape(view.resolutionNote ?? '')}</p>'}
${view.canResolve ? '''<h2>Resolve this incident</h2>
<p>Use this only after checking the situation. Further unsent notifications stop; messages already submitted cannot be recalled.</p>
<form method="post"><input type="hidden" name="proof" value="${IncidentService.hashToken('resolve:$token')}">
<label>Outcome note <input name="note" maxlength="200"></label>
<p><label><input type="checkbox" name="confirm" value="resolve" required> I have checked the situation and want to resolve this incident.</label></p>
<button type="submit">Resolve incident</button></form>''' : ''}
''';
    return Response.ok(
      body: Body.fromString(
        '''<!doctype html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex,nofollow"><meta name="referrer" content="no-referrer">
<title>SafeCheck incident</title><style>:root{color-scheme:light dark}body{font:16px/1.6 system-ui;margin:24px auto;padding:16px;max-width:680px}button,input{font:inherit;padding:12px}li{margin-bottom:8px}</style></head>
<body><p>SafeCheck · Private incident link</p>${error == null ? '' : '<p>${htmlEscape(error)}</p>'}$body
<p>Anyone holding this link can view this page and, if permission was granted, resolve the incident. This link expires after 48 hours. SafeCheck does not provide emergency response.</p></body></html>''',
        mimeType: MimeType.html,
      ),
      headers: Headers.build((h) {
        h.cacheControl = CacheControlHeader(noStore: true, privateCache: true);
        h['referrer-policy'] = ['no-referrer'];
        h['x-frame-options'] = ['DENY'];
        h['content-security-policy'] = [
          "default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; frame-ancestors 'none'",
        ];
      }),
    );
  }
}
