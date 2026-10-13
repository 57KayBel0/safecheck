import 'contact_picker_types.dart';
import 'contact_picker_stub.dart'
    if (dart.library.io) 'contact_picker_native.dart'
    if (dart.library.js_interop) 'contact_picker_web.dart'
    as platform;

export 'contact_picker_types.dart';

ContactPickerService createContactPicker() => platform.createContactPicker();
