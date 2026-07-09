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
  });

  final Trip trip;
  final TrackedLocation? lastLocation;

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

    return UtaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_rounded, color: UtaColors.gold),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Live route map',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              Text('OSM', style: UtaText.label),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'OpenStreetMap tiles with current position and checkpoint markers.',
            style: TextStyle(color: UtaColors.muted),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: currentPoint == null ? 6.2 : 11,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.derpapps.uta',
                  ),
                  if (routePoints.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4,
                          color: UtaColors.sunset,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      for (final point in routePoints)
                        Marker(
                          point: point,
                          width: 34,
                          height: 34,
                          child: const _CheckpointMarker(),
                        ),
                      if (currentPoint != null)
                        Marker(
                          point: currentPoint,
                          width: 46,
                          height: 46,
                          child: const _CurrentLocationMarker(),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckpointMarker extends StatelessWidget {
  const _CheckpointMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UtaColors.gold,
        shape: BoxShape.circle,
        border: Border.all(color: UtaColors.night, width: 3),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black45,
          ),
        ],
      ),
      child: const Icon(
        Icons.flag_rounded,
        size: 16,
        color: UtaColors.night,
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: UtaColors.passport.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(color: UtaColors.sky, width: 2),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: UtaColors.sky,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
