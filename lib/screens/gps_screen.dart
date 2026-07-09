import 'package:flutter/material.dart';

import '../models/checkpoint_proximity.dart';
import '../models/gps_tracking_state.dart';
import '../models/location_permission_status.dart';
import '../models/tracked_location.dart';
import '../models/trip.dart';
import '../services/checkpoint_proximity_service.dart';
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
  });

  final Trip trip;
  final LocationPermissionStatus permissionStatus;
  final GpsTrackingState trackingState;
  final TrackedLocation? lastLocation;
  final String locationMessage;
  final VoidCallback onRequestLocation;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;

  @override
  Widget build(BuildContext context) {
    final proximities = const CheckpointProximityService().estimateProximity(
      trip: trip,
      location: lastLocation,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('GPS Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WarningBanner(
            title: 'Live GPS beta',
            message:
                'Device permission and foreground GPS updates are now wired. Keep manual checkpoints available as the safety fallback.',
          ),
          const SizedBox(height: 12),
          GpsStatusCard(
            permissionStatus: permissionStatus,
            trackingState: trackingState,
            lastLocation: lastLocation,
            message: locationMessage,
            onRequestPermission: onRequestLocation,
            onStartTracking: onStartTracking,
            onStopTracking: onStopTracking,
          ),
          RouteMapCard(
            trip: trip,
            lastLocation: lastLocation,
          ),
          const SectionHeader(
            'Auto-log readiness',
            subtitle: 'Nearby checkpoint detection uses the active leg coordinates and live device updates.',
          ),
          Row(
            children: [
              Expanded(
                child: StatusTile(
                  label: 'Auto-log radius',
                  value: '0.25 mi',
                  icon: Icons.radar_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatusTile(
                  label: 'Tracking mode',
                  value: trackingState.label,
                  icon: Icons.gps_fixed_rounded,
                ),
              ),
            ],
          ),
          const SectionHeader('Checkpoint proximity'),
          for (final proximity in proximities.take(6))
            _ProximityTile(proximity: proximity),
        ],
      ),
    );
  }
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
