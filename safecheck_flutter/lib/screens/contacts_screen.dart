import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

import '../app_events.dart';
import '../client.dart';
import '../contacts/contact_picker.dart';
import '../util/errors.dart';
import '../util/contact_validation.dart';
import '../widgets/contact_picker_button.dart';
import '../widgets/state_views.dart';

const _maxContacts = 5;

/// Lists, adds, edits and removes trusted contacts.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({this.contactPicker, super.key});

  final ContactPickerService? contactPicker;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<TrustedContact>? _contacts;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    dataRevision.addListener(_reloadSilently);
    _load();
  }

  @override
  void dispose() {
    dataRevision.removeListener(_reloadSilently);
    super.dispose();
  }

  void _reloadSilently() => _load(silent: true);

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final contacts = await client.contact.list();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || (silent && _contacts != null)) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _openEditor([TrustedContact? contact]) async {
    final saved = await showModalBottomSheet<TrustedContact>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ContactEditor(
        contact: contact,
        picker: widget.contactPicker,
      ),
    );
    if (saved == null || !mounted) return;
    showSnack(
      context,
      contact == null ? '${saved.name} added.' : '${saved.name} updated.',
    );
    notifyDataChanged();
  }

  Future<void> _remove(TrustedContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${contact.name}?'),
        content: const Text(
          'They will not be included in future trips. Trips that already '
          'started keep their contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await client.contact.remove(contact.id!);
      if (!mounted) return;
      showSnack(context, '${contact.name} removed.');
      notifyDataChanged();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(label: 'Loading contacts…');
    if (_error != null) {
      return ErrorView(message: friendlyError(_error!), onRetry: _load);
    }
    final contacts = _contacts!;
    final full = contacts.length >= _maxContacts;

    return Scaffold(
      floatingActionButton: full
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add contact'),
            ),
      body: RefreshIndicator(
        onRefresh: () => _load(silent: true),
        child: contacts.isEmpty
            ? const EmptyView(
                icon: Icons.people_outline,
                title: 'No trusted contacts yet',
                message:
                    'Add up to five people who should be alerted if you '
                    "miss a check-in. You need at least one to start a trip.",
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(
                    '${contacts.length} of $_maxContacts contacts'
                    '${full ? ' · remove one to add another' : ''}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  for (final c in contacts)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                        leading: CircleAvatar(
                          child: Text(c.name.characters.first.toUpperCase()),
                        ),
                        title: Text(c.name),
                        subtitle: Text(
                          [
                            c.relationship,
                            c.phoneNumber,
                          ].whereType<String>().join(' · '),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit ${c.name}',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openEditor(c),
                            ),
                            IconButton(
                              tooltip: 'Remove ${c.name}',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _remove(c),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _ContactEditor extends StatefulWidget {
  const _ContactEditor({this.contact, this.picker});

  final TrustedContact? contact;
  final ContactPickerService? picker;

  @override
  State<_ContactEditor> createState() => _ContactEditorState();
}

class _ContactEditorState extends State<_ContactEditor> {
  final _formKey = GlobalKey<FormState>();
  late final _picker = widget.picker ?? createContactPicker();
  late final _name = TextEditingController(text: widget.contact?.name);
  late final _phone = TextEditingController(text: widget.contact?.phoneNumber);
  late final _relationship = TextEditingController(
    text: widget.contact?.relationship,
  );
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _relationship.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final existing = widget.contact;
      final saved = existing == null
          ? await client.contact.add(
              _name.text,
              _phone.text,
              _relationship.text,
            )
          : await client.contact.update(
              existing.id!,
              _name.text,
              _phone.text,
              _relationship.text,
            );
      if (mounted) Navigator.of(context).pop(saved);
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
    final editing = widget.contact != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                editing ? 'Edit contact' : 'Add trusted contact',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (!editing) ...[
                ContactPickerButton(
                  picker: _picker,
                  onSelected: (contact) {
                    final name = contact.name?.trim();
                    if (name != null && name.isNotEmpty) _name.text = name;
                    _phone.text = contact.phoneNumbers.single;
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _name,
                autofocus: !editing,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                maxLength: 60,
                validator: validateContactName,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  hintText: '082 123 4567',
                  helperText: 'South African number',
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: validateContactPhone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship (optional)',
                  hintText: 'e.g. Sister, Housemate',
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 40,
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 8),
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
                    : Text(editing ? 'Save changes' : 'Add contact'),
              ),
              if (editing) ...[
                const SizedBox(height: 8),
                Text(
                  'Changes apply to future trips. A trip that already '
                  'started keeps the details it started with.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
