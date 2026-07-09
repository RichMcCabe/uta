import '../models/journey_event.dart';
import '../models/journey_event_type.dart';
import '../models/route_checkpoint_status.dart';
import '../models/trip.dart';
import 'eta_calculator.dart';

class JourneyStats {
  const JourneyStats({
    required this.totalDistanceMiles,
    required this.plannedDrivingMinutes,
    required this.elapsedMinutes,
    required this.loggedCheckpointCount,
    required this.totalCheckpointCount,
    required this.manualEventCount,
    required this.stopEventCount,
    required this.statusLabel,
  });

  final double totalDistanceMiles;
  final int plannedDrivingMinutes;
  final int elapsedMinutes;
  final int loggedCheckpointCount;
  final int totalCheckpointCount;
  final int manualEventCount;
  final int stopEventCount;
  final String statusLabel;
}

class JourneyStatsService {
  const JourneyStatsService();

  JourneyStats buildStats({
    required Trip trip,
    required List<RouteCheckpointStatus> statuses,
    required List<JourneyEvent> manualEvents,
    required DateTime departureTime,
    required DateTime? completedTime,
  }) {
    final calculator = const EtaCalculator();
    final totalDistance = trip.route.fold<double>(
      0,
      (sum, segment) => sum + segment.distanceMiles,
    );
    final plannedMinutes = calculator.totalPlannedMinutes(trip);
    final endTime = completedTime ?? DateTime.now();
    final elapsedMinutes = endTime.difference(departureTime).inMinutes;
    final loggedCount = statuses.where((status) => status.isLogged).length;
    final stopEvents = manualEvents.where((event) {
      return event.type == JourneyEventType.fuel ||
          event.type == JourneyEventType.meal ||
          event.type == JourneyEventType.bathroom ||
          event.type == JourneyEventType.stop ||
          event.type == JourneyEventType.driverSwap;
    }).length;

    return JourneyStats(
      totalDistanceMiles: totalDistance,
      plannedDrivingMinutes: plannedMinutes,
      elapsedMinutes: elapsedMinutes < 0 ? 0 : elapsedMinutes,
      loggedCheckpointCount: loggedCount,
      totalCheckpointCount: trip.route.length,
      manualEventCount: manualEvents.length,
      stopEventCount: stopEvents,
      statusLabel: completedTime == null ? 'In progress' : 'Completed',
    );
  }
}
