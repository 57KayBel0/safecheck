import 'package:serverpod/serverpod.dart';

/// Serialises writes for one user until [transaction] ends, using a Postgres
/// transaction-level advisory lock. This protects invariants that span rows,
/// such as "at most five contacts", against concurrent requests.
Future<void> lockOwner(
  Session session,
  String ownerId,
  Transaction transaction,
) async {
  await session.db.unsafeQuery(
    "SELECT pg_advisory_xact_lock(hashtext('safecheck_owner:' || @owner))",
    parameters: QueryParameters.named({'owner': ownerId}),
    transaction: transaction,
  );
}
