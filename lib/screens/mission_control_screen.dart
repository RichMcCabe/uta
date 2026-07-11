import 'package:flutter/material.dart';

import '../models/journey_event.dart';
import '../models/route_checkpoint_status.dart';
import '../models/trip.dart';
import '../models/trip_state.dart';
import '../services/event_detector.dart';
import '../services/trip_progress_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/progress_status_badge.dart';
import '../widgets/status_tile.dart';
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            if (!_hasJourney) _buildWelcome(context) else _buildJourney(context),
            const SizedBox(height: 18),
            Text('Quick access', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _QuickAccessGrid(
              onOpenTrips: onOpenTrips,
              onOpenGps: onOpenGps,
              onOpenTools: onOpenTools,
              onPlanTrip: onPlanTrip,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          'Where are you going?',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Create a trip with a start and destination. UTA will build the journey workspace around it.',
          style: TextStyle(color: UtaColors.muted, fontSize: 17, height: 1.4),
        ),
        const SizedBox(height: 22),
        UtaCard(
          highlight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.travel_explore_rounded, size: 42, color: UtaColors.gold),
              const SizedBox(height: 18),
              const Text(
                'Plan your first journey',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose any start and destination in the world. Dates, route, reservations and live GPS can be added as you need them.',
                style: TextStyle(color: UtaColors.muted, height: 1.4),
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
    final nextPlan = trip.reservations.isEmpty ? null : trip.reservations.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          trip.name,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${trip.origin}  →  ${trip.destination}',
          style: const TextStyle(color: UtaColors.muted, fontSize: 17),
        ),
        const SizedBox(height: 18),
        UtaCard(
          highlight: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tripState == TripState.active ? 'Journey in progress' : 'Ready when you are',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(
                    tripState == TripState.active
                        ? Icons.navigation_rounded
                        : Icons.luggage_rounded,
                    color: UtaColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ProgressStatusBadge(
                label: snapshot.statusLabel,
                detail: snapshot.statusDetail,
                minutesAheadBehind: snapshot.minutesAheadBehind,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: StatusTile(
                      label: 'Departure',
                      value: trip.departureLabel,
                      icon: Icons.departure_board_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatusTile(
                      label: 'Current ETA',
                      value: snapshot.projectedArrivalLabel,
                      icon: Icons.schedule_rounded,
                      color: UtaColors.mint,
                    ),
                  ),
                ],
              ),
              if (nextPlan != null) ...[
                const SizedBox(height: 12),
                StatusTile(
                  label: 'Next plan',
                  value: '${nextPlan.title} • ${nextPlan.timeLabel}',
                  icon: Icons.event_available_rounded,
                  color: UtaColors.gold,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: tripState == TripState.active ? onEndTrip : onStartTrip,
                  icon: Icon(
                    tripState == TripState.active
                        ? Icons.flag_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    tripState == TripState.active ? 'End journey' : 'Start journey',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({
    required this.onOpenTrips,
    required this.onOpenGps,
    required this.onOpenTools,
    required this.onPlanTrip,
  });

  final VoidCallback onOpenTrips;
  final VoidCallback onOpenGps;
  final VoidCallback onOpenTools;
  final VoidCallback onPlanTrip;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickAccessItem(
        label: 'Trips',
        detail: 'Saved journeys',
        icon: Icons.luggage_rounded,
        onTap: onOpenTrips,
      ),
      _QuickAccessItem(
        label: 'GPS',
        detail: 'Live location',
        icon: Icons.gps_fixed_rounded,
        onTap: onOpenGps,
      ),
      _QuickAccessItem(
        label: 'Tools',
        detail: 'Route, plans, fuel',
        icon: Icons.dashboard_customize_rounded,
        onTap: onOpenTools,
      ),
      _QuickAccessItem(
        label: 'New trip',
        detail: 'Start somewhere new',
        icon: Icons.add_location_alt_rounded,
        onTap: onPlanTrip,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  const _QuickAccessItem({
    required this.label,
    required this.detail,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String detail;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UtaColors.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: UtaColors.sky),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(detail, style: const TextStyle(color: UtaColors.muted, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
