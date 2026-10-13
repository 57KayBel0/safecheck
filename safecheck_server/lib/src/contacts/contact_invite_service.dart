import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// What the public invite page needs to show.
class InviteView {
  const InviteView({
    required this.contactName,
    required this.ownerName,
    required this.status,
  });

  final String contactName;
  final String ownerName;
  final ContactOptInStatus status;
}

/// Handles a contact's answer to their invite link. The token is the only
/// credential, so it is long, random and rotated when the number changes.
abstract final class ContactInviteService {
  static Future<InviteView?> view(Session session, String token) async {
    final contact = await _findByToken(session, token);
    if (contact == null) return null;
    return _toView(session, contact);
  }

  /// Records the contact's answer. The contact may change their mind later.
  static Future<InviteView?> respond(
    Session session,
    String token, {
    required bool accept,
  }) async {
    final contact = await _findByToken(session, token);
    if (contact == null) return null;
    final updated = await TrustedContact.db.updateRow(
      session,
      contact.copyWith(
        optInStatus: accept
            ? ContactOptInStatus.accepted
            : ContactOptInStatus.declined,
        optInRespondedAt: DateTime.now().toUtc(),
      ),
    );
    return _toView(session, updated);
  }

  static Future<TrustedContact?> _findByToken(Session session, String token) {
    if (token.length < 20) return Future.value(null);
    return TrustedContact.db.findFirstRow(
      session,
      where: (t) => t.inviteToken.equals(token),
    );
  }

  static Future<InviteView> _toView(
    Session session,
    TrustedContact contact,
  ) async {
    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(contact.ownerId),
    );
    return InviteView(
      contactName: contact.name,
      ownerName: profile?.displayName ?? 'A SafeCheck user',
      status: contact.optInStatus,
    );
  }
}
