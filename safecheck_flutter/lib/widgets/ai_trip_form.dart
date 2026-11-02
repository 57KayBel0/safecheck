import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

import '../planning/trip_draft.dart';
import '../reminders/check_in_reminder.dart';
import '../util/errors.dart';
import '../util/format.dart';
import 'state_views.dart';
import 'trip_review_dialog.dart';

/// Natural-language proposal → clarification → review → explicit start.
/// Only [onStart] can activate a trip, and only after a confirmed review.
class AiTripForm extends StatefulWidget {
  const AiTripForm({
    super.key,
    required this.propose,
    required this.loadContacts,
    required this.serverNow,
    required this.onStart,
    required this.onUseManual,
    required this.onOpenContacts,
    required this.onBusyChanged,
  });

  final Future<String> Function(String, List<String>) propose;
  final Future<List<TrustedContact>> Function() loadContacts;
  final DateTime Function() serverNow;
  final Future<void> Function(
    TripType,
    String,
    DateTime,
    CheckInReminderMode,
    LocationSharing,
  )
  onStart;
  final VoidCallback onUseManual;
  final VoidCallback onOpenContacts;
  final ValueChanged<bool> onBusyChanged;

  @override
  State<AiTripForm> createState() => _AiTripFormState();
}

enum _Phase { idle, proposing, loadingContacts, reviewing, starting }

class _AiTripFormState extends State<AiTripForm> {
  final _input = TextEditingController();
  final _history = <String>[];
  _Phase _phase = _Phase.idle;
  TripDraft? _draft;
  String? _error;
  LocationSharing _sharing = LocationSharing.off;

  bool get _busy => _phase != _Phase.idle;
  bool get _working => _busy && _phase != _Phase.reviewing;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _setPhase(_Phase phase) {
    setState(() => _phase = phase);
    widget.onBusyChanged(phase != _Phase.idle);
  }

  Future<void> _propose() async {
    if (_busy) return;
    final input = _input.text.trim();
    if (input.isEmpty || input.length > 1500) {
      setState(() => _error = 'Describe your trip in 1–1500 characters.');
      return;
    }
    if (_history.length > 6) {
      setState(
        () => _error = 'Start a new draft or use manual setup to continue.',
      );
      return;
    }
    _setPhase(_Phase.proposing);
    setState(() => _error = null);
    // A changed request makes the previous proposal ineligible for review,
    // even if this new request fails. Never start an older interpretation.
    setState(() => _draft = null);
    try {
      final response = await widget
          .propose(input, List.of(_history))
          .timeout(const Duration(seconds: 40));
      final draft = TripDraft.decode(response);
      if (!mounted) return;
      setState(() {
        _history.addAll([input, response]);
        _draft = draft;
        _input.clear();
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _error = error is FormatException || error is TypeError
            ? 'The AI returned an invalid draft. Try again or use manual setup.'
            : error is TimeoutException
            ? 'AI planning took too long. Try again or use manual setup.'
            : friendlyError(error),
      );
    } finally {
      if (mounted) _setPhase(_Phase.idle);
    }
  }

  bool _timeIsValid(TripDraft draft) {
    final remaining = draft.checkInAtUtc!.difference(
      widget.serverNow().toUtc(),
    );
    return remaining >= const Duration(minutes: 1) &&
        remaining <= const Duration(hours: 24);
  }

  Future<void> _review() async {
    final draft = _draft;
    if (_busy || draft == null || !draft.ready) return;
    if (_input.text.trim().isNotEmpty) {
      setState(() => _error = 'Send your changes before reviewing this draft.');
      return;
    }
    _setPhase(_Phase.loadingContacts);
    setState(() => _error = null);
    final sharing = _sharing;
    try {
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
      if (!_timeIsValid(draft)) {
        setState(
          () => _error =
              'This check-in time is too close or has passed. Ask for a new time.',
        );
        return;
      }
      _setPhase(_Phase.reviewing);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => TripReviewDialog(
          tripType: draft.tripType!,
          description: draft.description!,
          durationMinutes: draft.checkInAtUtc!
              .difference(widget.serverNow())
              .inMinutes,
          estimatedDeadline: draft.checkInAtUtc!,
          exactDeadline: true,
          contacts: contacts,
          locationSharing: sharing,
          reminderMode: CheckInReminderMode.silent,
        ),
      );
      if (!mounted || confirmed != true) return;
      if (!_timeIsValid(draft)) {
        setState(
          () => _error = 'This draft has expired. Ask for a new check-in time.',
        );
        return;
      }
      _setPhase(_Phase.starting);
      // No timeout/retry on a mutation: a late server reply could have started
      // the trip. The normal active-trip refresh reconciles connection loss.
      await widget.onStart(
        draft.tripType!,
        draft.description!,
        draft.checkInAtUtc!,
        CheckInReminderMode.silent,
        sharing,
      );
    } catch (error) {
      if (mounted) setState(() => _error = friendlyError(error));
    } finally {
      if (mounted) _setPhase(_Phase.idle);
    }
  }

  void _reset() {
    setState(() {
      _history.clear();
      _draft = null;
      _error = null;
      _input.clear();
      _sharing = LocationSharing.off;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final draft = _draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Describe your trip', style: text.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'SafeCheck AI helps turn your plans into a check-in. '
          'Nothing starts until you review and confirm.',
          style: text.bodyLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Your trip text and this planning conversation are processed by Meta. '
          'SafeCheck does not add your contacts or GPS to this request. '
          'Times default to South Africa (SAST).',
          style: text.bodySmall,
        ),
        if (draft != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.ready
                        ? 'Draft ready for review'
                        : 'A few details to clarify',
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (draft.tripType != null)
                    Text(tripTypeLabel(draft.tripType!)),
                  if (draft.description != null) Text(draft.description!),
                  if (draft.checkInAtUtc != null)
                    Text(formatSastDateTime(context, draft.checkInAtUtc!)),
                  for (final question in draft.questions)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(question),
                    ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          key: const Key('ai-trip-input'),
          controller: _input,
          enabled: !_busy && _history.length <= 6,
          minLines: 3,
          maxLines: 5,
          maxLength: 1500,
          decoration: InputDecoration(
            labelText: draft == null
                ? 'What is your plan?'
                : 'Your answer or changes',
            hintText:
                'I’m taking a taxi from Pretoria CBD to Mamelodi now. '
                'I’ll check in in 45 minutes.',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy || _history.length > 6 ? null : _propose,
          icon: const Icon(Icons.auto_awesome_outlined),
          label: Text(
            _phase == _Phase.proposing
                ? 'Preparing draft…'
                : _history.isEmpty
                ? 'Prepare my draft'
                : 'Send answer or changes',
          ),
        ),
        if (draft?.ready == true) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<LocationSharing>(
            isExpanded: true,
            initialValue: _sharing,
            decoration: const InputDecoration(labelText: 'Location sharing'),
            items: const [
              DropdownMenuItem(
                value: LocationSharing.off,
                child: Text('Off (default)'),
              ),
              DropdownMenuItem(
                value: LocationSharing.afterAlert,
                child: Text('After a missed check-in'),
              ),
              DropdownMenuItem(
                value: LocationSharing.live,
                child: Text('Live'),
              ),
            ],
            onChanged: _busy
                ? null
                : (v) {
                    if (v != null) setState(() => _sharing = v);
                  },
          ),
          const SizedBox(height: 8),
          const Text(
            'Silent reminder while the app is open. Location is off unless you choose otherwise.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy || _input.text.trim().isNotEmpty ? null : _review,
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(
              _phase == _Phase.starting ? 'Starting trip…' : 'Review AI draft',
            ),
          ),
        ],
        if (_working) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (_error != null) ...[
          const SizedBox(height: 12),
          ErrorBanner(message: _error!),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            TextButton(
              onPressed: _busy ? null : widget.onUseManual,
              child: const Text('Use manual setup'),
            ),
            TextButton(
              onPressed: _busy ? null : _reset,
              child: const Text('New draft'),
            ),
            TextButton(
              onPressed: _busy ? null : widget.onOpenContacts,
              child: const Text('Manage contacts'),
            ),
          ],
        ),
      ],
    );
  }
}
