import 'package:flutter/material.dart';

import '../models/driving_style.dart';
import '../models/profile.dart';
import '../models/tracked_location.dart';
import '../models/trip.dart';
import '../services/navigation_progress_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/uta_card.dart';

class DirectionsScreen extends StatelessWidget {
  const DirectionsScreen({
    super.key,
    required this.trip,
    required this.departureTime,
    required this.currentDriver,
    required this.lastLocation,
  });

  final Trip trip;
  final DateTime departureTime;
  final Profile? currentDriver;
  final TrackedLocation? lastLocation;

  @override
  Widget build(BuildContext context) {
    final snapshot = const NavigationProgressService().calculate(
      trip: trip,
      location: lastLocation,
      departureTime: departureTime,
    );
    var elapsedMinutes = 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Turn-by-turn directions')),
      body: trip.route.isEmpty
          ? const Center(child: Text('No directions are loaded for this leg.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                UtaCard(
                  highlight: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${trip.origin} → ${trip.destination}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text(
                        '${trip.route.length} steps • ${snapshot.remainingMiles.toStringAsFixed(0)} mi remaining • ETA ${_clock(snapshot.liveEta)}',
                        style: const TextStyle(color: UtaColors.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentDriver == null
                            ? 'Choose a driver to calculate profile-based estimates.'
                            : 'Estimates use ${currentDriver!.name}’s ${currentDriver!.drivingStyle.label.toLowerCase()} profile.',
                        style: const TextStyle(color: UtaColors.gold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < trip.route.length; index++)
                  Builder(builder: (context) {
                    final segment = trip.route[index];
                    final estimatedMph = _profileSpeed(
                      segment.speedLimitMph,
                      currentDriver,
                    );
                    final minutes = segment.distanceMiles <= 0
                        ? 0.0
                        : segment.distanceMiles / estimatedMph * 60;
                    elapsedMinutes += minutes;
                    final eta = departureTime.add(
                      Duration(minutes: elapsedMinutes.round()),
                    );
                    final isCurrent = index == snapshot.activeSegmentIndex;
                    final isComplete = index < snapshot.activeSegmentIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: UtaCard(
                        highlight: isCurrent,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: isComplete
                                  ? UtaColors.mint.withValues(alpha: 0.18)
                                  : isCurrent
                                      ? UtaColors.gold.withValues(alpha: 0.18)
                                      : Colors.white.withValues(alpha: 0.06),
                              child: Icon(
                                isComplete
                                    ? Icons.check_rounded
                                    : Icons.turn_right_rounded,
                                color: isComplete
                                    ? UtaColors.mint
                                    : isCurrent
                                        ? UtaColors.gold
                                        : UtaColors.muted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(segment.instruction,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16)),
                                  const SizedBox(height: 7),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 5,
                                    children: [
                                      _fact('${segment.distanceMiles.toStringAsFixed(segment.distanceMiles < 10 ? 1 : 0)} mi'),
                                      _fact('Step ETA ${_clock(eta)}'),
                                      _fact('Profile estimate $estimatedMph mph'),
                                      _fact(isCurrent && lastLocation?.speedMph != null
                                          ? 'Actual now ${lastLocation!.speedMph!.toStringAsFixed(0)} mph'
                                          : 'Actual speed --'),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Posted limit unavailable • OSRM pace is an estimate',
                                    style: TextStyle(
                                        color: UtaColors.muted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }

  static Widget _fact(String text) => Text(
        text,
        style: const TextStyle(color: UtaColors.muted, fontSize: 12),
      );

  static int _profileSpeed(int routePace, Profile? driver) {
    final adjustment = driver?.drivingStyle.defaultAdjustmentMph ?? 0;
    return (routePace + adjustment).clamp(15, 80).toInt();
  }

  static String _clock(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
