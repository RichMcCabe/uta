enum TripState {
  draft,
  ready,
  active,
  paused,
  arrived,
  completed,
}

extension TripStateX on TripState {
  String get label {
    switch (this) {
      case TripState.draft:
        return 'Draft';
      case TripState.ready:
        return 'Ready';
      case TripState.active:
        return 'Active trip';
      case TripState.paused:
        return 'Paused';
      case TripState.arrived:
        return 'Arrived';
      case TripState.completed:
        return 'Completed';
    }
  }
}
