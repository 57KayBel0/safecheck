import 'package:flutter/material.dart';
import 'package:safecheck_client/safecheck_client.dart';
import '../location/trip_location_controller.dart';

class TripLocationStatus extends StatelessWidget {
  const TripLocationStatus({
    super.key,
    required this.controller,
    required this.sharing,
  });
  final TripLocationController controller;
  final LocationSharing sharing;

  @override
  Widget build(BuildContext context) {
    final message = switch (controller.state) {
      TrackingState.off => 'Location sharing is off.',
      TrackingState.checkingPermission => 'Checking location permission…',
      TrackingState.needsPermission =>
        'Enable location to record GPS points for this trip.',
      TrackingState.permissionGranted => 'Location permission granted.',
      TrackingState.acquiring => 'Acquiring position…',
      TrackingState.uploading => 'Uploading location…',
      TrackingState.uploaded =>
        'Location uploaded. Updates depend on this app staying active and connected.',
      TrackingState.denied =>
        'Location permission was not granted. Allow location for this site, then retry.',
      TrackingState.blocked =>
        'Location access is blocked or unavailable. Review site permission and device location settings, then retry.',
      TrackingState.servicesDisabled =>
        'Device location services are disabled. Turn on Location Services, then retry.',
      TrackingState.gpsTimeout =>
        'Tracking unavailable: GPS timed out. Check device location services and try somewhere with a better signal.',
      TrackingState.uploadFailed =>
        'Tracking unavailable: location upload was not confirmed. Check your connection and retry.',
      TrackingState.unavailable =>
        'Tracking unavailable: permission or position could not be obtained. Check site permissions and device location services, then retry.',
      TrackingState.paused =>
        'Continuing without location on this device. The trip’s sharing setting is unchanged.',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Trip location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              sharing == LocationSharing.afterAlert
                  ? 'GPS points are recorded now; contacts can see them only after a missed check-in.'
                  : 'GPS points can be visible to anyone with a contact tracking link during this trip.',
            ),
            if (controller.permissionGranted)
              const Text('Location permission granted.'),
            Semantics(liveRegion: true, child: Text(message)),
            if (!controller.busy &&
                controller.state != TrackingState.uploaded) ...[
              const Text(
                'Chrome/Edge: site controls beside the address → Site settings → Location → Allow. '
                'Firefox: address-bar permissions → clear the location block, then retry. '
                'Safari: Website Settings → Location → Allow (on Mac, Safari Settings → Websites → Location). '
                'Also allow the browser in your device’s Location Services settings. '
                'On native apps, allow location in the device’s app permissions.',
              ),
              TextButton(
                onPressed: controller.enable,
                child: Text(
                  controller.state == TrackingState.needsPermission
                      ? 'Enable location'
                      : 'Retry location',
                ),
              ),
              if (controller.state != TrackingState.paused)
                TextButton(
                  onPressed: controller.continueWithoutLocation,
                  child: const Text('Continue without location'),
                ),
            ],
            const Text(
              'Check-in remains available even when tracking is unavailable.',
            ),
          ],
        ),
      ),
    );
  }
}
