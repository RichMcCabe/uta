import 'dart:math' as math;

import '../models/checkpoint_proximity.dart';
import '../models/tracked_location.dart';
import '../models/trip.dart';

class CheckpointProximityService {
  const CheckpointProximityService();

  List<CheckpointProximity> estimateProximity({
    required Trip trip,
    required TrackedLocation? location,
    double autoLogRadiusMiles = 0.25,
  }) {
    return [
      for (final segment in trip.route)
        CheckpointProximity(
          segmentId: segment.id,
          label: segment.instruction,
          distanceMiles: _distanceMilesForSegment(
            location: location,
            latitude: segment.checkpointLatitude,
            longitude: segment.checkpointLongitude,
          ),
          isWithinAutoLogRange: _isWithinAutoLogRange(
            location: location,
            latitude: segment.checkpointLatitude,
            longitude: segment.checkpointLongitude,
            autoLogRadiusMiles: autoLogRadiusMiles,
          ),
        ),
    ]..sort((a, b) => a.distanceMiles.compareTo(b.distanceMiles));
  }

  double _distanceMilesForSegment({
    required TrackedLocation? location,
    required double? latitude,
    required double? longitude,
  }) {
    if (location == null || latitude == null || longitude == null) {
      return double.infinity;
    }

    return _haversineMiles(
      location.latitude,
      location.longitude,
      latitude,
      longitude,
    );
  }

  bool _isWithinAutoLogRange({
    required TrackedLocation? location,
    required double? latitude,
    required double? longitude,
    required double autoLogRadiusMiles,
  }) {
    final distanceMiles = _distanceMilesForSegment(
      location: location,
      latitude: latitude,
      longitude: longitude,
    );
    return distanceMiles.isFinite && distanceMiles <= autoLogRadiusMiles;
  }

  double _haversineMiles(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const earthRadiusMiles = 3958.7613;
    final dLat = _toRadians(endLatitude - startLatitude);
    final dLon = _toRadians(endLongitude - startLongitude);
    final lat1 = _toRadians(startLatitude);
    final lat2 = _toRadians(endLatitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMiles * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
}
