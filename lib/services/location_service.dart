import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/gps_tracking_state.dart';
import '../models/location_permission_status.dart';
import '../models/tracked_location.dart';

class LocationServiceSnapshot {
  const LocationServiceSnapshot({
    required this.permissionStatus,
    required this.trackingState,
    required this.lastLocation,
    required this.message,
  });

  final LocationPermissionStatus permissionStatus;
  final GpsTrackingState trackingState;
  final TrackedLocation? lastLocation;
  final String message;
}

class LocationService {
  const LocationService();

  static const LocationSettings _trackingSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 25,
  );

  LocationServiceSnapshot initialSnapshot() {
    return const LocationServiceSnapshot(
      permissionStatus: LocationPermissionStatus.notRequested,
      trackingState: GpsTrackingState.off,
      lastLocation: null,
      message: 'GPS is ready to request device permission when you start tracking.',
    );
  }

  Future<LocationServiceSnapshot> requestCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationServiceSnapshot(
        permissionStatus: LocationPermissionStatus.disabled,
        trackingState: GpsTrackingState.unavailable,
        lastLocation: null,
        message: 'Location services are turned off on this device.',
      );
    }

    final permissionStatus = await _requestPermissionStatus();
    if (!permissionStatus.canTrack) {
      return LocationServiceSnapshot(
        permissionStatus: permissionStatus,
        trackingState: GpsTrackingState.unavailable,
        lastLocation: null,
        message: 'Location permission was not granted. UTA can still use manual checkpoints.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: Duration(seconds: 12),
      ),
    );

    return LocationServiceSnapshot(
      permissionStatus: permissionStatus,
      trackingState: GpsTrackingState.ready,
      lastLocation: _trackedLocationFromPosition(position),
      message: 'Current location captured. Start live tracking when the active leg begins.',
    );
  }

  Stream<LocationServiceSnapshot> trackingSnapshots() async* {
    final readySnapshot = await requestCurrentLocation();
    if (!readySnapshot.permissionStatus.canTrack) {
      yield readySnapshot;
      return;
    }

    yield LocationServiceSnapshot(
      permissionStatus: readySnapshot.permissionStatus,
      trackingState: GpsTrackingState.active,
      lastLocation: readySnapshot.lastLocation,
      message: 'Live GPS tracking is active for the current leg.',
    );

    await for (final position in Geolocator.getPositionStream(
      locationSettings: _trackingSettings,
    )) {
      yield LocationServiceSnapshot(
        permissionStatus: readySnapshot.permissionStatus,
        trackingState: GpsTrackingState.active,
        lastLocation: _trackedLocationFromPosition(position),
        message: 'Live GPS update received. UTA will auto-log nearby checkpoints.',
      );
    }
  }

  Future<LocationPermissionStatus> _requestPermissionStatus() async {
    final currentPermission = await Geolocator.checkPermission();
    if (_isUsablePermission(currentPermission)) {
      return _mapPermission(currentPermission);
    }

    final requestedPermission = await Geolocator.requestPermission();
    return _mapPermission(requestedPermission);
  }

  bool _isUsablePermission(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  LocationPermissionStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
        return LocationPermissionStatus.always;
      case LocationPermission.whileInUse:
        return LocationPermissionStatus.whileInUse;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.denied;
      case LocationPermission.unableToDetermine:
        return LocationPermissionStatus.unknown;
    }
  }

  TrackedLocation _trackedLocationFromPosition(Position position) {
    final speedMetersPerSecond = position.speed;
    final speedMph = speedMetersPerSecond.isFinite && speedMetersPerSecond >= 0
        ? speedMetersPerSecond * 2.2369362921
        : null;

    return TrackedLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      capturedAt: position.timestamp,
      accuracyMeters: position.accuracy,
      speedMph: speedMph,
      headingDegrees: position.heading.isFinite ? position.heading : null,
    );
  }
}
