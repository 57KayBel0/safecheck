import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

import '../client.dart';
import '../util/errors.dart';
import '../widgets/state_views.dart';

/// Creates (during onboarding) or edits the user's profile.
///
/// During onboarding [onSaved] is called with the new profile. When pushed as
/// a route, the saved profile is returned with `Navigator.pop`.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.existing,
    this.onboarding = false,
    this.onSaved,
    this.onSignOut,
  });

  final UserProfile? existing;
  final bool onboarding;
  final ValueChanged<UserProfile>? onSaved;
  final VoidCallback? onSignOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.displayName);
  late final _phone = TextEditingController(
    text: widget.existing?.phoneNumber,
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final profile = await client.profile.saveProfile(_name.text, _phone.text);
      if (!mounted) return;
      if (widget.onSaved != null) {
        widget.onSaved!(profile);
      } else {
        Navigator.of(context).pop(profile);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = friendlyError(e);
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.onboarding ? 'Welcome' : 'Edit profile'),
        actions: [
          if (widget.onSignOut != null)
            TextButton(
              onPressed: widget.onSignOut,
              child: const Text('Sign out'),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.onboarding) ...[
                      Text('Set up your profile', style: text.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        'Your name and number are included in alerts so your '
                        'trusted contacts know who needs help.',
                        style: text.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                    ],
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        hintText: 'e.g. Thandi',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      maxLength: 60,
                      validator: (v) => (v ?? '').trim().length < 2
                          ? 'Enter at least 2 characters.'
                          : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile number',
                        hintText: '082 123 4567',
                        helperText: 'South African number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      onFieldSubmitted: (_) => _save(),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Enter your mobile number.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      ErrorBanner(message: _error!),
                      const SizedBox(height: 16),
                    ],
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : Text(widget.onboarding ? 'Continue' : 'Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
