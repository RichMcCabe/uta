import 'package:flutter/material.dart';

import '../models/journey_event.dart';
import '../models/route_checkpoint_status.dart';
import '../models/trip.dart';
import '../models/trip_state.dart';
import '../services/driver_eligibility_service.dart';
import '../services/eta_calculator.dart';
import '../services/event_detector.dart';
import '../services/journey_stats_service.dart';
import '../services/trip_progress_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/journey_stats_card.dart';
import '../widgets/progress_status_badge.dart';
import '../widgets/section_header.dart';
import '../widgets/status_tile.dart';
import '../widgets/trip_dashboard_card.dart';
import '../widgets/uta_card.dart';
import '../widgets/uta_logo.dart';
import '../widgets/uta_metric_ring.dart';
import '../widgets/uta_module_chip.dart';
import '../widgets/uta_pattern_background.dart';
import '../widgets/uta_travel_sign.dart';
import '../widgets/warning_banner.dart';

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

  @override
  Widget build(BuildContext context) {
    final eta = const EtaCalculator();
    final progressService = const TripProgressService();
    final snapshot = progressService.snapshot(
      trip: trip,
      statuses: statuses,
      departureTime: departureTime,
      targetArrivalTime: targetArrivalTime,
    );
    final legalMinutes = eta.totalLegalMinutes(trip);
    final plannedMinutes = eta.totalPlannedMinutes(trip);
    final savedMinutes = legalMinutes - plannedMinutes;
    final driverService = const DriverEligibilityService();
    final stats = const JourneyStatsService().buildStats(
      trip: trip,
      statuses: statuses,
      manualEvents: manualEvents,
      departureTime: departureTime,
      completedTime: completedTime,
    );
    final kenzie = trip.profiles.firstWhere((p) => p.name == 'Kenzie');

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 270,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            title: const Text('Mission Control'),
            background: UtaPatternBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 62),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const UtaLogo(showWordmark: true),
                      const Spacer(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          UtaTravelSign(kind: UtaSignKind.road, label: 'I-95 S', compact: true),
                          UtaTravelSign(kind: UtaSignKind.airport, label: 'TRAVEL DAY', compact: true),
                          UtaTravelSign(kind: UtaSignKind.boat, label: 'NO WAKE', compact: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${trip.name}\n${trip.origin} → ${trip.destination}',
                        style: const TextStyle(color: UtaColors.muted, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.list(
            children: [
              TripDashboardCard(trip: trip),
              const SizedBox(height: 12),
              UtaCard(
                highlight: true,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 640;
                    final mainContent = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tripState.label, style: const TextStyle(color: UtaColors.muted)),
                        const SizedBox(height: 6),
                        Text(
                          'Titanic Exhibition • ${trip.targetArrivalLabel}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        ProgressStatusBadge(
                          label: snapshot.statusLabel,
                          detail: snapshot.statusDetail,
                          minutesAheadBehind: snapshot.minutesAheadBehind,
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: const [
                            UtaModuleChip(kind: UtaSignKind.ticket, label: 'Tickets', enabled: true),
                            UtaModuleChip(kind: UtaSignKind.fuel, label: 'Fuel', enabled: true),
                            UtaModuleChip(kind: UtaSignKind.hotel, label: 'Vault', enabled: true),
                            UtaModuleChip(kind: UtaSignKind.warning, label: 'GPS Later', enabled: false),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: StatusTile(
                                label: 'Current ETA',
                                value: snapshot.projectedArrivalLabel,
                                icon: Icons.schedule,
                                color: UtaColors.mint,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StatusTile(
                                label: 'Checkpoints',
                                value: '${snapshot.loggedCount}/${snapshot.totalCount}',
                                icon: Icons.flag_rounded,
                                color: UtaColors.gold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
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
                    );

                    if (!wide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mainContent,
                          const SizedBox(height: 16),
                          Center(
                            child: UtaMetricRing(
                              value: '${(snapshot.progress * 100).round()}%',
                              label: 'trip\ncomplete',
                              progress: snapshot.progress,
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: mainContent),
                        const SizedBox(width: 24),
                        UtaMetricRing(
                          value: '${(snapshot.progress * 100).round()}%',
                          label: 'trip\ncomplete',
                          progress: snapshot.progress,
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (completedTime != null) ...[
                const SectionHeader('Trip complete', subtitle: 'Summary of the journey so far.'),
                JourneyStatsCard(stats: stats),
              ],
              const SectionHeader('Trip cockpit', subtitle: 'Fast read for the drive.'),
              StatusTile(label: 'Departure basis', value: tripState == TripState.active ? 'Started now' : trip.departureLabel, icon: Icons.departure_board),
              const SizedBox(height: 10),
              StatusTile(label: 'Next checkpoint', value: snapshot.nextCheckpointLabel, icon: Icons.route),
              const SizedBox(height: 10),
              StatusTile(label: 'Tracking mode', value: trackingMode.description, icon: Icons.gps_fixed_rounded, color: UtaColors.sky),
              const SizedBox(height: 10),
              StatusTile(
                label: 'Kenzie window',
                value: driverService.eligibilitySummary(kenzie, trip.sunriseLabel, trip.sunsetLabel),
                icon: Icons.wb_sunny,
                color: UtaColors.sunset,
              ),
              const SectionHeader('Travel signs', subtitle: 'UTA visual language: road signs, airport cards, docks, tickets, vaults.'),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  UtaTravelSign(kind: UtaSignKind.road, label: 'ROUTE'),
                  UtaTravelSign(kind: UtaSignKind.airport, label: 'AIRPORT'),
                  UtaTravelSign(kind: UtaSignKind.boat, label: 'NO WAKE'),
                  UtaTravelSign(kind: UtaSignKind.hotel, label: 'HOTEL'),
                  UtaTravelSign(kind: UtaSignKind.ticket, label: 'TICKET'),
                  UtaTravelSign(kind: UtaSignKind.fuel, label: 'FUEL'),
                  UtaTravelSign(kind: UtaSignKind.passport, label: 'VAULT'),
                ],
              ),
              const SectionHeader('Planning profile'),
              const WarningBanner(
                title: 'Planning estimate only',
                message: 'UTA estimates travel time using selected planning profiles. Always obey posted speed limits, traffic laws, weather conditions, road conditions, and police instructions.',
              ),
              const SizedBox(height: 12),
              UtaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Legal estimate: $legalMinutes min', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Planned estimate: $plannedMinutes min', style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Planning difference: $savedMinutes min', style: const TextStyle(color: UtaColors.gold, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
