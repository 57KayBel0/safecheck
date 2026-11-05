import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../location/geolocator_trip_service.dart';
import '../location/trip_location_controller.dart';
import '../widgets/trip_location_status.dart';
import 'package:latlong2/latlong.dart';
import 'package:safecheck_client/safecheck_client.dart';

import '../app_events.dart';
import '../client.dart';
import '../reminders/check_in_reminder.dart';
import '../reminders/reminder_feedback.dart';
import '../util/errors.dart';
import '../util/format.dart';
import '../widgets/state_views.dart';
import '../widgets/companion_journey_form.dart';
import '../widgets/safety_plan_card.dart';
import '../widgets/trip_completion_notice.dart';
import '../widgets/safety_design.dart';
import '../widgets/journey_overview.dart';

/// Home tab: start a trip, or follow the active trip and check in.
class TripScreen extends StatefulWidget {
  const TripScreen({
    super.key,
    required this.onOpenContacts,
    required this.onOpenAlerts,
  });

  final VoidCallback onOpenContacts;
  final VoidCallback onOpenAlerts;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> with WidgetsBindingObserver {
  bool _loading = true;
  Object? _loadError;

  /// The active trip as last confirmed by the server.
  Trip? _trip;

  /// The most recent trip that ended while this screen was open.
  Trip? _endedTrip;

  /// Server clock minus device clock, so the countdown follows the server.
  Duration _clockOffset = Duration.zero;
  List<TrustedContact> _contacts = const [];
  bool? _aiAvailable;
  bool _checkingAi = false;
  String? _aiAvailabilityMessage;

  bool _checkingIn = false;
  CheckInReminderMode _reminderMode = CheckInReminderMode.silent;
  final CheckInReminderGate _reminderGate = CheckInReminderGate();
  Timer? _ticker;
  Timer? _locationTimer;
  late final TripLocationController _location;
  DateTime? _lastDeadlineRefresh;

  @override
  void initState() {
    super.initState();
    _location = TripLocationController(
      service: GeolocatorTripService(),
      upload: (id, sample) => client.location.recordLocations(id, [
        LocationPoint(
          latitude: sample.latitude,
          longitude: sample.longitude,
          accuracyMeters: sample.accuracy,
          recordedAt: sample.time,
        ),
      ]),
      onChanged: () {
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addObserver(this);
    dataRevision.addListener(_onDataChanged);
    _load();
    unawaited(_checkAiAvailability());
  }

  Future<void> _checkAiAvailability() async {
    if (_checkingAi) return;
    _checkingAi = true;
    if (mounted) {
      setState(() {
        _aiAvailable = null;
        _aiAvailabilityMessage = null;
      });
    }
    try {
      final available = await client.planning.isAvailable().timeout(
        const Duration(seconds: 20),
      );
      if (mounted) {
        setState(() {
          _aiAvailable = available;
          _aiAvailabilityMessage = available
              ? null
              : 'The server reports no usable Meta key. AI actions remain visible so you can retry; manual setup works.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiAvailable = null;
          _aiAvailabilityMessage = e is TimeoutException
              ? 'The AI availability check timed out. Retry the connection, or enter journey details manually.'
              : friendlyError(e);
        });
      }
    } finally {
      _checkingAi = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    dataRevision.removeListener(_onDataChanged);
    _ticker?.cancel();
    _locationTimer?.cancel();
    _location.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load(silent: true);
  }

  void _onDataChanged() => _load(silent: true);

  DateTime get _serverNow => DateTime.now().toUtc().add(_clockOffset);

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final results = await Future.wait([
        client.trip.getActiveTrip(),
        client.contact.list(),
      ]);
      final snapshot = results[0] as TripSnapshot;
      final contacts = results[1] as List<TrustedContact>;

      // If the trip we were showing has gone, find out how it ended.
      Trip? ended;
      final previous = _trip;
      if (previous != null && snapshot.trip?.id != previous.id) {
        final history = await client.trip.history();
        ended = history.where((t) => t.id == previous.id).firstOrNull;
      }

      if (!mounted) return;
      setState(() {
        _clockOffset = snapshot.serverTime.difference(DateTime.now().toUtc());
        _trip = snapshot.trip;
        if (snapshot.trip == null && previous?.id != null) {
          _reminderGate.cancel(previous!.id!);
        }
        _contacts = contacts;
        if (ended != null) _endedTrip = ended;
        _loading = false;
        _loadError = null;
      });
      _syncTicker();
      _evaluateReminder();
      if (_trip != null) {
        _startLocationTracking();
      } else {
        _stopLocationTracking();
      }
    } catch (e) {
      if (!mounted) return;
      if (silent && !_loading) return; // Keep showing the last known state.
      setState(() {
        _loadError = e;
        _loading = false;
      });
    }
  }

  void _syncTicker() {
    if (_trip == null) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final trip = _trip;
    if (trip == null || !mounted) return;
    _evaluateReminder();
    setState(() {});
    // Once the deadline passes, ask the server what happened. Retry every
    // 10 seconds until the server reports the trip as ended.
    if (!_serverNow.isBefore(trip.alertAt ?? trip.deadline)) {
      final last = _lastDeadlineRefresh;
      if (last == null ||
          DateTime.now().difference(last) > const Duration(seconds: 10)) {
        _lastDeadlineRefresh = DateTime.now();
        _load(silent: true).then((_) => notifyIfEnded());
      }
    }
  }

  void _evaluateReminder() {
    final trip = _trip;
    final tripId = trip?.id;
    if (trip == null || tripId == null) return;
    if (!_reminderGate.claim(
      tripId: tripId,
      deadline: trip.deadline,
      serverNow: _serverNow,
    )) {
      return;
    }
    setState(() {});
    unawaited(playReminderFeedback(_reminderMode));
  }

  void notifyIfEnded() {
    if (_trip == null) notifyDataChanged();
  }

  Future<void> _startJourney(JourneyRequest request) => _startConfirmedTrip(
    () => client.trip.startJourney(request),
    CheckInReminderMode.silent,
  );

  Future<void> _extendJourney() async {
    final trip = _trip;
    if (trip == null) return;
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Extend your journey'),
        children: [
          for (final m in [5, 15, 30, 60])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, m),
              child: Text('Add $m minutes'),
            ),
        ],
      ),
    );
    if (minutes == null || !mounted) return;
    setState(() => _checkingIn = true);
    try {
      final result = await client.trip.extendJourney(trip.id!, minutes);
      if (!mounted) return;
      setState(() {
        _trip = result.trip;
        _clockOffset = result.serverTime.difference(DateTime.now().toUtc());
        _reminderGate.cancel(trip.id!);
      });
      _syncTicker();
      notifyDataChanged();
      showSnack(context, 'Journey extended. Check the updated deadline.');
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
      await _load(silent: true);
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  Future<void> _requestHelp() async {
    final trip = _trip;
    if (trip == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request help from your contacts?'),
        content: const Text(
          'This creates an incident now and queues messages using the configured delivery mode. It does not contact emergency services. Simulated messages are not sent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create help request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _checkingIn = true);
    try {
      final result = await client.trip.requestHelp(trip.id!);
      if (!mounted) return;
      setState(() {
        _trip = null;
        _endedTrip = result.endedTrip;
        _checkingIn = false;
        _reminderGate.cancel(trip.id!);
      });
      _syncTicker();
      _stopLocationTracking();
      notifyDataChanged();
      widget.onOpenAlerts();
    } catch (e) {
      if (mounted) {
        setState(() => _checkingIn = false);
        showSnack(context, friendlyError(e), error: true);
      }
      await _load(silent: true);
    }
  }

  Future<void> _startConfirmedTrip(
    Future<TripSnapshot> Function() start,
    CheckInReminderMode reminderMode,
  ) async {
    final TripSnapshot snapshot;
    try {
      snapshot = await start();
    } catch (_) {
      // A connection loss may happen after the server commits a start. Refresh
      // before offering another start; never automatically retry the mutation.
      await _load(silent: true);
      rethrow;
    }
    if (!mounted) return;
    setState(() {
      _clockOffset = snapshot.serverTime.difference(DateTime.now().toUtc());
      _trip = snapshot.trip;
      _reminderMode = reminderMode;
      _endedTrip = null;
      _lastDeadlineRefresh = null;
    });
    _syncTicker();
    _evaluateReminder();
    _startLocationTracking();
    notifyDataChanged();
    final deadline = snapshot.trip!.deadline;
    showSnack(
      context,
      'Trip started. Check in by ${formatTime(context, deadline)}.',
    );
  }

  Future<void> _checkIn() async {
    final trip = _trip;
    if (trip == null) return;
    setState(() => _checkingIn = true);
    try {
      final snapshot = await client.trip.checkIn(trip.id!);
      if (!mounted) return;
      setState(() {
        _trip = null;
        _reminderGate.cancel(trip.id!);
        _endedTrip = snapshot.endedTrip;
        _checkingIn = false;
      });
      _syncTicker();
      _startLocationTracking();
      notifyDataChanged();
      showSnack(context, "Checked in. Glad you're safe.");
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkingIn = false);
      showSnack(context, friendlyError(e), error: true);
      await _load(silent: true);
      notifyDataChanged();
    }
  }

  void _startLocationTracking() {
    final trip = _trip;
    _location.attach(
      trip?.id,
      enabled: trip != null && trip.locationSharing != LocationSharing.off,
    );
    if (trip == null || trip.locationSharing == LocationSharing.off) {
      _stopLocationTracking();
      return;
    }
    _locationTimer ??= Timer.periodic(
      const Duration(seconds: 30),
      (_) => _location.update(),
    );
  }

  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _location.attach(null, enabled: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingView(label: 'Checking for an active trip…');
    }
    if (_loadError != null) {
      return ErrorView(message: friendlyError(_loadError!), onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_trip == null || MediaQuery.sizeOf(context).width >= 1000)
                    JourneyOverview(
                      trip: _trip,
                      contacts: _contacts,
                      onOpenContacts: widget.onOpenContacts,
                    ),
                  if (_endedTrip != null && _trip == null) ...[
                    TripCompletionNotice(
                      status: _endedTrip!.status,
                      helpRequested: _endedTrip!.helpRequestedAt != null,
                      onOpenAlerts: widget.onOpenAlerts,
                      onDismiss: () => setState(() => _endedTrip = null),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_trip != null &&
                      _trip!.locationSharing != LocationSharing.off)
                    TripLocationStatus(
                      controller: _location,
                      sharing: _trip!.locationSharing,
                    ),
                  if (_trip != null)
                    _ActiveTripView(
                      trip: _trip!,
                      serverNow: _serverNow,
                      checkingIn: _checkingIn,
                      reminder:
                          _reminderGate.isVisibleFor(_trip!.id!) &&
                          _serverNow.isBefore(_trip!.deadline),
                      onCheckIn: _checkIn,
                      onExtend: _extendJourney,
                      onRequestHelp: _requestHelp,
                    )
                  else
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: CompanionJourneyForm(
                          contacts: _contacts,
                          loadContacts: () => client.contact.list(),
                          serverNow: () => _serverNow,
                          propose: (text, history) =>
                              client.planning.propose(text, history),
                          preparePlan: (type, description, deadline, grace) =>
                              client.planning.prepareSafetyPlan(
                                type,
                                description,
                                deadline,
                                grace,
                              ),
                          onStart: _startJourney,
                          onOpenContacts: widget.onOpenContacts,
                          onBusyChanged: (_) {},
                          aiAvailable: _aiAvailable,
                          availabilityMessage: _aiAvailabilityMessage,
                          onRetryAvailability: () =>
                              unawaited(_checkAiAvailability()),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripView extends StatelessWidget {
  const _ActiveTripView({
    required this.trip,
    required this.serverNow,
    required this.checkingIn,
    required this.reminder,
    required this.onCheckIn,
    required this.onExtend,
    required this.onRequestHelp,
  });

  final Trip trip;
  final DateTime serverNow;
  final bool checkingIn;
  final bool reminder;
  final VoidCallback onCheckIn;
  final VoidCallback onExtend;
  final VoidCallback onRequestHelp;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final nominalRemaining = trip.deadline.difference(serverNow);
    final remaining = (trip.alertAt ?? trip.deadline).difference(serverNow);
    final overdue = remaining <= Duration.zero;
    final inGrace = !overdue && nominalRemaining <= Duration.zero;
    final total = trip.deadline.difference(trip.startedAt).inSeconds;
    final progress = total <= 0
        ? 1.0
        : (1 - remaining.inSeconds / total).clamp(0.0, 1.0);
    final urgent = !overdue && remaining < const Duration(minutes: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusPill(
                      label: overdue
                          ? 'Alert time passed'
                          : inGrace
                          ? 'Grace period'
                          : 'Trip active',
                      color: overdue ? colors.error : colors.primary,
                    ),
                    SafetyTag(
                      label: tripTypeLabel(trip.tripType),
                      icon: tripTypeIcon(trip.tripType),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(trip.description, style: text.titleLarge),
                const SizedBox(height: 24),
                Semantics(
                  label: overdue
                      ? 'Deadline passed'
                      : describeCountdown(remaining),
                  excludeSemantics: true,
                  child: JourneyCountdown(
                    value: overdue ? '00:00' : formatCountdown(remaining),
                    progress: progress,
                    urgent: overdue || urgent,
                    caption: overdue
                        ? 'time is up'
                        : inGrace
                        ? 'grace left before an alert'
                        : 'left until alert time',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 20,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Check in by ${formatDateTime(context, trip.deadline)}'
                        ' (confirmed by server)',
                        style: text.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (reminder && !overdue) ...[
          Card(
            color: colors.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your check-in is due soon.',
                    style: text.titleMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: checkingIn ? null : onCheckIn,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("I'm safe"),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (overdue)
          Semantics(
            liveRegion: true,
            child: Card(
              color: colors.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colors.onErrorContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'The deadline has passed. Confirming with the '
                        'server…',
                        style: TextStyle(color: colors.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 72,
            child: FilledButton.icon(
              onPressed: checkingIn ? null : onCheckIn,
              style: FilledButton.styleFrom(
                textStyle: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: checkingIn
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : const Icon(Icons.check_circle, size: 28),
              label: Text(checkingIn ? 'Checking in…' : "I'm safe"),
            ),
          ),
        const SizedBox(height: 12),
        if (!overdue)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: checkingIn ? null : onExtend,
                icon: const Icon(Icons.more_time),
                label: const Text('Extend journey'),
              ),
              OutlinedButton.icon(
                onPressed: checkingIn ? null : onRequestHelp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                  backgroundColor: colors.errorContainer.withValues(alpha: 0.3),
                ),
                icon: const Icon(Icons.sos_rounded),
                label: const Text('Request help'),
              ),
            ],
          ),
        const SizedBox(height: 20),
        if (trip.locationSharing != LocationSharing.off) ...[
          _LiveTripMap(trip: trip),
          const SizedBox(height: 16),
        ] else ...[
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              leading: Icon(
                Icons.location_off_outlined,
                color: colors.onSurfaceVariant,
              ),
              title: const Text('Location sharing is off'),
              subtitle: const Text(
                'This journey does not collect or share your location.',
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (trip.graceMinutes > 0)
          Text(
            'Check-in deadline: ${formatSastDateTime(context, trip.deadline)}. Alert time after grace: ${formatSastDateTime(context, trip.alertAt ?? trip.deadline)}.',
          ),
        SafetyPlanCard(planJson: trip.safetyPlanJson, atStart: true),
        const SizedBox(height: 24),
        Text('Contacts for this trip', style: text.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Saved when the trip started. If you miss the deadline, an alert '
          'is created using their saved channel preferences. Check Alerts '
          'for each message’s status.',
          style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        for (final c in trip.contacts)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              child: Text(c.name.characters.first.toUpperCase()),
            ),
            title: Text(c.name),
            subtitle: Text(
              [c.relationship, c.phoneNumber].whereType<String>().join(' · '),
            ),
          ),
      ],
    );
  }
}

class _LiveTripMap extends StatefulWidget {
  const _LiveTripMap({required this.trip});

  final Trip trip;

  @override
  State<_LiveTripMap> createState() => _LiveTripMapState();
}

class _LiveTripMapState extends State<_LiveTripMap> {
  final MapController _mapController = MapController();

  List<TripLocation> _points = const [];
  Timer? _refreshTimer;

  bool _loading = true;
  bool _refreshing = false;
  Object? _error;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();

    _loadLocations();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadLocations(silent: true),
    );
  }

  @override
  void didUpdateWidget(covariant _LiveTripMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.trip.id != widget.trip.id) {
      _points = const [];
      _loading = true;
      _error = null;
      _loadLocations();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocations({bool silent = false}) async {
    final tripId = widget.trip.id;

    if (tripId == null || _refreshing) return;

    _refreshing = true;

    try {
      final locations = await client.location
          .getTripLocations(tripId)
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      setState(() {
        _points = locations;
        _loading = false;
        _error = null;
      });

      if (_mapReady && locations.isNotEmpty) {
        final latest = locations.last;

        _mapController.move(
          LatLng(latest.latitude, latest.longitude),
          _mapController.camera.zoom,
        );
      }
    } catch (e) {
      if (!mounted) return;

      if (!silent) {
        setState(() {
          _loading = false;
          _error = e;
        });
      }
    } finally {
      _refreshing = false;
    }
  }

  void _centreOnLatest() {
    if (_points.isEmpty) return;

    final latest = _points.last;

    _mapController.move(LatLng(latest.latitude, latest.longitude), 16);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recorded location route',
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusPill(
                  label: _points.isEmpty ? 'NO POINTS' : 'RECORDED',
                  color: colors.primary,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'This map shows points confirmed by the server. It does not guarantee ongoing tracking.',
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            if (_loading)
              const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SizedBox(
                height: 220,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        color: colors.error,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Could not load your live route.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _loadLocations,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_points.isEmpty)
              SizedBox(
                height: 220,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location, color: colors.primary, size: 38),
                      const SizedBox(height: 8),
                      const Text(
                        'Waiting for your first location…',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep location permission enabled.',
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildMap(context),

            if (_points.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildLocationDetails(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final route = _points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    final latest = _points.last;
    final latestPosition = LatLng(latest.latitude, latest.longitude);

    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: latestPosition,
                initialZoom: 16,
                onMapReady: () {
                  _mapReady = true;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.safecheck.app',
                ),
                if (route.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route,
                        strokeWidth: 5,
                        color: colors.primary,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latestPosition,
                      width: 56,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 4),
                          boxShadow: const [
                            BoxShadow(blurRadius: 8, color: Colors.black26),
                          ],
                        ),
                        child: Icon(
                          Icons.person_pin_circle,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Centre on my location',
                onPressed: _centreOnLatest,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetails(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final latest = _points.last;
    final accuracy = latest.accuracyMeters;

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.route_outlined, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_points.length} location point'
                '${_points.length == 1 ? '' : 's'} recorded',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.schedule, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Last updated ${formatTime(context, latest.recordedAt)}',
              ),
            ),
          ],
        ),
        if (accuracy != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.gps_fixed, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('GPS accuracy ±${accuracy.round()} m')),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.lock_outline, size: 20, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.trip.locationSharing == LocationSharing.live
                    ? 'Live location sharing is enabled for this trip.'
                    : 'Location will be shared after a missed check-in.',
                style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SafetyTag(label: label, color: color);
  }
}
