import 'package:flutter/material.dart';

import '../contacts/contact_picker.dart';

class ContactPickerButton extends StatefulWidget {
  const ContactPickerButton({
    required this.picker,
    required this.onSelected,
    super.key,
  });

  final ContactPickerService picker;
  final ValueChanged<PickedPhoneContact> onSelected;

  @override
  State<ContactPickerButton> createState() => _ContactPickerButtonState();
}

class _ContactPickerButtonState extends State<ContactPickerButton> {
  bool? _supported;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    try {
      final supported = await widget.picker.isSupported();
      if (mounted) setState(() => _supported = supported);
    } catch (_) {
      if (mounted) setState(() => _supported = false);
    }
  }

  Future<void> _choose() async {
    setState(() => _busy = true);
    try {
      // The picker is invoked directly from this button's user gesture.
      final contact = await widget.picker.pickContact();
      if (!mounted || contact == null) return;
      final numbers = contact.phoneNumbers
          .map((number) => number.trim())
          .where((number) => number.isNotEmpty)
          .toSet()
          .toList();
      if (numbers.isEmpty) {
        _showMessage('That contact has no phone number. Enter it manually.');
        return;
      }
      final selectedNumber = numbers.length == 1
          ? numbers.single
          : await _chooseNumber(numbers);
      if (!mounted || selectedNumber == null) return;
      widget.onSelected(
        PickedPhoneContact(
          name: contact.name,
          phoneNumbers: [selectedNumber],
        ),
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Could not open contacts. Enter details below.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _chooseNumber(List<String> numbers) => showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Choose a phone number'),
      children: [
        for (final number in numbers)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, number),
            child: Text(number),
          ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_supported == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.contacts_outlined),
            label: const Text('Choose from phone contacts (unavailable)'),
          ),
          const Text(
            'Contact selection is not supported here. You can enter the '
            'details manually below.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _supported == true && !_busy ? _choose : null,
          icon: _busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.contacts_outlined),
          label: Text(
            _supported == null
                ? 'Checking contact selection…'
                : 'Choose from phone contacts',
          ),
        ),
        const Text(
          'Or enter the contact details manually below.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
