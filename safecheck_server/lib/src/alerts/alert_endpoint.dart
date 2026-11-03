import 'package:serverpod/serverpod.dart';

import '../common/validation.dart';
import '../generated/protocol.dart';
import '../companion/incident_service.dart';

/// Lists the alerts raised for the signed-in user's missed check-ins and the
/// messages created for their contacts.
class AlertEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<SafetyAlert> resolveIncident(
    Session session,
    int alertId,
    String note,
  ) => IncidentService.resolveOwner(session, ownerIdOf(session), alertId, note);

  /// The caller's alerts, newest first.
  Future<List<SafetyAlert>> listAlerts(Session session) {
    final ownerId = ownerIdOf(session);
    return SafetyAlert.db.find(
      session,
      where: (t) => t.ownerId.equals(ownerId),
      orderBy: (t) => t.createdAt.desc(),
      limit: 50,
    );
  }

  /// Messages for the caller's alerts, newest first. In this version every
  /// message has status `simulated`: nothing was sent.
  Future<List<AlertMessage>> listMessages(Session session) {
    final ownerId = ownerIdOf(session);
    return AlertMessage.db.find(
      session,
      where: (t) => t.ownerId.equals(ownerId),
      orderBy: (t) => t.id.desc(),
      limit: 100,
    );
  }
}
