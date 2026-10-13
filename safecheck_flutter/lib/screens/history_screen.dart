import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';

import '../app_events.dart';
import '../client.dart';
import '../util/errors.dart';
import '../util/format.dart';
import '../widgets/state_views.dart';

/// The user's recent trips and how each one ended.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Trip>? _trips;
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
      final trips = await client.trip.history();
      if (!mounted) return;
      setState(() {
        _trips = trips;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted || (silent && _trips != null)) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(label: 'Loading trip history…');
    if (_error != null) {
      return ErrorView(message: friendlyError(_error!), onRetry: _load);
    }
    final trips = _trips!;
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: trips.isEmpty
          ? const EmptyView(
              icon: Icons.route_outlined,
              title: 'No trips yet',
              message: 'Trips you start appear here with how they ended.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _TripTile(trip: trips[i]),
            ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (label, icon, color) = switch (trip.status) {
      TripStatus.active => ('Active', Icons.timelapse, colors.primary),
      TripStatus.checkedIn => ('Checked in', Icons.verified_user, Colors.green),
      TripStatus.missed => (
        'Missed – alert created',
        Icons.warning,
        colors.error,
      ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tripTypeIcon(trip.tripType), color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tripTypeLabel(trip.tripType),
                    style: text.titleSmall,
                  ),
                ),
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: text.labelLarge?.copyWith(color: color),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(trip.description, style: text.bodyLarge),
            const SizedBox(height: 8),
            Text(
              'Started ${formatDateTime(context, trip.startedAt)}\n'
              'Deadline ${formatDateTime(context, trip.deadline)} '
              '(${formatDurationShort(trip.durationMinutes)})'
              '${trip.endedAt != null && trip.status == TripStatus.checkedIn ? '\nChecked in ${formatDateTime(context, trip.endedAt!)}' : ''}',
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
