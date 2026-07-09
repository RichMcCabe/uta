import '../models/route_checkpoint_status.dart';
import '../models/trip.dart';
import 'eta_calculator.dart';

class TripProgressSnapshot {
  const TripProgressSnapshot({
    required this.loggedCount,
    required this.totalCount,
    required this.progress,
    required this.nextCheckpointLabel,
    required this.minutesAheadBehind,
    required this.statusLabel,
    required this.statusDetail,
    required this.projectedArrivalLabel,
  });

  final int loggedCount;
  final int totalCount;
  final double progress;
  final String nextCheckpointLabel;
  final int minutesAheadBehind;
  final String statusLabel;
  final String statusDetail;
  final String projectedArrivalLabel;
}

class TripProgressService {
  const TripProgressService();

  TripProgressSnapshot snapshot({
    required Trip trip,
    required List<RouteCheckpointStatus> statuses,
    required DateTime departureTime,
    required DateTime targetArrivalTime,
  }) {
    final calculator = const EtaCalculator();
    final logged = statuses.where((status) => status.isLogged).toList();
    final loggedIds = logged.map((status) => status.segmentId).toSet();

    final highestLoggedIndex = _highestLoggedRouteIndex(trip, loggedIds);
    final nextIndex = highestLoggedIndex + 1;
    final nextSegment = nextIndex >= 0 && nextIndex < trip.route.length
        ? trip.route[nextIndex]
        : null;

    final loggedCount = logged.length;
    final totalCount = trip.route.length;
    final progress = totalCount == 0
        ? 0.0
        : ((highestLoggedIndex + 1).clamp(0, totalCount) / totalCount);

    final plannedElapsedMinutes = highestLoggedIndex < 0
        ? 0
        : _plannedElapsedThroughIndex(trip, highestLoggedIndex, calculator);

    final latestStatus = highestLoggedIndex < 0
        ? null
        : statuses.firstWhere((status) => status.segmentId == trip.route[highestLoggedIndex].id);
    final actualElapsedMinutes = latestStatus?.actualTime == null
        ? 0
        : latestStatus!.actualTime!.difference(departureTime).inMinutes;

    final minutesAheadBehind = latestStatus?.actualTime == null
        ? 0
        : actualElapsedMinutes - plannedElapsedMinutes;

    final totalPlannedMinutes = calculator.totalPlannedMinutes(trip);
    final projectedArrival = departureTime.add(
      Duration(minutes: totalPlannedMinutes + minutesAheadBehind),
    );

    return TripProgressSnapshot(
      loggedCount: loggedCount,
      totalCount: totalCount,
      progress: progress,
      nextCheckpointLabel:
          nextSegment == null ? 'Trip complete' : nextSegment.instruction,
      minutesAheadBehind: minutesAheadBehind,
      statusLabel: statusLabel(minutesAheadBehind),
      statusDetail: statusDetail(minutesAheadBehind),
      projectedArrivalLabel: _formatTime(projectedArrival),
    );
  }

  String statusLabel(int minutesAheadBehind) {
    if (minutesAheadBehind <= -15) return 'Ahead of plan';
    if (minutesAheadBehind >= 15) return 'Behind plan';
    return 'On schedule';
  }

  String statusDetail(int minutesAheadBehind) {
    if (minutesAheadBehind == 0) return 'Tracking exactly to plan';
    if (minutesAheadBehind > 0) return '$minutesAheadBehind min behind';
    return '${minutesAheadBehind.abs()} min ahead';
  }

  String plannedCheckpointTimeLabel({
    required Trip trip,
    required int index,
    required DateTime departureTime,
  }) {
    final calculator = const EtaCalculator();
    final minutes = _plannedElapsedThroughIndex(trip, index, calculator);
    return _formatTime(departureTime.add(Duration(minutes: minutes)));
  }

  int? checkpointDifferenceMinutes({
    required Trip trip,
    required int index,
    required DateTime departureTime,
    required DateTime? actualTime,
  }) {
    if (actualTime == null) return null;
    final calculator = const EtaCalculator();
    final minutes = _plannedElapsedThroughIndex(trip, index, calculator);
    final planned = departureTime.add(Duration(minutes: minutes));
    return actualTime.difference(planned).inMinutes;
  }

  String formatDifference(int? minutes) {
    if (minutes == null) return 'Not logged';
    if (minutes == 0) return 'On time';
    if (minutes > 0) return '+$minutes min';
    return '${minutes.abs()} min early';
  }

  String formatActualTime(DateTime? time) {
    if (time == null) return 'Tap to log';
    return _formatTime(time);
  }

  int _highestLoggedRouteIndex(Trip trip, Set<String> loggedIds) {
    var highest = -1;
    for (var i = 0; i < trip.route.length; i++) {
      if (loggedIds.contains(trip.route[i].id)) highest = i;
    }
    return highest;
  }

  int _plannedElapsedThroughIndex(
    Trip trip,
    int index,
    EtaCalculator calculator,
  ) {
    var minutes = 0;
    for (var i = 0; i <= index; i++) {
      minutes += calculator.plannedMinutesForSegment(trip.route[i], trip);
    }
    return minutes;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
