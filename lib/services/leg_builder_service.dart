import '../models/route_segment.dart';
import '../models/speed_source.dart';
import '../models/trip.dart';
import '../models/trip_leg.dart';
import 'eta_calculator.dart';

class LegBuilderService {
  const LegBuilderService();

  TripLeg buildCurrentTripLeg(Trip trip) {
    return TripLeg(
      id: 'primary-leg',
      name: '${trip.origin} to ${trip.destination}',
      startLabel: trip.origin,
      endLabel: trip.destination,
      inputMode: LegInputMode.manualDirections,
      segments: trip.route,
      note: 'Add directions manually or generate them from the route tools.',
      isActive: true,
    );
  }

  TripLeg buildBlankLeg({
    required String startLabel,
    required String endLabel,
    String? name,
  }) {
    final safeStart = startLabel.trim().isEmpty ? 'Start' : startLabel.trim();
    final safeEnd = endLabel.trim().isEmpty ? 'Destination' : endLabel.trim();

    return TripLeg(
      id: 'leg-${DateTime.now().microsecondsSinceEpoch}',
      name: name?.trim().isNotEmpty == true ? name!.trim() : '$safeStart to $safeEnd',
      startLabel: safeStart,
      endLabel: safeEnd,
      inputMode: LegInputMode.manualDirections,
      segments: const [],
      note: 'New leg. Generate or manually add directions.',
    );
  }

  TripLeg cloneLeg(TripLeg leg) {
    return leg.copyWith(
      id: 'leg-${DateTime.now().microsecondsSinceEpoch}',
      name: '${leg.name} Copy',
      isActive: false,
    );
  }

  int plannedMinutesForLeg(Trip trip, TripLeg leg) {
    final calculator = const EtaCalculator();
    return leg.segments.fold(
      0,
      (sum, segment) => sum + calculator.plannedMinutesForSegment(segment, trip),
    );
  }

  RouteSegment makeManualSegment({
    required String instruction,
    required double miles,
    required int speedLimitMph,
    required String driverName,
    String? note,
  }) {
    final idSeed = instruction
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    return RouteSegment(
      id: 'manual-${DateTime.now().microsecondsSinceEpoch}-$idSeed',
      instruction: instruction,
      distanceMiles: miles,
      speedLimitMph: speedLimitMph,
      assignedDriverName: driverName,
      speedSource: SpeedSource.userOverride,
      note: note,
    );
  }
}
