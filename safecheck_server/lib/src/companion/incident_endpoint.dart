import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'incident_service.dart';

/// Access requires a 256-bit private link, with explicit per-journey permission
/// for resolution. These endpoints never expose an owner's other incidents.
class IncidentEndpoint extends Endpoint {
  Future<IncidentView?> view(Session session, String token) =>
      IncidentService.view(session, token);
  Future<IncidentView?> resolve(Session session, String token, String note) =>
      IncidentService.resolveFromLink(session, token, note);
}
