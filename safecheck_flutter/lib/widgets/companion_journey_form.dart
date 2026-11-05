import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';
import '../planning/trip_draft.dart';
import '../reminders/check_in_reminder.dart';
import '../util/errors.dart';
import '../util/format.dart';
import 'state_views.dart';
import 'trip_review_dialog.dart';
import 'safety_plan_card.dart';
import 'safety_design.dart';

/// The home journey builder. AI may suggest; only confirmed requests act.
class CompanionJourneyForm extends StatefulWidget {
  const CompanionJourneyForm({
    super.key,
    required this.contacts,
    required this.loadContacts,
    required this.serverNow,
    required this.propose,
    required this.preparePlan,
    required this.onStart,
    required this.onOpenContacts,
    required this.onBusyChanged,
    required this.aiAvailable,
    required this.onRetryAvailability,
    this.availabilityMessage,
  });
  final List<TrustedContact> contacts;
  final Future<List<TrustedContact>> Function() loadContacts;
  final DateTime Function() serverNow;
  final Future<String> Function(String, List<String>) propose;
  final Future<String> Function(TripType, String, DateTime, int) preparePlan;
  final Future<void> Function(JourneyRequest) onStart;
  final VoidCallback onOpenContacts;
  final ValueChanged<bool> onBusyChanged;
  final bool? aiAvailable;
  final String? availabilityMessage;
  final VoidCallback onRetryAvailability;
  @override
  State<CompanionJourneyForm> createState() => _CompanionJourneyFormState();
}

class _CompanionJourneyFormState extends State<CompanionJourneyForm> {
  final _input = TextEditingController();
  final _description = TextEditingController();
  final _history = <String>[];
  final _selected = <int>{};
  TripType _type = TripType.walking;
  int _minutes = 30;
  int _grace = 0;
  DateTime? _absolute;
  LocationSharing _sharing = LocationSharing.off;
  bool _summaryConsent = false;
  bool _resolutionConsent = false;
  bool _busy = false;
  bool _reviewing = false;
  String? _plan;
  String? _error;
  List<String> _questions = const [];
  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.contacts.map((c) => c.id).whereType<int>());
  }

  @override
  void didUpdateWidget(covariant CompanionJourneyForm old) {
    super.didUpdateWidget(old);
    _selected.removeWhere((id) => !widget.contacts.any((c) => c.id == id));
  }

  @override
  void dispose() {
    _input.dispose();
    _description.dispose();
    super.dispose();
  }

  DateTime get _deadline =>
      _absolute ?? widget.serverNow().add(Duration(minutes: _minutes));
  void _working(bool value) {
    setState(() => _busy = value);
    widget.onBusyChanged(value);
  }

  void _changed() {
    setState(() => _plan = null);
  }

  Future<void> _chooseTime() async {
    if (_busy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final now = widget.serverNow().toUtc();
    final initial = _deadline.toUtc().add(const Duration(hours: 2));
    final first = now.add(const Duration(hours: 2));
    _working(true);
    try {
      final date = await showDatePicker(
        context: context,
        helpText: 'Check-in date (SAST)',
        initialDate: initial.isBefore(first) ? first : initial,
        firstDate: first,
        lastDate: first.add(const Duration(hours: 24)),
      );
      if (!mounted || date == null) return;
      final time = await showTimePicker(
        context: context,
        helpText: 'Check-in time (SAST)',
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (!mounted || time == null) return;
      setState(() {
        _absolute = DateTime.utc(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ).subtract(const Duration(hours: 2));
        _plan = null;
        _error = null;
      });
      _validate();
    } finally {
      if (mounted) _working(false);
    }
  }

  Future<void> _interpret() async {
    if (_busy) return;
    final text = _input.text.trim();
    if (text.isEmpty || text.length > 1500 || _history.length > 6) {
      setState(() => _error = 'Enter a short plan, or start a new draft.');
      return;
    }
    _working(true);
    setState(() {
      _error = null;
      _plan = null;
    });
    try {
      final raw = await widget
          .propose(text, List.of(_history))
          .timeout(const Duration(seconds: 40));
      final draft = TripDraft.decode(raw);
      if (!mounted) return;
      setState(() {
        _history.addAll([text, raw]);
        _questions = draft.questions;
        if (draft.tripType != null) _type = draft.tripType!;
        if (draft.description != null) _description.text = draft.description!;
        _absolute = draft.checkInAtUtc;
        _input.clear();
      });
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is TimeoutException
              ? 'AI took too long. You can enter the journey details below.'
              : friendlyError(e),
        );
      }
    } finally {
      if (mounted) _working(false);
    }
  }

  bool _validate() {
    if (_description.text.trim().isEmpty) {
      setState(() => _error = 'Enter a destination or route.');
      return false;
    }
    final remaining = _deadline.difference(widget.serverNow());
    if (remaining < const Duration(minutes: 1) ||
        remaining > const Duration(hours: 24)) {
      setState(
        () => _error =
            'Choose a new check-in time between one minute and 24 hours from now.',
      );
      return false;
    }
    return true;
  }

  Future<void> _generatePlan() async {
    if (_busy || !_validate()) return;
    _absolute ??= _deadline;
    _working(true);
    setState(() => _error = null);
    try {
      final plan = await widget
          .preparePlan(_type, _description.text.trim(), _deadline, _grace)
          .timeout(const Duration(seconds: 35));
      if (mounted) setState(() => _plan = plan);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) _working(false);
    }
  }

  Future<void> _review() async {
    if (_busy || !_validate()) return;
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one trusted contact.');
      return;
    }
    if (_input.text.trim().isNotEmpty) {
      setState(
        () => _error =
            'Interpret your typed changes first, or clear the AI input to use the details below.',
      );
      return;
    }
    _absolute ??= _deadline;
    final deadline = _deadline;
    final request = JourneyRequest(
      tripType: _type,
      description: _description.text.trim(),
      checkInAtUtc: deadline,
      contactIds: _selected.toList(),
      graceMinutes: _grace,
      locationSharing: _sharing,
      safetyPlanJson: _plan,
      useAiIncidentSummary: _summaryConsent,
      allowContactResolution: _resolutionConsent,
    );
    _working(true);
    setState(() => _error = null);
    try {
      final fresh = await widget.loadContacts().timeout(
        const Duration(seconds: 20),
      );
      if (!mounted) return;
      if (!request.contactIds.every((id) => fresh.any((c) => c.id == id))) {
        setState(
          () => _error =
              'Your contacts changed. Refresh the Trip tab and choose again.',
        );
        return;
      }
      final contacts = fresh
          .where((c) => request.contactIds.contains(c.id))
          .toList();
      setState(() => _reviewing = true);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => TripReviewDialog(
          tripType: request.tripType,
          description: request.description,
          durationMinutes: _minutes,
          estimatedDeadline: deadline,
          exactDeadline: true,
          contacts: contacts,
          locationSharing: request.locationSharing,
          reminderMode: CheckInReminderMode.silent,
          graceMinutes: request.graceMinutes,
          safetyPlanJson: request.safetyPlanJson,
          useAiIncidentSummary: request.useAiIncidentSummary,
          allowContactResolution: request.allowContactResolution,
        ),
      );
      if (!mounted || confirmed != true) return;
      if (deadline.difference(widget.serverNow()) <
          const Duration(minutes: 1)) {
        setState(
          () => _error =
              'The draft expired during review. Choose a new check-in time.',
        );
        return;
      }
      setState(() => _reviewing = false);
      await widget.onStart(request);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) {
        setState(() => _reviewing = false);
        _working(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SafetySectionHeading(
          eyebrow: 'PLAN WITH INTENTION',
          title: 'Your safety companion',
          subtitle:
              'Plan your journey, choose who can help, and review before starting. SafeCheck monitors your confirmed check-in; AI does not predict danger.',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text('Describe with AI', style: text.titleLarge),
                    const SafetyTag(
                      label: 'Meta Model API',
                      icon: Icons.auto_awesome_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.aiAvailable == true
                      ? 'Meta planning is configured.'
                      : widget.availabilityMessage ??
                            (widget.aiAvailable == false
                                ? 'The server reports AI is not configured. You can retry or use manual details.'
                                : 'Checking AI availability…'),
                ),
                TextButton(
                  onPressed: _busy ? null : widget.onRetryAvailability,
                  child: const Text('Retry AI connection'),
                ),
                TextField(
                  key: const Key('journey-ai-input'),
                  controller: _input,
                  enabled: !_busy,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 1500,
                  decoration: const InputDecoration(
                    labelText: 'Describe a trip or answer a question',
                    hintText:
                        'Minibus taxi from Pretoria CBD to Mamelodi now. Check in in 45 minutes.',
                  ),
                ),
                for (final q in _questions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(q),
                  ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _interpret,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Interpret journey'),
                ),
                if (_history.isNotEmpty)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () {
                            setState(() {
                              _history.clear();
                              _questions = const [];
                              _input.clear();
                            });
                          },
                    child: const Text('New AI conversation'),
                  ),
                Text(
                  'Trip text is processed by Meta when you use AI. Contacts and GPS coordinates are not added to planning requests.',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Journey details', style: text.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'Make it yours. Review everything before you start.',
                  style: text.bodySmall,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TripType>(
                  key: ValueKey(_type),
                  isExpanded: true,
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Transport'),
                  items: [
                    for (final type in TripType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Text(tripTypeLabel(type)),
                      ),
                  ],
                  onChanged: _busy
                      ? null
                      : (v) {
                          if (v != null) {
                            setState(() {
                              _type = v;
                              _plan = null;
                            });
                          }
                        },
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('journey-description'),
                  controller: _description,
                  enabled: !_busy,
                  maxLength: 200,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Destination or route',
                  ),
                  onChanged: (_) => _changed(),
                ),
                Text('Check in within', style: text.titleMedium),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final m in [2, 15, 30, 45, 60, 120])
                      ChoiceChip(
                        label: Text(formatDurationShort(m)),
                        selected: _absolute == null && _minutes == m,
                        onSelected: _busy
                            ? null
                            : (_) {
                                setState(() {
                                  _minutes = m;
                                  _absolute = null;
                                  _plan = null;
                                });
                              },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Check-in: ${formatSastDateTime(context, _deadline)}'),
                TextButton.icon(
                  onPressed: _busy ? null : _chooseTime,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Choose exact SAST time'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _grace,
                  decoration: const InputDecoration(
                    labelText: 'Grace period after check-in',
                  ),
                  items: [
                    for (final m in [0, 1, 2, 5, 10])
                      DropdownMenuItem(
                        value: m,
                        child: Text(m == 0 ? 'No grace period' : '$m minutes'),
                      ),
                  ],
                  onChanged: _busy
                      ? null
                      : (v) {
                          if (v != null) {
                            setState(() {
                              _grace = v;
                              _plan = null;
                            });
                          }
                        },
                ),
                const SizedBox(height: 8),
                Text(
                  'If no check-in is recorded, alert time is ${formatSastDateTime(context, _deadline.add(Duration(minutes: _grace)))}. You may check in during grace.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Trusted contacts for this journey',
                  style: text.titleMedium,
                ),
                if (widget.contacts.isEmpty)
                  const Text('Add a trusted contact before starting.'),
                for (final contact in widget.contacts)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(contact.name),
                    subtitle: Text(contact.phoneNumber),
                    value: _selected.contains(contact.id),
                    onChanged: _busy
                        ? null
                        : (v) {
                            setState(() {
                              if (v == true && contact.id != null) {
                                _selected.add(contact.id!);
                              } else {
                                _selected.remove(contact.id);
                              }
                            });
                          },
                  ),
                TextButton(
                  onPressed: _busy ? null : widget.onOpenContacts,
                  child: const Text('Manage contacts'),
                ),
                DropdownButtonFormField<LocationSharing>(
                  isExpanded: true,
                  initialValue: _sharing,
                  decoration: const InputDecoration(
                    labelText: 'Location sharing',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: LocationSharing.off,
                      child: Text('Off (default)'),
                    ),
                    DropdownMenuItem(
                      value: LocationSharing.afterAlert,
                      child: Text('After an alert'),
                    ),
                    DropdownMenuItem(
                      value: LocationSharing.live,
                      child: Text('Live while the app runs'),
                    ),
                  ],
                  onChanged: _busy
                      ? null
                      : (v) {
                          if (v != null) setState(() => _sharing = v);
                        },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _summaryConsent,
                  title: const Text('Use Meta for an incident brief'),
                  subtitle: const Text(
                    'If an alert is raised, send the journey description, recorded times and location timestamp to Meta. Coordinates and contact details are excluded.',
                  ),
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _summaryConsent = v ?? false),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _resolutionConsent,
                  title: const Text(
                    'Allow accepted contacts to resolve incidents',
                  ),
                  subtitle: const Text(
                    'Their private incident link grants this permission to anyone holding it. It expires after 48 hours.',
                  ),
                  onChanged: _busy
                      ? null
                      : (v) => setState(() => _resolutionConsent = v ?? false),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _generatePlan,
                  icon: const Icon(Icons.shield_outlined),
                  label: const Text('Create AI safety plan'),
                ),
                SafetyPlanCard(planJson: _plan),
                const SizedBox(height: 8),
                const Text(
                  'Silent reminder while the app is open. The server processes deadlines even when the app is closed. Alerts and delivery statuses are separate.',
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: ErrorBanner(message: _error!),
                  ),
                if (_busy && !_reviewing)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy ? null : _review,
                  icon: const Icon(Icons.fact_check_outlined),
                  label: const Text('Review safety journey'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
