import 'dart:async';

enum LocationAccess { granted, denied, blocked, unknown }

enum TrackingState {
  off,
  checkingPermission,
  needsPermission,
  permissionGranted,
  acquiring,
  uploading,
  uploaded,
  denied,
  blocked,
  servicesDisabled,
  gpsTimeout,
  uploadFailed,
  unavailable,
  paused,
}

class LocationSample {
  const LocationSample(this.latitude, this.longitude, this.accuracy, this.time);
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime time;
}

abstract interface class TripLocationService {
  Future<bool> servicesEnabled();
  Future<LocationAccess> permission();
  Future<LocationAccess> requestPermission();
  Future<LocationSample> position();
}

/// Owns location work only; retry cannot create or modify a trip.
class TripLocationController {
  TripLocationController({
    required this.service,
    required this.upload,
    required this.onChanged,
    this.timeout = const Duration(seconds: 20),
  });

  final TripLocationService service;
  final Future<int> Function(int, LocationSample) upload;
  final void Function() onChanged;
  final Duration timeout;
  TrackingState state = TrackingState.off;
  bool permissionGranted = false;
  int? _tripId;
  int _generation = 0;
  bool _busy = false;
  bool _paused = false;
  bool _disposed = false;

  bool get busy => _busy;

  void attach(int? tripId, {required bool enabled}) {
    final id = enabled ? tripId : null;
    if (id == _tripId) return;
    _generation++;
    _tripId = id;
    _busy = false;
    _paused = false;
    permissionGranted = false;
    _set(id == null ? TrackingState.off : TrackingState.checkingPermission);
    if (id != null) unawaited(update());
  }

  void continueWithoutLocation() {
    _generation++;
    _busy = false;
    _paused = true;
    _set(TrackingState.paused);
  }

  Future<void> enable() => update(request: true);

  Future<void> update({bool request = false}) async {
    if (_disposed || _tripId == null || _busy || (_paused && !request)) return;
    if (!request &&
        state != TrackingState.checkingPermission &&
        state != TrackingState.uploaded) {
      return;
    }
    _paused = false;
    _busy = true;
    final generation = _generation;
    final id = _tripId!;
    bool current() => !_disposed && generation == _generation;
    var phase = TrackingState.checkingPermission;
    void transition(TrackingState value) {
      phase = value;
      if (current()) _set(value);
    }

    try {
      transition(TrackingState.checkingPermission);
      if (!await service.servicesEnabled().timeout(timeout)) {
        transition(TrackingState.servicesDisabled);
        return;
      }
      if (!current()) return;
      var access = await service.permission().timeout(timeout);
      if (!current()) return;
      if (access != LocationAccess.granted &&
          request &&
          access != LocationAccess.blocked) {
        access = await service.requestPermission().timeout(timeout);
        // Web requestPermission can conflate GPS errors with denial. Recheck
        // the browser's permission state before describing it as blocked.
        if (access != LocationAccess.granted) {
          access = await service.permission().timeout(timeout);
        }
      }
      if (!current()) return;
      permissionGranted = access == LocationAccess.granted;
      if (!permissionGranted) {
        transition(
          access == LocationAccess.blocked
              ? TrackingState.blocked
              : request
              ? TrackingState.denied
              : TrackingState.needsPermission,
        );
        return;
      }
      transition(TrackingState.permissionGranted);
      transition(TrackingState.acquiring);
      final sample = await service.position().timeout(timeout);
      if (!current()) return;
      transition(TrackingState.uploading);
      final stored = await upload(id, sample).timeout(timeout);
      if (!current()) return;
      transition(
        stored > 0 ? TrackingState.uploaded : TrackingState.uploadFailed,
      );
    } on TimeoutException {
      transition(
        phase == TrackingState.uploading
            ? TrackingState.uploadFailed
            : phase == TrackingState.acquiring
            ? TrackingState.gpsTimeout
            : TrackingState.unavailable,
      );
    } catch (_) {
      transition(
        phase == TrackingState.uploading
            ? TrackingState.uploadFailed
            : TrackingState.unavailable,
      );
    } finally {
      if (current()) {
        _busy = false;
        onChanged();
      }
    }
  }

  void _set(TrackingState value) {
    state = value;
    if (!_disposed) onChanged();
  }

  void dispose() {
    _disposed = true;
    _generation++;
  }
}
