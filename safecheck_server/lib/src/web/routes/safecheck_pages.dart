import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../common/links.dart';
import '../../contacts/contact_invite_service.dart';
import '../../generated/protocol.dart';
import '../../tracking/tracking_service.dart';
import '../../trips/trip_service.dart' show formatSast, tripTypeLabel;

// Public pages for trusted contacts, who are not app users. The secret token
// in the URL is the only credential, so pages are never cached or indexed and
// send only the origin as a referrer, never the secret path or query.
//
// Unknown tokens get a normal 200 page: server.dart turns every 404 into the
// "build the Flutter app" page.

String? _token(Request request) => request.rawPathParameters[#token];

Response _html(String title, String body) {
  final page =
      '''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="referrer" content="strict-origin">
<meta name="robots" content="noindex, nofollow">
<title>${htmlEscape(title)} · SafeCheck</title>
<style>
  :root { color-scheme: light dark; --accent: #00796b; }
  body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
         margin: 0; line-height: 1.5; background: Canvas; color: CanvasText; }
  main { max-width: 640px; margin: 0 auto; padding: 20px 16px 40px; }
  h1 { font-size: 1.5rem; margin: 0 0 4px; }
  .brand { color: var(--accent); font-weight: 700; letter-spacing: .02em; }
  .card { border: 1px solid #8884; border-radius: 14px; padding: 16px;
          margin: 16px 0; }
  .warn { border-color: #c62828; background: #c628281a; }
  .ok { border-color: #2e7d32; background: #2e7d321a; }
  .muted { opacity: .75; font-size: .95rem; }
  #map { height: 60vh; min-height: 320px; border-radius: 14px; margin: 16px 0; }
  button, .button { font: inherit; font-weight: 600; border: 0;
          border-radius: 12px; padding: 14px 20px; min-height: 48px;
          cursor: pointer; display: inline-block; text-decoration: none; }
  .primary { background: var(--accent); color: white; }
  .secondary { background: #8883; color: inherit; }
  form { display: inline; }
  .actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 12px; }
</style>
</head>
<body><main>
<p class="brand">SafeCheck</p>
$body
<p class="muted">SafeCheck is a demo. If you believe someone is in danger,
call SAPS on 10111, or 112 from a mobile phone.</p>
</main></body></html>''';
  return Response.ok(
    body: Body.fromString(page, mimeType: MimeType.html),
    headers: _noStore,
  );
}

final _noStore = Headers.build((h) {
  h.cacheControl = CacheControlHeader(noStore: true, privateCache: true);
  h['referrer-policy'] = ['strict-origin'];
});

Response _invalidLink() => _html(
  'Link not valid',
  '<h1>This link is not valid</h1>'
      '<p>It may have been replaced by a newer link. Ask the person who sent '
      'it to share it again.</p>',
);

/// `/c/:token` — a contact accepts or declines an invite.
class InvitePageRoute extends Route {
  InvitePageRoute()
    : super(methods: {Method.get, Method.post}, path: '/:token');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final token = _token(request) ?? '';
    InviteView? view;
    if (request.method == Method.post) {
      final form = Uri.splitQueryString(
        await request.readAsString(maxLength: 1024),
      );
      final answer = form['answer'];
      if (answer == 'accept' || answer == 'decline') {
        view = await ContactInviteService.respond(
          session,
          token,
          accept: answer == 'accept',
        );
      }
    }
    view ??= await ContactInviteService.view(session, token);
    if (view == null) return _invalidLink();

    final owner = htmlEscape(view.ownerName);
    final contact = htmlEscape(view.contactName);
    final status = switch (view.status) {
      ContactOptInStatus.accepted =>
        '<div class="card ok"><strong>You accepted.</strong> You may get a '
            'WhatsApp message or SMS from SafeCheck if $owner misses a '
            'check-in.</div>',
      ContactOptInStatus.declined =>
        '<div class="card"><strong>You declined.</strong> SafeCheck will not '
            'send you WhatsApp messages about $owner.</div>',
      ContactOptInStatus.pending => '',
    };
    return _html(
      'Trusted contact invite',
      '''
<h1>Hi $contact</h1>
<p>$owner would like you to be one of their trusted contacts on SafeCheck.</p>
<p>Before a trip, $owner sets a time to check in. If they don't check in in
time, SafeCheck can message you so you can try to reach them, and may include
a link to their last known location.</p>
$status
<div class="actions">
  <form method="post"><input type="hidden" name="answer" value="accept">
    <button class="primary" type="submit">Accept</button></form>
  <form method="post"><input type="hidden" name="answer" value="decline">
    <button class="secondary" type="submit">Decline</button></form>
</div>
<p class="muted">You can change your answer at any time with this link.</p>''',
    );
  }
}

/// `/t/:token` — a contact's view of a trip's location.
class TrackingPageRoute extends Route {
  TrackingPageRoute() : super(path: '/:token');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final view = await TrackingService.view(session, _token(request) ?? '');
    if (view == null) return _invalidLink();

    final name = htmlEscape(view.travellerName);
    final trip = view.trip;
    final missed = trip.status == TripStatus.missed;
    return _html(
      'Trip of ${view.travellerName}',
      '''
<h1>$name's trip</h1>
<div id="status" class="card ${missed ? 'warn' : (view.showLocation ? '' : 'ok')}">
  ${htmlEscape(view.message)}</div>
<p><strong>${htmlEscape(tripTypeLabel(trip.tripType))}:</strong>
  ${htmlEscape(trip.description)}<br>
  <span class="muted">Check-in deadline: ${htmlEscape(formatSast(trip.deadline))}</span></p>
${view.showLocation ? _mapSection : ''}''',
    );
  }
}

const _mapSection = '''
<div id="map" role="img" aria-label="Map of the trip"></div>
<p id="last" class="muted">Loading location…</p>
<p><a id="gmaps" class="button secondary" target="_blank" rel="noopener noreferrer"
  style="display:none">Open in Google Maps</a></p>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
<script>
(function () {
  var map = L.map('map');
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);
  map.setView([-28.5, 24.7], 5); // South Africa until data arrives.
  var line = L.polyline([], { color: '#00796b', weight: 4 }).addTo(map);
  var marker = null, circle = null, fitted = false;

  function ago(iso) {
    var s = Math.max(0, Math.round((Date.now() - Date.parse(iso)) / 1000));
    if (s < 60) return s + ' seconds ago';
    if (s < 3600) return Math.round(s / 60) + ' minutes ago';
    return Math.round(s / 3600) + ' hours ago';
  }

  function refresh() {
    fetch(location.pathname.replace(/\\/\$/, '') + '/data', { cache: 'no-store' })
      .then(function (r) {
        var type = r.headers.get('content-type') || '';
        if (!r.ok || type.indexOf('application/json') === -1) {
          throw new Error('Location response: HTTP ' + r.status + ' (' + type + ')');
        }
        return r.json();
      })
      .then(function (d) {
        document.getElementById('status').textContent = d.message;
        if (!d.showLocation) { location.reload(); return; }
        var pts = d.points.map(function (p) { return [p.lat, p.lng]; });
        line.setLatLngs(pts);
        var lastEl = document.getElementById('last');
        if (!pts.length) {
          lastEl.textContent = 'No location has been received yet.';
          return;
        }
        var last = d.points[d.points.length - 1];
        var ll = [last.lat, last.lng];
        if (!marker) { marker = L.marker(ll).addTo(map); }
        marker.setLatLng(ll);
        if (circle) map.removeLayer(circle);
        if (last.acc) {
          circle = L.circle(ll, { radius: last.acc, weight: 1 }).addTo(map);
        }
        if (!fitted) {
          map.fitBounds(line.getBounds().pad(0.2), { maxZoom: 16 });
          fitted = true;
        }
        lastEl.textContent = 'Last location ' + ago(last.t) +
          (last.acc ? ' (accurate to about ' + Math.round(last.acc) + ' m)' : '') + '.';
        var g = document.getElementById('gmaps');
        g.href = 'https://www.google.com/maps/search/?api=1&query=' + last.lat + ',' + last.lng;
        g.style.display = 'inline-block';
      })
      .catch(function () {
        document.getElementById('last').textContent =
          'Could not update the location. Retrying…';
      });
  }
  refresh();
  setInterval(refresh, 30000);
})();
</script>''';

/// `/t/:token/data` — JSON polled by the tracking page.
class TrackingDataRoute extends Route {
  TrackingDataRoute() : super(path: '/data');

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final view = await TrackingService.view(session, _token(request) ?? '');
    final data = view == null
        ? {'showLocation': false, 'message': 'This link is not valid.'}
        : {
            'showLocation': view.showLocation,
            'message': view.message,
            'status': view.trip.status.name,
            'points': [
              for (final p in view.points)
                {
                  'lat': p.latitude,
                  'lng': p.longitude,
                  'acc': p.accuracyMeters,
                  't': p.recordedAt.toUtc().toIso8601String(),
                },
            ],
          };
    return Response.ok(
      body: Body.fromString(jsonEncode(data), mimeType: MimeType.json),
      headers: _noStore,
    );
  }
}
