import '../models/driving_style.dart';
import '../models/route_segment.dart';
import '../models/trip.dart';

class EtaCalculator {
  const EtaCalculator();

  int legalMinutesForSegment(RouteSegment segment) {
    if (segment.isStop) return segment.plannedStopMinutes;
    if (segment.speedLimitMph <= 0 || segment.distanceMiles <= 0) return 0;
    return ((segment.distanceMiles / segment.speedLimitMph) * 60).round();
  }

  int plannedMinutesForSegment(RouteSegment segment, Trip trip) {
    if (segment.isStop) return segment.plannedStopMinutes;
    final driver = trip.profiles.firstWhere(
      (profile) => profile.name == segment.assignedDriverName,
      orElse: () => trip.profiles.first,
    );
    final adjustment = driver.drivingStyle.defaultAdjustmentMph;
    final plannedSpeed = (segment.speedLimitMph + adjustment).clamp(15, 80);
    if (segment.speedLimitMph <= 0 || segment.distanceMiles <= 0) return 0;
    return ((segment.distanceMiles / plannedSpeed) * 60).round();
  }

  int totalLegalMinutes(Trip trip) =>
      trip.route.fold(0, (sum, segment) => sum + legalMinutesForSegment(segment));

  int totalPlannedMinutes(Trip trip) =>
      trip.route.fold(0, (sum, segment) => sum + plannedMinutesForSegment(segment, trip));
}
