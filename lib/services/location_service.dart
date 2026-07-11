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
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 10,
  );

  LocationServiceSnapshot initialSnapshot() {
    return const LocationServiceSnapshot(
      permissionStatus: LocationPermissionStatus.notRequested,
      trackingState: GpsTrackingState.off,
      lastLocation: null,
      message: 'UTA is ready to request location access.',
    );
  }

  Future<LocationServiceSnapshot> requestCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationServiceSnapshot(
          permissionStatus: LocationPermissionStatus.disabled,
          trackingState: GpsTrackingState.unavailable,
          lastLocation: null,
          message:
              'Location Services are off. Turn them on in Settings to use live travel mode.',
        );
      }

      final permissionStatus = await _requestPermissionStatus();
      if (!permissionStatus.canTrack) {
        return LocationServiceSnapshot(
          permissionStatus: permissionStatus,
          trackingState: GpsTrackingState.unavailable,
          lastLocation: null,
          message:
              'Location access was not granted. Open Settings to allow UTA location access.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationServiceSnapshot(
        permissionStatus: permissionStatus,
        trackingState: GpsTrackingState.ready,
        lastLocation: _trackedLocationFromPosition(position),
        message: 'Location ready. Start tracking for live speed, route progress and ETA.',
      );
    } on TimeoutException {
      return const LocationServiceSnapshot(
        permissionStatus: LocationPermissionStatus.unknown,
        trackingState: GpsTrackingState.unavailable,
        lastLocation: null,
        message: 'UTA could not obtain a GPS fix. Move outdoors and try again.',
      );
    } catch (error) {
      return LocationServiceSnapshot(
        permissionStatus: LocationPermissionStatus.unknown,
        trackingState: GpsTrackingState.unavailable,
        lastLocation: null,
        message: 'Location error: $error',
      );
    }
  }

  Stream<LocationServiceSnapshot> trackingSnapshots() async* {
    final readySnapshot = await requestCurrentLocation();
    yield readySnapshot;
    if (!readySnapshot.permissionStatus.canTrack) return;

    yield LocationServiceSnapshot(
      permissionStatus: readySnapshot.permissionStatus,
      trackingState: GpsTrackingState.active,
      lastLocation: readySnapshot.lastLocation,
      message: 'Live GPS tracking is active.',
    );

    await for (final position in Geolocator.getPositionStream(
      locationSettings: _trackingSettings,
    )) {
      yield LocationServiceSnapshot(
        permissionStatus: readySnapshot.permissionStatus,
        trackingState: GpsTrackingState.active,
        lastLocation: _trackedLocationFromPosition(position),
        message: 'Live GPS update received.',
      );
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<LocationPermissionStatus> _requestPermissionStatus() async {
    final currentPermission = await Geolocator.checkPermission();
    if (_isUsablePermission(currentPermission)) {
      return _mapPermission(currentPermission);
    }

    if (currentPermission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.denied;
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
      headingDegrees: position.heading.isFinite && position.heading >= 0
          ? position.heading
          : null,
    );
  }
}
