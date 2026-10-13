String? validateContactName(String? value) =>
    (value ?? '').trim().isEmpty ? 'Enter a name.' : null;

String? validateContactPhone(String? value) =>
    (value ?? '').trim().isEmpty ? 'Enter a mobile number.' : null;
