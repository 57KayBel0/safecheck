import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Maximum number of trusted contacts per user.
const maxTrustedContacts = 5;

/// Shortest and longest trip duration accepted by the server, in minutes.
const minTripMinutes = 1;
const maxTripMinutes = 24 * 60;

const maxDescriptionLength = 200;
const maxNameLength = 60;
const maxRelationshipLength = 40;

/// Returns the authenticated user's identifier. Endpoints using this must set
/// `requireLogin`, so a missing user is a server bug rather than a client
/// error.
String ownerIdOf(Session session) {
  final auth = session.authenticated;
  if (auth == null) {
    throw SafeCheckException(
      message: 'Please sign in to continue.',
      code: 'unauthenticated',
    );
  }
  return auth.userIdentifier;
}

SafeCheckException validationError(String message) =>
    SafeCheckException(message: message, code: 'validation');

SafeCheckException notFoundError(String message) =>
    SafeCheckException(message: message, code: 'not_found');

SafeCheckException conflictError(String message) =>
    SafeCheckException(message: message, code: 'conflict');

/// Trims [value] and collapses internal whitespace, then checks its length.
String cleanText(
  String value, {
  required String field,
  required int maxLength,
  int minLength = 1,
}) {
  final cleaned = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (cleaned.length < minLength) {
    throw validationError(
      minLength == 1
          ? '$field is required.'
          : '$field must be at least $minLength characters.',
    );
  }
  if (cleaned.length > maxLength) {
    throw validationError('$field must be at most $maxLength characters.');
  }
  return cleaned;
}

/// Like [cleanText], but returns null for blank input.
String? cleanOptionalText(
  String? value, {
  required String field,
  required int maxLength,
}) {
  if (value == null || value.trim().isEmpty) return null;
  return cleanText(value, field: field, maxLength: maxLength);
}

/// Normalises a South African phone number to E.164 (`+27XXXXXXXXX`).
///
/// Accepts the local format (`082 123 4567`), the international format
/// (`+27 82 123 4567`, `0027...`, `27...`) and common separators. Throws a
/// validation error for anything else.
String normalizeSaPhone(String input, {String field = 'Phone number'}) {
  final compact = input.replaceAll(RegExp(r'[\s\-().]'), '');
  String? national;
  if (compact.startsWith('+27')) {
    national = compact.substring(3);
  } else if (compact.startsWith('0027')) {
    national = compact.substring(4);
  } else if (compact.startsWith('27') && compact.length == 11) {
    national = compact.substring(2);
  } else if (compact.startsWith('0') && compact.length == 10) {
    national = compact.substring(1);
  }
  if (national == null || !RegExp(r'^[1-9]\d{8}$').hasMatch(national)) {
    throw validationError(
      '$field must be a valid South African number, e.g. 082 123 4567 '
      'or +27 82 123 4567.',
    );
  }
  return '+27$national';
}

/// Checks that a trip duration is within the allowed range.
void validateDuration(int minutes) {
  if (minutes < minTripMinutes || minutes > maxTripMinutes) {
    throw validationError(
      'Trip duration must be between $minTripMinutes minute and '
      '${maxTripMinutes ~/ 60} hours.',
    );
  }
}
