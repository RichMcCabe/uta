import 'speed_source.dart';

class RouteSegment {
  const RouteSegment({
    required this.id,
    required this.instruction,
    required this.distanceMiles,
    required this.speedLimitMph,
    required this.assignedDriverName,
    this.speedSource = SpeedSource.estimated,
    this.isStop = false,
    this.plannedStopMinutes = 0,
    this.note,
    this.checkpointLatitude,
    this.checkpointLongitude,
  });

  final String id;
  final String instruction;
  final double distanceMiles;
  final int speedLimitMph;
  final String assignedDriverName;
  final SpeedSource speedSource;
  final bool isStop;
  final int plannedStopMinutes;
  final String? note;
  final double? checkpointLatitude;
  final double? checkpointLongitude;

  bool get hasCheckpointLocation =>
      checkpointLatitude != null && checkpointLongitude != null;

  RouteSegment copyWith({
    String? id,
    String? instruction,
    double? distanceMiles,
    int? speedLimitMph,
    String? assignedDriverName,
    SpeedSource? speedSource,
    bool? isStop,
    int? plannedStopMinutes,
    String? note,
    double? checkpointLatitude,
    double? checkpointLongitude,
  }) {
    return RouteSegment(
      id: id ?? this.id,
      instruction: instruction ?? this.instruction,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      speedLimitMph: speedLimitMph ?? this.speedLimitMph,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      speedSource: speedSource ?? this.speedSource,
      isStop: isStop ?? this.isStop,
      plannedStopMinutes: plannedStopMinutes ?? this.plannedStopMinutes,
      note: note ?? this.note,
      checkpointLatitude: checkpointLatitude ?? this.checkpointLatitude,
      checkpointLongitude: checkpointLongitude ?? this.checkpointLongitude,
    );
  }
}
