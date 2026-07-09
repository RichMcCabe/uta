enum TrackingMode {
  manual,
  assisted,
  automatic,
}

extension TrackingModeX on TrackingMode {
  String get label {
    switch (this) {
      case TrackingMode.manual:
        return 'Manual';
      case TrackingMode.assisted:
        return 'Assisted';
      case TrackingMode.automatic:
        return 'Automatic';
    }
  }

  String get description {
    switch (this) {
      case TrackingMode.manual:
        return 'Tap checkpoints yourself. Lowest battery use.';
      case TrackingMode.assisted:
        return 'UTA can suggest checkpoint logs using GPS proximity.';
      case TrackingMode.automatic:
        return 'Log checkpoints automatically during an active trip when GPS is live.';
    }
  }
}

class EventDetector {
  const EventDetector();

  bool shouldAutoLogCheckpoint({
    required TrackingMode mode,
    required double distanceMiles,
  }) {
    if (mode == TrackingMode.manual) return false;
    return distanceMiles <= 0.25;
  }
}
