import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/tracked_location.dart';
import '../models/trip.dart';
import '../theme/uta_theme.dart';
import 'uta_card.dart';

class RouteMapCard extends StatelessWidget {
  const RouteMapCard({
    super.key,
    required this.trip,
    required this.lastLocation,
    this.activeSegmentIndex = 0,
    this.followLocation = false,
  });

  final Trip trip;
  final TrackedLocation? lastLocation;
  final int activeSegmentIndex;
  final bool followLocation;

  @override
  Widget build(BuildContext context) {
    final routePoints = [
      for (final segment in trip.route)
        if (segment.hasCheckpointLocation)
          LatLng(segment.checkpointLatitude!, segment.checkpointLongitude!),
    ];
    final currentPoint = lastLocation == null
        ? null
        : LatLng(lastLocation!.latitude, lastLocation!.longitude);
    final mapCenter = currentPoint ??
        (routePoints.isNotEmpty
            ? routePoints.first
            : const LatLng(34.9249, -80.7434));
    final completedPoints = routePoints.isEmpty
        ? const <LatLng>[]
        : routePoints.take((activeSegmentIndex + 1).clamp(1, routePoints.length).toInt()).toList();

    final locationKey = currentPoint == null
        ? 'route-${routePoints.length}'
        : '${currentPoint.latitude.toStringAsFixed(4)}-${currentPoint.longitude.toStringAsFixed(4)}-$followLocation';

    return UtaCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 330,
          child: Stack(
            children: [
              FlutterMap(
                key: ValueKey(locationKey),
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: currentPoint == null ? 6.2 : (followLocation ? 13.5 : 11),
                  initialRotation: followLocation ? -(lastLocation?.headingDegrees ?? 0) : 0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom |
                        InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.derpapps.uta',
                  ),
                  if (routePoints.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 7,
                          color: UtaColors.night.withValues(alpha: 0.75),
                        ),
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4,
                          color: UtaColors.gold,
                        ),
                        if (completedPoints.length > 1)
                          Polyline(
                            points: completedPoints,
                            strokeWidth: 4,
                            color: UtaColors.sky,
                          ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (routePoints.isNotEmpty)
                        Marker(
                          point: routePoints.last,
                          width: 42,
                          height: 42,
                          child: const _DestinationMarker(),
                        ),
                      if (currentPoint != null)
                        Marker(
                          point: currentPoint,
                          width: 54,
                          height: 54,
                          child: Transform.rotate(
                            angle: ((lastLocation?.headingDegrees ?? 0) * 3.141592653589793) / 180,
                            child: const _CurrentLocationMarker(),
                          ),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [TextSourceAttribution('OpenStreetMap contributors')],
                  ),
                ],
              ),
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: UtaColors.night.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(followLocation ? Icons.navigation_rounded : Icons.map_rounded, color: UtaColors.gold, size: 16),
                      const SizedBox(width: 6),
                      Text(followLocation ? 'FOLLOWING' : 'ROUTE OVERVIEW', style: UtaText.label),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UtaColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: UtaColors.night, width: 3),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black54)],
      ),
      child: const Icon(Icons.flag_rounded, size: 20, color: UtaColors.night),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UtaColors.sky.withValues(alpha: 0.20),
        shape: BoxShape.circle,
        border: Border.all(color: UtaColors.sky.withValues(alpha: 0.55), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.navigation_rounded, color: UtaColors.sky, size: 30),
      ),
    );
  }
}
