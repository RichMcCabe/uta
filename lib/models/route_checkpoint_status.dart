import 'journey_event.dart';

class RouteCheckpointStatus {
  const RouteCheckpointStatus({
    required this.segmentId,
    this.actualTime,
    this.source = JourneyEventSource.actual,
  });

  final String segmentId;
  final DateTime? actualTime;
  final JourneyEventSource source;

  bool get isLogged => actualTime != null;

  RouteCheckpointStatus copyWith({
    DateTime? actualTime,
    JourneyEventSource? source,
    bool clearActualTime = false,
  }) {
    return RouteCheckpointStatus(
      segmentId: segmentId,
      actualTime: clearActualTime ? null : actualTime ?? this.actualTime,
      source: source ?? this.source,
    );
  }
}
