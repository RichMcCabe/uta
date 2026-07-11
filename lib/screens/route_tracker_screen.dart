import 'package:flutter/material.dart';

import '../models/route_checkpoint_status.dart';
import '../models/trip.dart';
import '../models/trip_state.dart';
import '../services/eta_calculator.dart';
import '../services/event_detector.dart';
import '../services/trip_progress_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/checkpoint_tile.dart';
import '../widgets/progress_status_badge.dart';
import '../widgets/section_header.dart';
import '../widgets/status_tile.dart';
import '../widgets/uta_card.dart';
import '../widgets/warning_banner.dart';

class RouteTrackerScreen extends StatelessWidget {
  const RouteTrackerScreen({
    super.key,
    required this.trip,
    required this.statuses,
    required this.departureTime,
    required this.targetArrivalTime,
    required this.tripState,
    required this.trackingMode,
    required this.onStartTrip,
    required this.onEndTrip,
    required this.onLogCheckpoint,
    required this.onClearCheckpoint,
    required this.onResetProgress,
  });

  final Trip trip;
  final List<RouteCheckpointStatus> statuses;
  final DateTime departureTime;
  final DateTime targetArrivalTime;
  final TripState tripState;
  final TrackingMode trackingMode;
  final VoidCallback onStartTrip;
  final VoidCallback onEndTrip;
  final void Function(String segmentId, DateTime actualTime) onLogCheckpoint;
  final void Function(String segmentId) onClearCheckpoint;
  final VoidCallback onResetProgress;

  @override
  Widget build(BuildContext context) {
    final calculator = const EtaCalculator();
    final progressService = const TripProgressService();
    final snapshot = progressService.snapshot(
      trip: trip,
      statuses: statuses,
      departureTime: departureTime,
      targetArrivalTime: targetArrivalTime,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Tracker'),
        actions: [
          IconButton(
            onPressed: onResetProgress,
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset progress',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WarningBanner(
            title: 'Manual checkpoint mode',
            message: 'Checkpoints do not have to be logged in order. If you log checkpoint 5 and skip 2–4, UTA uses checkpoint 5 as the latest known progress point.',
          ),
          const SizedBox(height: 12),
          UtaCard(
            highlight: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        label: 'Projected ETA',
                        value: snapshot.projectedArrivalLabel,
                        icon: Icons.schedule_rounded,
                        color: UtaColors.mint,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusTile(
                        label: 'Progress',
                        value: '${snapshot.loggedCount}/${snapshot.totalCount}',
                        icon: Icons.flag_rounded,
                        color: UtaColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatusTile(
                  label: 'Tracking mode',
                  value: trackingMode.description,
                  icon: Icons.gps_fixed_rounded,
                  color: UtaColors.sky,
                ),
                const SizedBox(height: 12),
                if (tripState != TripState.active)
                  FilledButton.icon(
                    onPressed: onStartTrip,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start Trip Now'),
                  )
                else
                  FilledButton.icon(
                    onPressed: onEndTrip,
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text('End Journey'),
                  ),
              ],
            ),
          ),
          SectionHeader(
            trip.route.isEmpty ? 'No route yet' : 'Journey route',
            subtitle: trip.route.isEmpty
                ? 'Use Build route in Trip tools to add directions and checkpoints.'
                : 'Tap checkpoints during the journey or catch up later at a safe stop.',
          ),
          if (trip.route.isEmpty)
            const UtaCard(
              child: Row(
                children: [
                  Icon(Icons.route_rounded, color: UtaColors.gold),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your trip is saved, but a route has not been built yet.',
                      style: TextStyle(color: UtaColors.muted, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          for (var i = 0; i < trip.route.length; i++)
            CheckpointTile(
              segment: trip.route[i],
              index: i,
              plannedMinutes: calculator.plannedMinutesForSegment(trip.route[i], trip),
              plannedTimeLabel: progressService.plannedCheckpointTimeLabel(
                trip: trip,
                index: i,
                departureTime: departureTime,
              ),
              actualTimeLabel: progressService.formatActualTime(_statusFor(i).actualTime),
              differenceLabel: progressService.formatDifference(
                progressService.checkpointDifferenceMinutes(
                  trip: trip,
                  index: i,
                  departureTime: departureTime,
                  actualTime: _statusFor(i).actualTime,
                ),
              ),
              isLogged: _statusFor(i).isLogged,
              onLogNow: () => onLogCheckpoint(trip.route[i].id, DateTime.now()),
              onLogTenMinutesAgo: () => onLogCheckpoint(
                trip.route[i].id,
                DateTime.now().subtract(const Duration(minutes: 10)),
              ),
              onLogThirtyMinutesAgo: () => onLogCheckpoint(
                trip.route[i].id,
                DateTime.now().subtract(const Duration(minutes: 30)),
              ),
              onClear: () => onClearCheckpoint(trip.route[i].id),
            ),
        ],
      ),
    );
  }

  RouteCheckpointStatus _statusFor(int index) {
    final segmentId = trip.route[index].id;
    return statuses.firstWhere(
      (status) => status.segmentId == segmentId,
      orElse: () => RouteCheckpointStatus(segmentId: segmentId),
    );
  }
}
