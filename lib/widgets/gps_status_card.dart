import 'package:flutter/material.dart';

import '../models/gps_tracking_state.dart';
import '../models/location_permission_status.dart';
import '../models/tracked_location.dart';
import '../theme/uta_theme.dart';
import 'uta_card.dart';
import 'uta_travel_sign.dart';

class GpsStatusCard extends StatelessWidget {
  const GpsStatusCard({
    super.key,
    required this.permissionStatus,
    required this.trackingState,
    required this.lastLocation,
    required this.message,
    required this.onRequestPermission,
    required this.onStartTracking,
    required this.onStopTracking,
  });

  final LocationPermissionStatus permissionStatus;
  final GpsTrackingState trackingState;
  final TrackedLocation? lastLocation;
  final String message;
  final VoidCallback onRequestPermission;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;

  @override
  Widget build(BuildContext context) {
    final canStart = permissionStatus.canTrack &&
        trackingState != GpsTrackingState.active;

    return UtaCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live GPS',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: UtaColors.muted)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              UtaTravelSign(
                kind: UtaSignKind.passport,
                label: permissionStatus.label.toUpperCase(),
                compact: true,
              ),
              UtaTravelSign(
                kind: UtaSignKind.road,
                label: trackingState.label.toUpperCase(),
                compact: true,
              ),
              UtaTravelSign(
                kind: UtaSignKind.warning,
                label: 'ACTIVE TRIP ONLY',
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (lastLocation == null)
            const Text(
              'No current location captured yet.',
              style: TextStyle(fontWeight: FontWeight.w800),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: UtaColors.cardSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current location', style: UtaText.label),
                  const SizedBox(height: 4),
                  Text(lastLocation!.displayLabel, style: UtaText.value),
                  const SizedBox(height: 4),
                  Text(
                    '${lastLocation!.accuracyLabel} • ${lastLocation!.speedLabel}',
                    style: const TextStyle(color: UtaColors.muted),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onRequestPermission,
                icon: const Icon(Icons.location_searching_rounded),
                label: const Text('Request location'),
              ),
              FilledButton.icon(
                onPressed: canStart ? onStartTracking : null,
                icon: const Icon(Icons.gps_fixed_rounded),
                label: const Text('Start GPS tracking'),
              ),
              OutlinedButton.icon(
                onPressed: trackingState == GpsTrackingState.active
                    ? onStopTracking
                    : null,
                icon: const Icon(Icons.gps_off_rounded),
                label: const Text('Stop'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
