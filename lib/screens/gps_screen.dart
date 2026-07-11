import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/checkpoint_proximity.dart';
import '../models/gps_tracking_state.dart';
import '../models/location_permission_status.dart';
import '../models/tracked_location.dart';
import '../models/trip.dart';
import '../services/checkpoint_proximity_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/gps_status_card.dart';
import '../widgets/route_map_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_tile.dart';
import '../widgets/uta_card.dart';
import '../widgets/warning_banner.dart';

class GpsScreen extends StatelessWidget {
  const GpsScreen({
    super.key,
    required this.trip,
    required this.permissionStatus,
    required this.trackingState,
    required this.lastLocation,
    required this.locationMessage,
    required this.onRequestLocation,
    required this.onStartTracking,
    required this.onStopTracking,
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  final Trip trip;
  final LocationPermissionStatus permissionStatus;
  final GpsTrackingState trackingState;
  final TrackedLocation? lastLocation;
  final String locationMessage;
  final VoidCallback onRequestLocation;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final proximities = const CheckpointProximityService().estimateProximity(
      trip: trip,
      location: lastLocation,
    );
    final progress = _calculateProgress(trip, lastLocation);

    return Scaffold(
      appBar: AppBar(title: const Text('Live travel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (trip.route.isEmpty)
            const WarningBanner(
              title: 'Create a routed trip first',
              message:
                  'Live GPS can show your location now, but route progress and ETA require a trip with a generated route.',
            ),
          GpsStatusCard(
            permissionStatus: permissionStatus,
            trackingState: trackingState,
            lastLocation: lastLocation,
            message: locationMessage,
            onRequestPermission: onRequestLocation,
            onStartTracking: onStartTracking,
            onStopTracking: onStopTracking,
            onOpenAppSettings: onOpenAppSettings,
            onOpenLocationSettings: onOpenLocationSettings,
          ),
          if (trip.route.isNotEmpty) ...[
            const SizedBox(height: 12),
            _LiveJourneyCard(progress: progress),
            RouteMapCard(
              trip: trip,
              lastLocation: lastLocation,
            ),
            const SectionHeader(
              'Route progress',
              subtitle:
                  'ETA is recalculated from your GPS position and remaining route distance.',
            ),
            Row(
              children: [
                Expanded(
                  child: StatusTile(
                    label: 'Remaining',
                    value: progress.remainingDistanceLabel,
                    icon: Icons.route_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatusTile(
                    label: 'Live ETA',
                    value: progress.etaLabel,
                    icon: Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatusTile(
                    label: 'Next checkpoint',
                    value: progress.nextCheckpointLabel,
                    icon: Icons.flag_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatusTile(
                    label: 'Route pace',
                    value: progress.routePaceLabel,
                    icon: Icons.speed_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const WarningBanner(
              title: 'Speed-limit note',
              message:
                  'Current speed comes from your phone GPS. Route pace is an estimate from routing data, not a verified posted speed limit. Always follow road signs.',
            ),
            const SectionHeader('Checkpoint proximity'),
            for (final proximity in proximities.take(6))
              _ProximityTile(proximity: proximity),
          ],
        ],
      ),
    );
  }

  _LiveProgress _calculateProgress(Trip trip, TrackedLocation? location) {
    if (trip.route.isEmpty) return const _LiveProgress.empty();

    final totalDistance = trip.route.fold<double>(
      0,
      (sum, segment) => sum + segment.distanceMiles,
    );
    final routeDurationHours = trip.route.fold<double>(
      0,
      (sum, segment) =>
          sum + segment.distanceMiles / math.max(segment.speedLimitMph, 15),
    );
    final routePaceMph = routeDurationHours <= 0
        ? 45.0
        : totalDistance / routeDurationHours;

    if (location == null) {
      final eta = DateTime.now().add(
        Duration(minutes: (routeDurationHours * 60).round()),
      );
      return _LiveProgress(
        remainingMiles: totalDistance,
        eta: eta,
        nextCheckpointLabel: trip.route.first.instruction,
        routePaceMph: routePaceMph,
      );
    }

    var nearestIndex = 0;
    var nearestDistance = double.infinity;
    for (var index = 0; index < trip.route.length; index++) {
      final segment = trip.route[index];
      if (!segment.hasCheckpointLocation) continue;
      final distance = _distanceMiles(
        location.latitude,
        location.longitude,
        segment.checkpointLatitude!,
        segment.checkpointLongitude!,
      );
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestIndex = index;
      }
    }

    final remainingAfterNearest = trip.route
        .skip(nearestIndex + 1)
        .fold<double>(0, (sum, segment) => sum + segment.distanceMiles);
    final remainingMiles = math.max(
      0.0,
      nearestDistance + remainingAfterNearest,
    );
    final usableSpeed = location.speedMph != null && location.speedMph! >= 8
        ? location.speedMph!
        : routePaceMph;
    final remainingHours = remainingMiles / math.max(usableSpeed, 15);
    final eta = DateTime.now().add(
      Duration(minutes: (remainingHours * 60).round()),
    );

    return _LiveProgress(
      remainingMiles: remainingMiles,
      eta: eta,
      nextCheckpointLabel: trip.route[nearestIndex].instruction,
      routePaceMph: routePaceMph,
    );
  }

  double _distanceMiles(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadiusMiles = 3958.7613;
    final lat1 = latitude1 * math.pi / 180;
    final lat2 = latitude2 * math.pi / 180;
    final deltaLat = (latitude2 - latitude1) * math.pi / 180;
    final deltaLon = (longitude2 - longitude1) * math.pi / 180;
    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    return earthRadiusMiles * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

class _LiveJourneyCard extends StatelessWidget {
  const _LiveJourneyCard({required this.progress});

  final _LiveProgress progress;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mission status', style: UtaText.label),
          const SizedBox(height: 6),
          Text(
            progress.etaLabel,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            '${progress.remainingDistanceLabel} remaining',
            style: const TextStyle(color: UtaColors.muted),
          ),
        ],
      ),
    );
  }
}

class _LiveProgress {
  const _LiveProgress({
    required this.remainingMiles,
    required this.eta,
    required this.nextCheckpointLabel,
    required this.routePaceMph,
  });

  const _LiveProgress.empty()
      : remainingMiles = 0,
        eta = null,
        nextCheckpointLabel = 'No route',
        routePaceMph = 0;

  final double remainingMiles;
  final DateTime? eta;
  final String nextCheckpointLabel;
  final double routePaceMph;

  String get remainingDistanceLabel => remainingMiles >= 100
      ? '${remainingMiles.toStringAsFixed(0)} mi'
      : '${remainingMiles.toStringAsFixed(1)} mi';

  String get etaLabel {
    if (eta == null) return '--';
    final hour = eta!.hour % 12 == 0 ? 12 : eta!.hour % 12;
    final minute = eta!.minute.toString().padLeft(2, '0');
    final period = eta!.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get routePaceLabel => routePaceMph <= 0
      ? '--'
      : '${routePaceMph.toStringAsFixed(0)} mph est.';
}

class _ProximityTile extends StatelessWidget {
  const _ProximityTile({required this.proximity});

  final CheckpointProximity proximity;

  @override
  Widget build(BuildContext context) {
    final distanceLabel = proximity.distanceMiles.isInfinite
        ? 'Waiting for GPS'
        : '${proximity.distanceMiles.toStringAsFixed(2)} mi';

    return UtaCard(
      child: Row(
        children: [
          Icon(
            proximity.isWithinAutoLogRange
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              proximity.label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 8),
          Text(distanceLabel),
        ],
      ),
    );
  }
}
