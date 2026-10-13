import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safecheck_flutter/contacts/contact_picker.dart';
import 'package:safecheck_flutter/util/contact_validation.dart';
import 'package:safecheck_flutter/widgets/contact_picker_button.dart';

class FakeContactPicker implements ContactPickerService {
  FakeContactPicker({required this.supported, this.result});

  final bool supported;
  final PickedPhoneContact? result;
  int calls = 0;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<PickedPhoneContact?> pickContact() async {
    calls++;
    return result;
  }
}

void main() {
  Future<void> showPicker(
    WidgetTester tester,
    FakeContactPicker picker,
    ValueChanged<PickedPhoneContact> onSelected, {
    TextEditingController? name,
    TextEditingController? phone,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ContactPickerButton(picker: picker, onSelected: onSelected),
              if (name != null) TextField(controller: name),
              if (phone != null) TextField(controller: phone),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> openNumberDialog(WidgetTester tester) async {
    await tester.tap(find.text('Choose from phone contacts'));
    // Flush the fake picker future and build the dialog, then finish its
    // entrance transition. The busy spinner intentionally keeps animating
    // until the dialog returns, so pumpAndSettle cannot be used here.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Choose a phone number'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
  }

  void expectPickerReady(WidgetTester tester) {
    expect(find.text('Choose a phone number'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );
  }

  testWidgets('selection populates the reviewed name and phone values', (
    tester,
  ) async {
    final picker = FakeContactPicker(
      supported: true,
      result: const PickedPhoneContact(
        name: 'A trusted person',
        phoneNumbers: ['  +27 82 123 4567  '],
      ),
    );
    PickedPhoneContact? selected;
    await showPicker(tester, picker, (contact) => selected = contact);

    await tester.tap(find.text('Choose from phone contacts'));
    await tester.pump();

    expect(picker.calls, 1);
    expect(selected?.name, 'A trusted person');
    expect(selected?.phoneNumbers, ['+27 82 123 4567']);
    expectPickerReady(tester);
  });

  testWidgets('several numbers require an explicit user choice', (
    tester,
  ) async {
    final picker = FakeContactPicker(
      supported: true,
      result: const PickedPhoneContact(
        name: 'A trusted person',
        phoneNumbers: ['082 111 1111', '083 222 2222'],
      ),
    );
    PickedPhoneContact? selected;
    final name = TextEditingController(text: 'Existing name');
    final phone = TextEditingController(text: '084 333 3333');
    addTearDown(name.dispose);
    addTearDown(phone.dispose);
    await showPicker(
      tester,
      picker,
      (contact) {
        selected = contact;
        name.text = contact.name!;
        phone.text = contact.phoneNumbers.single;
      },
      name: name,
      phone: phone,
    );

    await openNumberDialog(tester);
    expect(picker.calls, 1);
    expect(selected, isNull);
    expect(name.text, 'Existing name');
    expect(phone.text, '084 333 3333');
    await tester.tap(find.text('083 222 2222'));
    await tester.pumpAndSettle();

    expect(selected?.name, 'A trusted person');
    expect(selected?.phoneNumbers, ['083 222 2222']);
    expect(name.text, 'A trusted person');
    expect(phone.text, '083 222 2222');
    expectPickerReady(tester);
  });

  testWidgets('canceling phone selection leaves the form unchanged', (
    tester,
  ) async {
    final picker = FakeContactPicker(
      supported: true,
      result: const PickedPhoneContact(
        name: 'A trusted person',
        phoneNumbers: ['082 111 1111', '083 222 2222'],
      ),
    );
    PickedPhoneContact? selected;
    final name = TextEditingController(text: 'Existing name');
    final phone = TextEditingController(text: '084 333 3333');
    addTearDown(name.dispose);
    addTearDown(phone.dispose);
    await showPicker(
      tester,
      picker,
      (contact) {
        selected = contact;
        name.text = contact.name!;
        phone.text = contact.phoneNumbers.single;
      },
      name: name,
      phone: phone,
    );

    await openNumberDialog(tester);
    expect(selected, isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(name.text, 'Existing name');
    expect(phone.text, '084 333 3333');
    expectPickerReady(tester);
  });

  testWidgets('canceling the device picker leaves the form unchanged', (
    tester,
  ) async {
    final picker = FakeContactPicker(supported: true);
    PickedPhoneContact? selected;
    await showPicker(tester, picker, (contact) => selected = contact);

    await tester.tap(find.text('Choose from phone contacts'));
    await tester.pump();

    expect(selected, isNull);
    expect(find.text('Choose from phone contacts'), findsOneWidget);
    expectPickerReady(tester);
  });

  testWidgets('a selected contact without a phone is not accepted', (
    tester,
  ) async {
    final picker = FakeContactPicker(
      supported: true,
      result: const PickedPhoneContact(name: 'No number', phoneNumbers: []),
    );
    PickedPhoneContact? selected;
    await showPicker(tester, picker, (contact) => selected = contact);

    await tester.tap(find.text('Choose from phone contacts'));
    await tester.pump();

    expect(selected, isNull);
    expect(
      find.text('That contact has no phone number. Enter it manually.'),
      findsOneWidget,
    );
  });

  testWidgets('unsupported browsers explain manual entry and disable picker', (
    tester,
  ) async {
    final picker = FakeContactPicker(supported: false);
    await showPicker(tester, picker, (_) {});

    final button = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );
    expect(button.onPressed, isNull);
    expect(
      find.textContaining('You can enter the details manually below.'),
      findsOneWidget,
    );
    expect(
      find.text('Choose from phone contacts (unavailable)'),
      findsOneWidget,
    );
    expect(picker.calls, 0);
  });

  test('contact form still validates required name and phone', () {
    expect(validateContactName('  '), 'Enter a name.');
    expect(validateContactName('Sam'), isNull);
    expect(validateContactPhone(''), 'Enter a mobile number.');
    expect(validateContactPhone('082 123 4567'), isNull);
  });
}
