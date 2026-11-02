/// Wire values supported by the existing SafeCheck trip model.
/// A protocol regression test keeps this list aligned with TripType.
const plannerTripTypes = <String>[
  'walking',
  'minibusTaxi',
  'rideHailing',
  'driving',
  'publicTransport',
  'meetingSomeone',
  'other',
];

/// Invalid or unsupported model output. Never includes the model's raw text.
class InvalidTripDraft implements Exception {
  const InvalidTripDraft();

  @override
  String toString() => 'The AI response was not a valid trip draft.';
}

/// A read-only proposal, never an active trip or a scheduling instruction.
///
/// Structural and time bounds are checked here; the user must still review
/// the interpretation. Confirmation must revalidate against the server clock.
class TripPlanDraft {
  TripPlanDraft._({
    required this.tripType,
    required this.description,
    required this.checkInAtUtc,
    required List<String> questions,
  }) : questions = List.unmodifiable(questions);

  final String? tripType;
  final String? description;
  final DateTime? checkInAtUtc;
  final List<String> questions;

  bool get isReadyForReview =>
      questions.isEmpty &&
      tripType != null &&
      description != null &&
      checkInAtUtc != null;

  static const fields = <String>{
    'tripType',
    'description',
    'checkInAtUtc',
    'questions',
  };

  factory TripPlanDraft.fromJson(
    Map<String, dynamic> json, {
    required DateTime serverNow,
  }) {
    if (json.length != fields.length ||
        !json.keys.toSet().containsAll(fields)) {
      throw const InvalidTripDraft();
    }
    final type = json['tripType'];
    if (type != null && (type is! String || !plannerTripTypes.contains(type))) {
      throw const InvalidTripDraft();
    }
    final description = json['description'];
    if (description != null &&
        (description is! String ||
            description.trim().isEmpty ||
            description.trim().length > 200)) {
      throw const InvalidTripDraft();
    }
    final rawQuestions = json['questions'];
    if (rawQuestions is! List ||
        rawQuestions.length > 3 ||
        rawQuestions.any(
          (q) => q is! String || q.trim().isEmpty || q.trim().length > 200,
        )) {
      throw const InvalidTripDraft();
    }
    var questions = rawQuestions.cast<String>().map((q) => q.trim()).toList();
    final rawDeadline = json['checkInAtUtc'];
    DateTime? deadline;
    if (rawDeadline != null) {
      if (rawDeadline is! String) throw const InvalidTripDraft();
      deadline = _parseUtc(rawDeadline);
      final remaining = deadline.difference(serverNow.toUtc());
      if (remaining < const Duration(minutes: 1) ||
          remaining > const Duration(hours: 24)) {
        // A future/past or unsupported plan must never silently become active.
        deadline = null;
        questions = {
          'What check-in time should we use, between one minute and 24 hours '
              'from now? SafeCheck starts a trip when you confirm.',
          ...questions,
        }.take(3).toList();
      }
    }
    if ((type == null || description == null || deadline == null) &&
        questions.isEmpty) {
      throw const InvalidTripDraft();
    }
    return TripPlanDraft._(
      tripType: type as String?,
      description: (description as String?)?.trim(),
      checkInAtUtc: deadline,
      questions: questions,
    );
  }

  Map<String, dynamic> toJson() => {
    'tripType': tripType,
    'description': description,
    'checkInAtUtc': checkInAtUtc?.toIso8601String(),
    'questions': questions,
  };

  static DateTime _parseUtc(String text) {
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d{1,6})?Z$',
    ).firstMatch(text);
    final time = DateTime.tryParse(text);
    if (match == null || time == null || !time.isUtc) {
      throw const InvalidTripDraft();
    }
    // DateTime.parse normalizes dates such as February 30. Reject rather than
    // changing a user's proposed day or time without asking.
    final actual = [
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
    ];
    for (var i = 0; i < actual.length; i++) {
      if (actual[i] != int.parse(match.group(i + 1)!)) {
        throw const InvalidTripDraft();
      }
    }
    return time;
  }
}
