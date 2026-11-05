import 'package:serverpod/serverpod.dart';
import 'incident_service.dart';

class IncidentSummaryFutureCall extends FutureCall {
  Future<void> generate(Session session, int alertId) async {
    IncidentService.launch(session.serverpod, alertId);
  }
}
