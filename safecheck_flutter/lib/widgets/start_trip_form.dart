import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

import '../reminders/check_in_reminder.dart';
import '../reminders/reminder_feedback.dart';
import '../util/errors.dart';
import '../util/format.dart';
import 'state_views.dart';
import 'trip_review_dialog.dart';

/// Prepares a trip for review before invoking the server-side start operation.
class StartTripForm extends StatefulWidget {
  const StartTripForm({
    super.key,
    required this.contacts,
    required this.loadContacts,
    required this.serverNow,
    required this.onOpenContacts,
    required this.onStart,
  });

  final List<TrustedContact> contacts;
  final Future<List<TrustedContact>> Function() loadContacts;
  final DateTime Function() serverNow;
  final VoidCallback onOpenContacts;
  final Future<void> Function(
    TripType,
    String,
    int,
    CheckInReminderMode,
    LocationSharing,
  )
  onStart;

  @override
  State<StartTripForm> createState() => _StartTripFormState();
}

enum _StartTripPhase { idle, loadingContacts, reviewing, starting }

class _StartTripFormState extends State<StartTripForm> {
  static const _presets = [15, 30, 60, 120, 240];

  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _customMinutes = TextEditingController();
  TripType _type = TripType.walking;
  int? _presetMinutes = 30;
  _StartTripPhase _phase = _StartTripPhase.idle;
  bool get _busy => _phase != _StartTripPhase.idle;
  bool get _working =>
      _phase == _StartTripPhase.loadingContacts ||
      _phase == _StartTripPhase.starting;
  String get _buttonLabel => switch (_phase) {
    _StartTripPhase.idle => 'Review trip',
    _StartTripPhase.loadingContacts => 'Loading contacts…',
    _StartTripPhase.reviewing => 'Review in progress',
    _StartTripPhase.starting => 'Starting trip…',
  };
  CheckInReminderMode _reminderMode = CheckInReminderMode.silent;
  LocationSharing _sharing = LocationSharing.off;
  String? _error;

  @override
  void dispose() {
    _description.dispose();
    _customMinutes.dispose();
    super.dispose();
  }

  int? get _minutes => _presetMinutes ?? int.tryParse(_customMinutes.text);

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _phase = _StartTripPhase.loadingContacts;
      _error = null;
    });
    final type = _type;
    final description = _description.text.trim();
    final minutes = _minutes!;
    final reminderMode = _reminderMode;
    final sharing = _sharing;
    try {
      // Refresh before review so edits made since this screen loaded are shown.
      final contacts = await widget.loadContacts().timeout(
        const Duration(seconds: 20),
      );
      if (!mounted) return;
      if (contacts.isEmpty) {
        setState(
          () => _error = 'Add a trusted contact before starting a trip.',
        );
        return;
      }
      final deadline = widget.serverNow().add(Duration(minutes: minutes));
      setState(() => _phase = _StartTripPhase.reviewing);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => TripReviewDialog(
          tripType: type,
          description: description,
          durationMinutes: minutes,
          estimatedDeadline: deadline,
          contacts: contacts,
          locationSharing: sharing,
          reminderMode: reminderMode,
        ),
      );
      if (!mounted || confirmed != true) return;
      setState(() => _phase = _StartTripPhase.starting);
      await widget.onStart(type, description, minutes, reminderMode, sharing);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _phase = _StartTripPhase.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final noContacts = widget.contacts.isEmpty;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Start a trip', style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(
            "Tell SafeCheck where you're going and when you expect to "
            "arrive. If you don't check in in time, an alert is created.",
            style: text.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (noContacts) ...[
            Card(
              color: colors.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a trusted contact first',
                      style: text.titleMedium?.copyWith(
                        color: colors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You need at least one trusted contact before starting '
                      'a trip.',
                      style: TextStyle(color: colors.onSecondaryContainer),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: widget.onOpenContacts,
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add contacts'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Trip type', style: text.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in TripType.values)
                ChoiceChip(
                  avatar: Icon(tripTypeIcon(type), size: 18),
                  label: Text(tripTypeLabel(type)),
                  selected: _type == type,
                  showCheckmark: false,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _description,
            enabled: !_busy,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'e.g. Taxi from Bree Street rank to Soweto',
            ),
            maxLength: 200,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            validator: (v) => (v ?? '').trim().isEmpty
                ? 'Describe your trip so contacts know where you were.'
                : null,
          ),
          const SizedBox(height: 12),
          Text('Check in within', style: text.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in _presets)
                ChoiceChip(
                  label: Text(formatDurationShort(m)),
                  selected: _presetMinutes == m,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _presetMinutes = m),
                ),
              ChoiceChip(
                label: const Text('Custom'),
                selected: _presetMinutes == null,
                onSelected: _busy
                    ? null
                    : (_) => setState(() => _presetMinutes = null),
              ),
            ],
          ),
          if (_presetMinutes == null) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _customMinutes,
              enabled: !_busy,
              decoration: const InputDecoration(
                labelText: 'Minutes',
                helperText: 'Between 1 minute and 24 hours (1440 minutes)',
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 1 || n > 1440) {
                  return 'Enter a number from 1 to 1440.';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),
          DropdownButtonFormField<LocationSharing>(
            initialValue: _sharing,
            decoration: const InputDecoration(labelText: 'Location sharing'),
            items: const [
              DropdownMenuItem(
                value: LocationSharing.live,
                child: Text('Live'),
              ),
              DropdownMenuItem(
                value: LocationSharing.afterAlert,
                child: Text('After a missed check-in'),
              ),
              DropdownMenuItem(value: LocationSharing.off, child: Text('Off')),
            ],
            onChanged: _busy
                ? null
                : (value) {
                    if (value != null) setState(() => _sharing = value);
                  },
          ),
          if (_sharing != LocationSharing.off)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'After starting, use Enable location if permission is needed. SafeCheck records GPS points while this app is running. '
                'You can continue without location if it is unavailable; your check-in still works.',
              ),
            ),
          Text('Reminder', style: text.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Reminders appear only while this app is open. A closed or '
            'suspended browser may not show one; the server still processes '
            'the check-in deadline.',
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
          Text(
            'Sound or vibration may attract attention.',
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          RadioGroup<CheckInReminderMode>(
            groupValue: _reminderMode,
            onChanged: (value) {
              if (value != null && !_busy && reminderModeSupported(value)) {
                setState(() => _reminderMode = value);
              }
            },
            child: Column(
              children: [
                RadioListTile<CheckInReminderMode>(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Silent (default)'),
                  subtitle: const Text('In-app reminder only'),
                  value: CheckInReminderMode.silent,
                  enabled: !_busy,
                ),
                RadioListTile<CheckInReminderMode>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    reminderModeSupported(CheckInReminderMode.vibration)
                        ? 'Vibration'
                        : 'Vibration (unavailable on this platform)',
                  ),
                  subtitle: const Text('May attract attention'),
                  value: CheckInReminderMode.vibration,
                  enabled:
                      !_busy &&
                      reminderModeSupported(CheckInReminderMode.vibration),
                ),
                RadioListTile<CheckInReminderMode>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    reminderModeSupported(CheckInReminderMode.sound)
                        ? 'Sound'
                        : 'Sound (unavailable on this platform)',
                  ),
                  subtitle: const Text('May attract attention'),
                  value: CheckInReminderMode.sound,
                  enabled:
                      !_busy &&
                      reminderModeSupported(CheckInReminderMode.sound),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_minutes != null && _minutes! >= 1 && _minutes! <= 1440)
            Text(
              'About ${formatTime(context, widget.serverNow().add(Duration(minutes: _minutes!)))}'
              '. The server sets the exact deadline when the trip starts.',
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            ErrorBanner(message: _error!),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            onPressed: _busy || noContacts ? null : _submit,
            icon: _working
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(Icons.fact_check_outlined),
            label: Text(_buttonLabel),
          ),
        ],
      ),
    );
  }
}
