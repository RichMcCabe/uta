enum LocationPermissionStatus {
  unknown,
  notRequested,
  denied,
  whileInUse,
  always,
  disabled,
}

extension LocationPermissionStatusX on LocationPermissionStatus {
  String get label {
    switch (this) {
      case LocationPermissionStatus.unknown:
        return 'Unknown';
      case LocationPermissionStatus.notRequested:
        return 'Not requested';
      case LocationPermissionStatus.denied:
        return 'Denied';
      case LocationPermissionStatus.whileInUse:
        return 'While in use';
      case LocationPermissionStatus.always:
        return 'Always';
      case LocationPermissionStatus.disabled:
        return 'Location disabled';
    }
  }

  bool get canTrack =>
      this == LocationPermissionStatus.whileInUse ||
      this == LocationPermissionStatus.always;
}
