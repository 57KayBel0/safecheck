import 'contact_picker_types.dart';

ContactPickerService createContactPicker() => _UnsupportedContactPicker();

class _UnsupportedContactPicker implements ContactPickerService {
  @override
  Future<bool> isSupported() async => false;

  @override
  Future<PickedPhoneContact?> pickContact() async => null;
}
