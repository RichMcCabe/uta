import '../models/journey_event.dart';
import '../models/journey_event_type.dart';
import '../models/route_checkpoint_status.dart';
import '../models/trip.dart';
import 'eta_calculator.dart';
import 'trip_progress_service.dart';

class JourneyEngine {
  const JourneyEngine();

  List<JourneyEvent> buildTimeline({
    required Trip trip,
    required List<RouteCheckpointStatus> statuses,
    required DateTime departureTime,
    List<JourneyEvent> manualEvents = const [],
    DateTime? completedTime,
  }) {
    final progressService = const TripProgressService();
    final etaCalculator = const EtaCalculator();
    final events = <JourneyEvent>[
      JourneyEvent(
        id: 'departure',
        title: 'Depart ${trip.origin}',
        type: JourneyEventType.departure,
        source: JourneyEventSource.planned,
        time: departureTime,
        subtitle: 'Planned ${trip.departureLabel}',
      ),
    ];

    var cumulativeMinutes = 0;
    for (var i = 0; i < trip.route.length; i++) {
      final segment = trip.route[i];
      cumulativeMinutes += etaCalculator.plannedMinutesForSegment(segment, trip);

      final status = statuses.firstWhere(
        (item) => item.segmentId == segment.id,
        orElse: () => RouteCheckpointStatus(segmentId: segment.id),
      );

      final plannedTime = departureTime.add(Duration(minutes: cumulativeMinutes));
      final plannedLabel = progressService.plannedCheckpointTimeLabel(
        trip: trip,
        index: i,
        departureTime: departureTime,
      );

      events.add(
        JourneyEvent(
          id: segment.id,
          title: segment.instruction,
          type: _eventTypeForSegment(segment.instruction, segment.isStop),
          source: status.isLogged ? status.source : JourneyEventSource.planned,
          time: status.actualTime ?? plannedTime,
          subtitle: status.isLogged
              ? 'Logged ${progressService.formatActualTime(status.actualTime)}'
              : 'Planned $plannedLabel',
          relatedSegmentId: segment.id,
        ),
      );
    }

    events.addAll(manualEvents);

    if (completedTime != null) {
      events.add(
        JourneyEvent(
          id: 'arrival-${completedTime.microsecondsSinceEpoch}',
          title: 'End journey',
          type: JourneyEventType.arrival,
          source: JourneyEventSource.actual,
          time: completedTime,
          subtitle: 'Trip completed',
        ),
      );
    }

    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  JourneyEventType _eventTypeForSegment(String instruction, bool isStop) {
    final lower = instruction.toLowerCase();
    if (lower.contains('breakfast') || lower.contains('restaurant')) {
      return JourneyEventType.meal;
    }
    if (lower.contains('gas') || lower.contains('fuel')) {
      return JourneyEventType.fuel;
    }
    if (lower.contains('driver change') || lower.contains('driver swap')) {
      return JourneyEventType.driverSwap;
    }
    return isStop ? JourneyEventType.stop : JourneyEventType.checkpoint;
  }
}
