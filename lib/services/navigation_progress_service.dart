import 'dart:math' as math;

import '../models/tracked_location.dart';
import '../models/trip.dart';

class NavigationSnapshot {
  const NavigationSnapshot({
    required this.totalMiles,
    required this.remainingMiles,
    required this.completedMiles,
    required this.progress,
    required this.routePaceMph,
    required this.liveEta,
    required this.baselineEta,
    required this.nextInstruction,
    required this.distanceToNextMiles,
    required this.activeSegmentIndex,
    required this.distanceFromRouteMiles,
    required this.isOffRoute,
  });

  final double totalMiles;
  final double remainingMiles;
  final double completedMiles;
  final double progress;
  final double routePaceMph;
  final DateTime liveEta;
  final DateTime baselineEta;
  final String nextInstruction;
  final double distanceToNextMiles;
  final int activeSegmentIndex;
  final double distanceFromRouteMiles;
  final bool isOffRoute;

  Duration get scheduleDelta => liveEta.difference(baselineEta);
}

class NavigationProgressService {
  const NavigationProgressService();

  NavigationSnapshot calculate({
    required Trip trip,
    required TrackedLocation? location,
    required DateTime departureTime,
    double offRouteThresholdMiles = 0.35,
  }) {
    final route = trip.route;
    final now = DateTime.now();
    final totalMiles = route.fold<double>(0, (sum, item) => sum + item.distanceMiles);
    final totalHours = route.fold<double>(
      0,
      (sum, item) => sum + item.distanceMiles / math.max(15, item.speedLimitMph),
    );
    final pace = totalHours <= 0 ? 45.0 : totalMiles / totalHours;
    final baselineEta = departureTime.add(Duration(minutes: (totalHours * 60).round()));

    if (route.isEmpty) {
      return NavigationSnapshot(
        totalMiles: 0,
        remainingMiles: 0,
        completedMiles: 0,
        progress: 0,
        routePaceMph: pace,
        liveEta: now,
        baselineEta: now,
        nextInstruction: 'No route loaded',
        distanceToNextMiles: 0,
        activeSegmentIndex: 0,
        distanceFromRouteMiles: 0,
        isOffRoute: false,
      );
    }

    if (location == null) {
      return NavigationSnapshot(
        totalMiles: totalMiles,
        remainingMiles: totalMiles,
        completedMiles: 0,
        progress: 0,
        routePaceMph: pace,
        liveEta: now.add(Duration(minutes: (totalHours * 60).round())),
        baselineEta: baselineEta,
        nextInstruction: route.first.instruction,
        distanceToNextMiles: route.first.distanceMiles,
        activeSegmentIndex: 0,
        distanceFromRouteMiles: 0,
        isOffRoute: false,
      );
    }

    final points = <_RoutePoint>[
      for (var i = 0; i < route.length; i++)
        if (route[i].hasCheckpointLocation)
          _RoutePoint(
            routeIndex: i,
            latitude: route[i].checkpointLatitude!,
            longitude: route[i].checkpointLongitude!,
          ),
    ];

    var activeIndex = 0;
    var distanceFromRoute = double.infinity;
    if (points.length == 1) {
      activeIndex = points.first.routeIndex;
      distanceFromRoute = _distanceMiles(
        location.latitude,
        location.longitude,
        points.first.latitude,
        points.first.longitude,
      );
    } else if (points.length > 1) {
      for (var i = 0; i < points.length - 1; i++) {
        final distance = _distanceToSegmentMiles(
          location.latitude,
          location.longitude,
          points[i].latitude,
          points[i].longitude,
          points[i + 1].latitude,
          points[i + 1].longitude,
        );
        if (distance < distanceFromRoute) {
          distanceFromRoute = distance;
          activeIndex = points[i].routeIndex;
        }
      }
    } else {
      distanceFromRoute = 0;
    }

    activeIndex = activeIndex.clamp(0, route.length - 1);
    final nextIndex = math.min(activeIndex + 1, route.length - 1);
    final next = route[nextIndex];
    final distanceToNext = next.hasCheckpointLocation
        ? _distanceMiles(
            location.latitude,
            location.longitude,
            next.checkpointLatitude!,
            next.checkpointLongitude!,
          )
        : next.distanceMiles;

    final milesBefore = route.take(activeIndex).fold<double>(0, (sum, item) => sum + item.distanceMiles);
    final activeLength = route[activeIndex].distanceMiles;
    final activeRemaining = math.min(activeLength, math.max(0, distanceToNext));
    final completed = math.min(totalMiles, milesBefore + math.max(0, activeLength - activeRemaining));
    final remaining = math.max(0.0, totalMiles - completed).toDouble();
    final remainingHours = remaining / math.max(15.0, pace);

    return NavigationSnapshot(
      totalMiles: totalMiles,
      remainingMiles: remaining,
      completedMiles: completed,
      progress: totalMiles <= 0
          ? 0.0
          : (completed / totalMiles).clamp(0.0, 1.0).toDouble(),
      routePaceMph: pace,
      liveEta: now.add(Duration(minutes: (remainingHours * 60).round())),
      baselineEta: baselineEta,
      nextInstruction: next.instruction,
      distanceToNextMiles: distanceToNext,
      activeSegmentIndex: activeIndex,
      distanceFromRouteMiles:
          distanceFromRoute.isFinite ? distanceFromRoute : 0.0,
      isOffRoute: distanceFromRoute.isFinite && distanceFromRoute > offRouteThresholdMiles,
    );
  }

  double _distanceToSegmentMiles(
    double lat,
    double lon,
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final referenceLat = lat * math.pi / 180;
    final x = (lon - lon1) * math.cos(referenceLat);
    final y = lat - lat1;
    final dx = (lon2 - lon1) * math.cos(referenceLat);
    final dy = lat2 - lat1;
    final lengthSquared = dx * dx + dy * dy;
    final t = lengthSquared == 0 ? 0.0 : ((x * dx + y * dy) / lengthSquared).clamp(0.0, 1.0);
    final projectedLat = lat1 + t * (lat2 - lat1);
    final projectedLon = lon1 + t * (lon2 - lon1);
    return _distanceMiles(lat, lon, projectedLat, projectedLon);
  }

  double _distanceMiles(double lat1, double lon1, double lat2, double lon2) {
    const radius = 3958.7613;
    final p1 = lat1 * math.pi / 180;
    final p2 = lat2 * math.pi / 180;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(p1) * math.cos(p2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

class _RoutePoint {
  const _RoutePoint({
    required this.routeIndex,
    required this.latitude,
    required this.longitude,
  });

  final int routeIndex;
  final double latitude;
  final double longitude;
}
