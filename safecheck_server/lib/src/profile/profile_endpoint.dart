import 'package:serverpod/serverpod.dart';

import '../common/validation.dart';
import '../generated/protocol.dart';

/// Reads and updates the signed-in user's own profile.
class ProfileEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the caller's profile, or null if they have not set one up yet.
  Future<UserProfile?> getProfile(Session session) async {
    final ownerId = ownerIdOf(session);
    return UserProfile.db.findFirstRow(
      session,
      where: (t) => t.ownerId.equals(ownerId),
    );
  }

  /// Creates or updates the caller's profile.
  Future<UserProfile> saveProfile(
    Session session,
    String displayName,
    String phoneNumber,
  ) async {
    final ownerId = ownerIdOf(session);
    final name = cleanText(
      displayName,
      field: 'Display name',
      minLength: 2,
      maxLength: maxNameLength,
    );
    final phone = normalizeSaPhone(phoneNumber);
    final now = DateTime.now().toUtc();

    return session.db.transaction((transaction) async {
      final existing = await UserProfile.db.findFirstRow(
        session,
        where: (t) => t.ownerId.equals(ownerId),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (existing != null) {
        return UserProfile.db.updateRow(
          session,
          existing.copyWith(
            displayName: name,
            phoneNumber: phone,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      }
      return UserProfile.db.insertRow(
        session,
        UserProfile(
          ownerId: ownerId,
          displayName: name,
          phoneNumber: phone,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
    });
  }
}
