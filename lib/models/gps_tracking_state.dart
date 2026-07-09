enum GpsTrackingState {
  off,
  ready,
  active,
  paused,
  unavailable,
}

extension GpsTrackingStateX on GpsTrackingState {
  String get label {
    switch (this) {
      case GpsTrackingState.off:
        return 'GPS off';
      case GpsTrackingState.ready:
        return 'Ready';
      case GpsTrackingState.active:
        return 'Tracking';
      case GpsTrackingState.paused:
        return 'Paused';
      case GpsTrackingState.unavailable:
        return 'Unavailable';
    }
  }
}
