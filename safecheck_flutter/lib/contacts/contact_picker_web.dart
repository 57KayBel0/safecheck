import 'dart:js_interop';

import 'contact_picker_types.dart';

@JS('navigator')
external _Navigator get _navigator;

@JS('window')
external _Window get _window;

@JS()
extension type _Navigator(JSObject _) implements JSObject {
  external _ContactsManager? get contacts;
}

@JS()
extension type _ContactsManager(JSObject _) implements JSObject {
  external JSPromise<JSArray<_ContactInfo>> select(
    JSArray<JSString> properties,
  );

  external JSPromise<JSArray<JSString>> getProperties();
}

@JS()
extension type _ContactInfo(JSObject _) implements JSObject {
  external JSArray<JSString>? get name;
  external JSArray<JSString>? get tel;
}

@JS()
extension type _Window(JSObject _) implements JSObject {
  external JSBoolean get isSecureContext;
  external JSAny? get top;
  external JSAny? get self;
}

ContactPickerService createContactPicker() => _WebContactPicker();

class _WebContactPicker implements ContactPickerService {
  _ContactsManager? get _contacts {
    if (!_window.isSecureContext.toDart || _window.top != _window.self) {
      return null;
    }
    return _navigator.contacts;
  }

  @override
  Future<bool> isSupported() async {
    final contacts = _contacts;
    if (contacts == null) return false;
    try {
      final properties = await contacts.getProperties().toDart;
      final supported = properties.toDart.map((property) => property.toDart);
      return supported.contains('name') && supported.contains('tel');
    } catch (_) {
      return false;
    }
  }

  @override
  Future<PickedPhoneContact?> pickContact() async {
    final contacts = _contacts;
    if (contacts == null) return null;
    final selection = await contacts
        .select(['name'.toJS, 'tel'.toJS].toJS)
        .toDart;
    if (selection.toDart.isEmpty) return null;
    final contact = selection.toDart.first;
    return PickedPhoneContact(
      name: contact.name?.toDart.map((name) => name.toDart).join(' '),
      phoneNumbers:
          contact.tel?.toDart.map((number) => number.toDart).toList() ??
          const [],
    );
  }
}
