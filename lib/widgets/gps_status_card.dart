import 'package:flutter/material.dart';

import '../models/gps_tracking_state.dart';
import '../models/location_permission_status.dart';
import '../models/tracked_location.dart';
import '../theme/uta_theme.dart';
import 'uta_card.dart';

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
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  final LocationPermissionStatus permissionStatus;
  final GpsTrackingState trackingState;
  final TrackedLocation? lastLocation;
  final String message;
  final VoidCallback onRequestPermission;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  Widget build(BuildContext context) {
    final canStart = permissionStatus.canTrack &&
        trackingState != GpsTrackingState.active;
    final showSettings = permissionStatus == LocationPermissionStatus.denied;
    final showLocationSettings =
        permissionStatus == LocationPermissionStatus.disabled;

    return UtaCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Live GPS',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
              _StatusPill(
                label: trackingState.label,
                active: trackingState == GpsTrackingState.active,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: UtaColors.muted)),
          const SizedBox(height: 14),
          if (lastLocation == null)
            const Text(
              'No GPS fix yet.',
              style: TextStyle(fontWeight: FontWeight.w800),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _MetricBlock(
                    label: 'Current speed',
                    value: lastLocation!.speedMph == null
                        ? '-- mph'
                        : '${lastLocation!.speedMph!.toStringAsFixed(0)} mph',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricBlock(
                    label: 'GPS accuracy',
                    value: lastLocation!.accuracyMeters == null
                        ? '--'
                        : '${lastLocation!.accuracyMeters!.toStringAsFixed(0)} m',
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onRequestPermission,
                icon: const Icon(Icons.location_searching_rounded),
                label: Text(
                  permissionStatus == LocationPermissionStatus.notRequested
                      ? 'Allow location'
                      : 'Refresh location',
                ),
              ),
              FilledButton.icon(
                onPressed: canStart ? onStartTracking : null,
                icon: const Icon(Icons.gps_fixed_rounded),
                label: const Text('Start tracking'),
              ),
              OutlinedButton.icon(
                onPressed: trackingState == GpsTrackingState.active
                    ? onStopTracking
                    : null,
                icon: const Icon(Icons.gps_off_rounded),
                label: const Text('Stop'),
              ),
              if (showSettings)
                OutlinedButton.icon(
                  onPressed: onOpenAppSettings,
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('App settings'),
                ),
              if (showLocationSettings)
                OutlinedButton.icon(
                  onPressed: onOpenLocationSettings,
                  icon: const Icon(Icons.location_disabled_rounded),
                  label: const Text('Location settings'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UtaColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: UtaText.label),
          const SizedBox(height: 4),
          Text(value, style: UtaText.value),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? UtaColors.mint.withValues(alpha: 0.14)
            : UtaColors.cardSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? UtaColors.mint : UtaColors.muted,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
