import 'package:flutter/material.dart';

import '../models/gps_tracking_state.dart';
import '../models/journey_event.dart';
import '../models/location_permission_status.dart';
import '../models/profile.dart';
import '../models/route_checkpoint_status.dart';
import '../models/tracked_location.dart';
import '../models/trip.dart';
import '../models/trip_state.dart';
import '../services/driver_eligibility_service.dart';
import '../services/event_detector.dart';
import '../services/trip_progress_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/uta_card.dart';
import '../widgets/uta_logo.dart';

class MissionControlScreen extends StatelessWidget {
  const MissionControlScreen({
    super.key,
    required this.trip,
    required this.statuses,
    required this.departureTime,
    required this.targetArrivalTime,
    required this.tripState,
    required this.trackingMode,
    required this.manualEvents,
    required this.completedTime,
    required this.locationPermissionStatus,
    required this.gpsTrackingState,
    required this.lastLocation,
    required this.onStartTrip,
    required this.onEndTrip,
    required this.onPlanTrip,
    required this.onOpenTrips,
    required this.onOpenGps,
    required this.onOpenTools,
  });

  final Trip trip;
  final List<RouteCheckpointStatus> statuses;
  final DateTime departureTime;
  final DateTime targetArrivalTime;
  final TripState tripState;
  final TrackingMode trackingMode;
  final List<JourneyEvent> manualEvents;
  final DateTime? completedTime;
  final LocationPermissionStatus locationPermissionStatus;
  final GpsTrackingState gpsTrackingState;
  final TrackedLocation? lastLocation;
  final VoidCallback onStartTrip;
  final VoidCallback onEndTrip;
  final VoidCallback onPlanTrip;
  final VoidCallback onOpenTrips;
  final VoidCallback onOpenGps;
  final VoidCallback onOpenTools;

  bool get _hasJourney =>
      trip.origin != 'Choose a start' &&
      trip.destination != 'Choose a destination';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const UtaLogo(showWordmark: true),
        actions: [
          IconButton(
            onPressed: onPlanTrip,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Plan a trip',
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071629), UtaColors.night],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              if (!_hasJourney) _buildWelcome(context) else _buildJourney(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text('Your journey starts here.', style: UtaText.hero),
        const SizedBox(height: 12),
        const Text(
          'Build a route, save the trip, and let UTA turn it into a live mission plan.',
          style: TextStyle(color: UtaColors.muted, fontSize: 16, height: 1.45),
        ),
        const SizedBox(height: 24),
        UtaCard(
          highlight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: UtaColors.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.travel_explore_rounded, color: UtaColors.gold, size: 30),
              ),
              const SizedBox(height: 18),
              const Text('Plan your first journey', style: UtaText.title),
              const SizedBox(height: 8),
              const Text(
                'Choose a start and destination, preview the route, then save it to Mission Control.',
                style: TextStyle(color: UtaColors.muted, height: 1.45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPlanTrip,
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: const Text('Create a trip'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJourney(BuildContext context) {
    final snapshot = const TripProgressService().snapshot(
      trip: trip,
      statuses: statuses,
      departureTime: departureTime,
      targetArrivalTime: targetArrivalTime,
    );
    final totalMiles = trip.route.fold<double>(0, (sum, segment) => sum + segment.distanceMiles);
    final completedMiles = _completedMiles();
    final remainingMiles = (totalMiles - completedMiles).clamp(0, double.infinity);
    final progressPercent = (snapshot.progress * 100).round();
    final currentDriver = _currentDriverName();
    final driverProfile = _driverProfile(currentDriver);
    final restriction = driverProfile == null
        ? 'Driver profile unavailable'
        : const DriverEligibilityService().eligibilitySummary(
            driverProfile,
            trip.sunriseLabel,
            trip.sunsetLabel,
          );
    final nextStop = trip.stops.isEmpty ? null : trip.stops.first;
    final fuelCost = trip.fuelEntries.fold<double>(0, (sum, entry) => sum + entry.totalCost);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _JourneyHeader(trip: trip, tripState: tripState),
        const SizedBox(height: 16),
        UtaCard(
          highlight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('TRIP PROGRESS', style: UtaText.label)),
                  Text('$progressPercent%', style: const TextStyle(color: UtaColors.gold, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: snapshot.progress.clamp(0, 1),
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation(UtaColors.gold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(snapshot.statusDetail, style: const TextStyle(color: UtaColors.muted))),
                  Text('${remainingMiles.toStringAsFixed(0)} of ${totalMiles.toStringAsFixed(0)} mi left', style: const TextStyle(color: UtaColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'ETA',
                value: snapshot.projectedArrivalLabel,
                detail: snapshot.statusLabel,
                icon: Icons.schedule_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'DISTANCE',
                value: '${remainingMiles.toStringAsFixed(0)} mi',
                detail: '${snapshot.loggedCount}/${snapshot.totalCount} checkpoints',
                icon: Icons.route_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                label: 'DRIVER',
                value: currentDriver,
                detail: driverProfile?.canDrive == true ? 'Eligible' : 'Check profile',
                icon: Icons.person_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        UtaCard(
          onTap: onOpenGps,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: UtaColors.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.turn_right_rounded, color: UtaColors.gold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NEXT', style: UtaText.label),
                    const SizedBox(height: 4),
                    Text(snapshot.nextCheckpointLabel, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: UtaColors.muted),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatusCard(
                label: 'DRIVING WINDOW',
                value: restriction,
                icon: Icons.verified_user_rounded,
                color: driverProfile?.canDrive == false ? UtaColors.coral : UtaColors.mint,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatusCard(
                label: 'GPS',
                value: _gpsSummary(),
                icon: Icons.gps_fixed_rounded,
                color: gpsTrackingState == GpsTrackingState.active ? UtaColors.mint : UtaColors.sky,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StatusCard(
                label: 'FUEL',
                value: trip.fuelEntries.isEmpty ? 'No fuel stops logged' : '\$${fuelCost.toStringAsFixed(2)} logged',
                icon: Icons.local_gas_station_rounded,
                color: UtaColors.gold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatusCard(
                label: 'WEATHER',
                value: 'Provider not connected',
                icon: Icons.cloud_outlined,
                color: UtaColors.sky,
              ),
            ),
          ],
        ),
        if (nextStop != null) ...[
          const SizedBox(height: 12),
          UtaCard(
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: UtaColors.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NEXT STOP', style: UtaText.label),
                      const SizedBox(height: 4),
                      Text(nextStop.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        Text('Quick actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        _QuickActions(
          onOpenTrips: onOpenTrips,
          onOpenGps: onOpenGps,
          onOpenTools: onOpenTools,
          onPlanTrip: onPlanTrip,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: tripState == TripState.active ? onEndTrip : onStartTrip,
            icon: Icon(tripState == TripState.active ? Icons.flag_rounded : Icons.navigation_rounded),
            label: Text(tripState == TripState.active ? 'End journey' : 'Start journey'),
          ),
        ),
      ],
    );
  }

  double _completedMiles() {
    final loggedIds = statuses.where((status) => status.isLogged).map((status) => status.segmentId).toSet();
    return trip.route.where((segment) => loggedIds.contains(segment.id)).fold<double>(0, (sum, segment) => sum + segment.distanceMiles);
  }

  String _currentDriverName() {
    final loggedIds = statuses.where((status) => status.isLogged).map((status) => status.segmentId).toSet();
    for (final segment in trip.route) {
      if (!loggedIds.contains(segment.id) && segment.assignedDriverName.trim().isNotEmpty) {
        return segment.assignedDriverName;
      }
    }
    if (trip.profiles.isNotEmpty) return trip.profiles.first.name;
    return 'Unassigned';
  }

  Profile? _driverProfile(String name) {
    for (final profile in trip.profiles) {
      if (profile.name == name) return profile;
    }
    return null;
  }

  String _gpsSummary() {
    if (gpsTrackingState == GpsTrackingState.active && lastLocation != null) {
      final speed = lastLocation!.speedMph;
      return speed == null ? 'Live tracking active' : '${speed.toStringAsFixed(0)} mph live';
    }
    if (locationPermissionStatus.canTrack) return 'Ready to track';
    if (locationPermissionStatus == LocationPermissionStatus.denied) return 'Permission denied';
    if (locationPermissionStatus == LocationPermissionStatus.disabled) return 'Location disabled';
    return 'Location not active';
  }
}

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({required this.trip, required this.tripState});

  final Trip trip;
  final TripState tripState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('CURRENT TRIP', style: UtaText.label.copyWith(color: UtaColors.gold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: UtaColors.mint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: UtaColors.mint.withValues(alpha: 0.3)),
              ),
              child: Text(tripState.label.toUpperCase(), style: const TextStyle(color: UtaColors.mint, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(trip.name, style: UtaText.hero),
        const SizedBox(height: 10),
        Text('${trip.origin}  →  ${trip.destination}', style: const TextStyle(color: UtaColors.muted, fontSize: 16, height: 1.35)),
        const SizedBox(height: 6),
        Text('${trip.startDateLabel} — ${trip.endDateLabel}', style: const TextStyle(color: UtaColors.muted, fontSize: 13)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.detail, required this.icon});

  final String label;
  final String value;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: Text(label, style: UtaText.label)), Icon(icon, size: 16, color: UtaColors.gold)]),
          const SizedBox(height: 10),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: UtaColors.muted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(label, style: UtaText.label),
          const SizedBox(height: 5),
          Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, height: 1.25)),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onOpenTrips, required this.onOpenGps, required this.onOpenTools, required this.onPlanTrip});

  final VoidCallback onOpenTrips;
  final VoidCallback onOpenGps;
  final VoidCallback onOpenTools;
  final VoidCallback onPlanTrip;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('Trips', Icons.luggage_rounded, onOpenTrips),
      _ActionData('Navigate', Icons.navigation_rounded, onOpenGps),
      _ActionData('Tools', Icons.tune_rounded, onOpenTools),
      _ActionData('New trip', Icons.add_location_alt_rounded, onPlanTrip),
    ];
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: _ActionButton(data: actions[i])),
        ],
      ],
    );
  }
}

class _ActionData {
  const _ActionData(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.data});
  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UtaColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
          child: Column(
            children: [
              Icon(data.icon, color: UtaColors.gold, size: 22),
              const SizedBox(height: 7),
              Text(data.label, maxLines: 1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
