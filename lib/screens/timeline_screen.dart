import 'package:flutter/material.dart';

import '../models/journey_event.dart';
import '../models/journey_event_type.dart';
import '../models/route_checkpoint_status.dart';
import '../models/trip.dart';
import '../services/journey_engine.dart';
import '../services/journey_stats_service.dart';
import '../widgets/journey_stats_card.dart';
import '../widgets/journey_timeline_card.dart';
import '../widgets/quick_event_button.dart';
import '../widgets/section_header.dart';
import '../widgets/uta_card.dart';
import '../widgets/warning_banner.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({
    super.key,
    required this.trip,
    required this.statuses,
    required this.departureTime,
    required this.manualEvents,
    required this.completedTime,
    required this.onAddQuickEvent,
  });

  final Trip trip;
  final List<RouteCheckpointStatus> statuses;
  final DateTime departureTime;
  final List<JourneyEvent> manualEvents;
  final DateTime? completedTime;
  final void Function(JourneyEventType type, String title) onAddQuickEvent;

  @override
  Widget build(BuildContext context) {
    final events = const JourneyEngine().buildTimeline(
      trip: trip,
      statuses: statuses,
      departureTime: departureTime,
      manualEvents: manualEvents,
      completedTime: completedTime,
    );
    final stats = const JourneyStatsService().buildStats(
      trip: trip,
      statuses: statuses,
      manualEvents: manualEvents,
      departureTime: departureTime,
      completedTime: completedTime,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Journey Timeline')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          JourneyStatsCard(stats: stats),
          const SectionHeader(
            'Journey Recorder',
            subtitle: 'Quickly log real events without needing to touch the route checklist.',
          ),
          UtaCard(
            highlight: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick log',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const WarningBanner(
                  title: 'Safe logging',
                  message: 'Use quick log when parked or as a passenger. UTA is designed so missed checkpoints can be logged later.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    QuickEventButton(
                      label: 'Fuel',
                      type: JourneyEventType.fuel,
                      onTap: () => onAddQuickEvent(JourneyEventType.fuel, 'Fuel stop'),
                    ),
                    QuickEventButton(
                      label: 'Meal',
                      type: JourneyEventType.meal,
                      onTap: () => onAddQuickEvent(JourneyEventType.meal, 'Meal stop'),
                    ),
                    QuickEventButton(
                      label: 'Bathroom',
                      type: JourneyEventType.bathroom,
                      onTap: () => onAddQuickEvent(JourneyEventType.bathroom, 'Bathroom break'),
                    ),
                    QuickEventButton(
                      label: 'Driver swap',
                      type: JourneyEventType.driverSwap,
                      onTap: () => onAddQuickEvent(JourneyEventType.driverSwap, 'Driver swap'),
                    ),
                    QuickEventButton(
                      label: 'Traffic',
                      type: JourneyEventType.trafficDelay,
                      onTap: () => onAddQuickEvent(JourneyEventType.trafficDelay, 'Traffic delay'),
                    ),
                    QuickEventButton(
                      label: 'Note',
                      type: JourneyEventType.note,
                      onTap: () => onAddQuickEvent(JourneyEventType.note, 'Trip note'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader(
            'Timeline',
            subtitle: 'Planned checkpoints plus actual events, sorted by time.',
          ),
          for (var i = 0; i < events.length; i++)
            JourneyTimelineCard(
              event: events[i],
              isLast: i == events.length - 1,
            ),
        ],
      ),
    );
  }
}
