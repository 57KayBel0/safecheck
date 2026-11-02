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
import '../widgets/start_trip_form.dart';
import '../widgets/trip_completion_notice.dart';

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
    if (!_serverNow.isBefore(trip.deadline)) {
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

  Future<void> _startTrip(
    TripType type,
    String description,
    int minutes,
    CheckInReminderMode reminderMode,
    LocationSharing sharing,
  ) async {
    final snapshot = await client.trip.startTrip(
      type,
      description,
      minutes,
      sharing,
    );
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
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_endedTrip != null && _trip == null) ...[
                    TripCompletionNotice(
                      status: _endedTrip!.status,
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
                    )
                  else
                    StartTripForm(
                      contacts: _contacts,
                      loadContacts: () => client.contact.list(),
                      serverNow: () => _serverNow,
                      onOpenContacts: widget.onOpenContacts,
                      onStart: _startTrip,
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
  });

  final Trip trip;
  final DateTime serverNow;
  final bool checkingIn;
  final bool reminder;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final remaining = trip.deadline.difference(serverNow);
    final overdue = remaining <= Duration.zero;
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
                Row(
                  children: [
                    _StatusPill(
                      label: overdue ? 'Deadline passed' : 'Trip active',
                      color: overdue ? colors.error : colors.primary,
                    ),
                    const Spacer(),
                    Icon(tripTypeIcon(trip.tripType), color: colors.primary),
                    const SizedBox(width: 6),
                    Text(tripTypeLabel(trip.tripType), style: text.labelLarge),
                  ],
                ),
                const SizedBox(height: 12),
                Text(trip.description, style: text.titleMedium),
                const SizedBox(height: 24),
                Semantics(
                  label: overdue
                      ? 'Deadline passed'
                      : describeCountdown(remaining),
                  excludeSemantics: true,
                  child: Column(
                    children: [
                      Text(
                        overdue ? '00:00' : formatCountdown(remaining),
                        style: text.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: overdue || urgent
                              ? colors.error
                              : colors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        overdue ? 'time is up' : 'left to check in',
                        style: text.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: overdue || urgent ? colors.error : colors.primary,
                    semanticsLabel: 'Trip progress',
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

        if (trip.locationSharing != LocationSharing.off) ...[
          _LiveTripMap(trip: trip),
          const SizedBox(height: 16),
        ],

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
