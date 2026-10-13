import 'package:serverpod/serverpod.dart';

import '../common/links.dart';
import '../common/owner_lock.dart';
import '../common/validation.dart';
import '../generated/protocol.dart';

/// Manages the signed-in user's trusted contacts (at most five).
class ContactEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Lists the caller's trusted contacts, oldest first.
  Future<List<TrustedContact>> list(Session session) async {
    final ownerId = ownerIdOf(session);
    return TrustedContact.db.find(
      session,
      where: (t) => t.ownerId.equals(ownerId),
      orderBy: (t) => t.id,
    );
  }

  /// Adds a trusted contact. Fails if the caller already has five.
  Future<TrustedContact> add(
    Session session,
    String name,
    String phoneNumber,
    String? relationship,
  ) async {
    final ownerId = ownerIdOf(session);
    final input = _validate(name, phoneNumber, relationship);
    final now = DateTime.now().toUtc();

    return session.db.transaction((transaction) async {
      await lockOwner(session, ownerId, transaction);
      final existing = await TrustedContact.db.find(
        session,
        where: (t) => t.ownerId.equals(ownerId),
        transaction: transaction,
      );
      if (existing.length >= maxTrustedContacts) {
        throw conflictError(
          'You can have up to $maxTrustedContacts trusted contacts. '
          'Remove one before adding another.',
        );
      }
      await _checkNotDuplicateOrSelf(
        session,
        ownerId,
        input.phone,
        existing,
        transaction,
      );
      return TrustedContact.db.insertRow(
        session,
        TrustedContact(
          ownerId: ownerId,
          name: input.name,
          phoneNumber: input.phone,
          relationship: input.relationship,
          createdAt: now,
          updatedAt: now,
          optInStatus: ContactOptInStatus.pending,
          inviteToken: generateToken(),
        ),
        transaction: transaction,
      );
    });
  }

  /// Updates one of the caller's trusted contacts. Trips that already started
  /// keep the contact details they were started with.
  Future<TrustedContact> update(
    Session session,
    int contactId,
    String name,
    String phoneNumber,
    String? relationship,
  ) async {
    final ownerId = ownerIdOf(session);
    final input = _validate(name, phoneNumber, relationship);

    return session.db.transaction((transaction) async {
      await lockOwner(session, ownerId, transaction);
      final existing = await TrustedContact.db.find(
        session,
        where: (t) => t.ownerId.equals(ownerId),
        transaction: transaction,
      );
      final contact = existing.where((c) => c.id == contactId).firstOrNull;
      if (contact == null) {
        throw notFoundError('That contact could not be found.');
      }
      await _checkNotDuplicateOrSelf(
        session,
        ownerId,
        input.phone,
        existing.where((c) => c.id != contactId).toList(),
        transaction,
      );
      // A new number may belong to someone else, so they must opt in again.
      final numberChanged = contact.phoneNumber != input.phone;
      return TrustedContact.db.updateRow(
        session,
        contact.copyWith(
          name: input.name,
          phoneNumber: input.phone,
          relationship: input.relationship,
          updatedAt: DateTime.now().toUtc(),
          optInStatus: numberChanged
              ? ContactOptInStatus.pending
              : contact.optInStatus,
          optInRespondedAt: numberChanged ? null : contact.optInRespondedAt,
          inviteToken: numberChanged ? generateToken() : contact.inviteToken,
        ),
        transaction: transaction,
      );
    });
  }

  /// Returns the invite link for one of the caller's contacts, with a
  /// suggested message. The caller shares it from their own phone (e.g. a
  /// personal WhatsApp chat); SafeCheck does not send invites itself.
  Future<ContactInvite> getInvite(Session session, int contactId) async {
    final ownerId = ownerIdOf(session);
    var contact = await TrustedContact.db.findFirstRow(
      session,
      where: (t) => t.id.equals(contactId) & t.ownerId.equals(ownerId),
    );
    if (contact == null) {
      throw notFoundError('That contact could not be found.');
    }
    if (contact.inviteToken == null) {
      // Contacts added before invites existed.
      contact = await TrustedContact.db.updateRow(
        session,
        contact.copyWith(inviteToken: generateToken()),
      );
    }
    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(ownerId),
    );
    final url = inviteUrl(session, contact.inviteToken!);
    final from = profile?.displayName ?? 'A friend';
    return ContactInvite(
      url: url,
      message:
          'Hi ${contact.name}, $from would like to add you as a trusted '
          'contact on SafeCheck. If they miss a check-in after a trip, you '
          'could get an alert. Please accept or decline here: $url',
    );
  }

  /// Removes one of the caller's trusted contacts.
  Future<void> remove(Session session, int contactId) async {
    final ownerId = ownerIdOf(session);
    final deleted = await TrustedContact.db.deleteWhere(
      session,
      where: (t) => t.id.equals(contactId) & t.ownerId.equals(ownerId),
    );
    if (deleted.isEmpty) {
      throw notFoundError('That contact could not be found.');
    }
  }

  ({String name, String phone, String? relationship}) _validate(
    String name,
    String phoneNumber,
    String? relationship,
  ) {
    return (
      name: cleanText(name, field: 'Contact name', maxLength: maxNameLength),
      phone: normalizeSaPhone(phoneNumber, field: 'Contact phone number'),
      relationship: cleanOptionalText(
        relationship,
        field: 'Relationship',
        maxLength: maxRelationshipLength,
      ),
    );
  }

  Future<void> _checkNotDuplicateOrSelf(
    Session session,
    String ownerId,
    String phone,
    List<TrustedContact> others,
    Transaction transaction,
  ) async {
    if (others.any((c) => c.phoneNumber == phone)) {
      throw validationError('You already have a contact with that number.');
    }
    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(ownerId),
      transaction: transaction,
    );
    if (profile?.phoneNumber == phone) {
      throw validationError(
        'A trusted contact needs a different number from your own.',
      );
    }
  }
}
