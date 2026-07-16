import '../models/driving_style.dart';
import '../models/profile.dart';
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
    if (segment.speedLimitMph <= 0 || segment.distanceMiles <= 0) return 0;

    final driver = _driverForSegment(segment, trip.profiles);
    final adjustment = driver?.drivingStyle.defaultAdjustmentMph ?? 0;
    final plannedSpeed =
        (segment.speedLimitMph + adjustment).clamp(15, 80).toInt();
    return ((segment.distanceMiles / plannedSpeed) * 60).round();
  }

  Profile? _driverForSegment(
    RouteSegment segment,
    List<Profile> profiles,
  ) {
    if (profiles.isEmpty) return null;

    final assignedName = segment.assignedDriverName.trim().toLowerCase();
    if (assignedName.isNotEmpty) {
      for (final profile in profiles) {
        if (profile.name.trim().toLowerCase() == assignedName) return profile;
      }
    }

    for (final profile in profiles) {
      if (profile.isPrimary && profile.canDrive) return profile;
    }
    for (final profile in profiles) {
      if (profile.canDrive) return profile;
    }
    return profiles.first;
  }

  int totalLegalMinutes(Trip trip) => trip.route.fold(
        0,
        (sum, segment) => sum + legalMinutesForSegment(segment),
      );

  int totalPlannedMinutes(Trip trip) => trip.route.fold(
        0,
        (sum, segment) => sum + plannedMinutesForSegment(segment, trip),
      );
}
