class PickedPhoneContact {
  const PickedPhoneContact({this.name, required this.phoneNumbers});

  final String? name;
  final List<String> phoneNumbers;
}

abstract interface class ContactPickerService {
  Future<bool> isSupported();

  /// Returns null when the user cancels.
  Future<PickedPhoneContact?> pickContact();
}
