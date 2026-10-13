import 'package:geolocator/geolocator.dart';
import 'trip_location_controller.dart';

class GeolocatorTripService implements TripLocationService {
  @override
  Future<bool> servicesEnabled() => Geolocator.isLocationServiceEnabled();

  LocationAccess _access(LocationPermission value) => switch (value) {
    LocationPermission.always ||
    LocationPermission.whileInUse => LocationAccess.granted,
    LocationPermission.deniedForever => LocationAccess.blocked,
    LocationPermission.denied => LocationAccess.denied,
    _ => LocationAccess.unknown,
  };

  @override
  Future<LocationAccess> permission() async {
    try {
      return _access(await Geolocator.checkPermission());
    } on UnsupportedError {
      return LocationAccess.unknown;
    }
  }

  @override
  Future<LocationAccess> requestPermission() async =>
      _access(await Geolocator.requestPermission());

  @override
  Future<LocationSample> position() async {
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return LocationSample(
      p.latitude,
      p.longitude,
      p.accuracy,
      p.timestamp.toUtc(),
    );
  }
}
