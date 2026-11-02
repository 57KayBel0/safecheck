import 'dart:convert';

import 'package:safecheck_client/safecheck_client.dart';

/// A display-only draft received from the authenticated planning endpoint.
class TripDraft {
  const TripDraft({
    required this.tripType,
    required this.description,
    required this.checkInAtUtc,
    required this.questions,
  });

  final TripType? tripType;
  final String? description;
  final DateTime? checkInAtUtc;
  final List<String> questions;

  bool get ready =>
      tripType != null &&
      description != null &&
      checkInAtUtc != null &&
      questions.isEmpty;

  factory TripDraft.decode(String response) {
    final json = jsonDecode(response) as Map<String, dynamic>;
    final type = json['tripType'] as String?;
    final description = json['description'] as String?;
    final rawTime = json['checkInAtUtc'] as String?;
    final time = rawTime == null ? null : DateTime.parse(rawTime);
    final questions = (json['questions'] as List).cast<String>();
    if (json.length != 4 ||
        (type != null && !TripType.values.any((t) => t.name == type)) ||
        (description != null &&
            (description.trim().isEmpty || description.length > 200)) ||
        (time != null && (!time.isUtc || !rawTime!.endsWith('Z'))) ||
        questions.length > 3 ||
        questions.any((q) => q.isEmpty || q.length > 200)) {
      throw const FormatException('Invalid trip draft');
    }
    final tripType = type == null ? null : TripType.values.byName(type);
    if ((tripType == null || description == null || time == null) &&
        questions.isEmpty) {
      throw const FormatException('Incomplete trip draft');
    }
    return TripDraft(
      tripType: tripType,
      description: description,
      checkInAtUtc: time,
      questions: List.unmodifiable(questions),
    );
  }
}
