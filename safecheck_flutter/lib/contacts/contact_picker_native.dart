import 'package:flutter/foundation.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

import 'contact_picker_types.dart';

ContactPickerService createContactPicker() => _NativeContactPicker();

class _NativeContactPicker implements ContactPickerService {
  final _picker = FlutterNativeContactPicker();

  @override
  Future<bool> isSupported() async =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Future<PickedPhoneContact?> pickContact() async {
    if (!await isSupported()) return null;
    final contact = await _picker.selectContact();
    if (contact == null) return null;
    return PickedPhoneContact(
      name: contact.fullName,
      phoneNumbers: contact.phoneNumbers ?? const [],
    );
  }
}
