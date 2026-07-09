import 'package:flutter/material.dart';

import '../models/journey_event.dart';
import '../models/journey_event_type.dart';
import '../theme/uta_theme.dart';

class JourneyTimelineCard extends StatelessWidget {
  const JourneyTimelineCard({
    super.key,
    required this.event,
    required this.isLast,
  });

  final JourneyEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = _colorForSource(event.source);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.46)),
              ),
              child: Icon(_iconForType(event.type), color: color, size: 18),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: Colors.white.withValues(alpha: 0.10),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: UtaColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                if (event.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(event.subtitle!, style: const TextStyle(color: UtaColors.muted)),
                ],
                const SizedBox(height: 8),
                _SourceBadge(source: event.source, color: color),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _colorForSource(JourneyEventSource source) {
    switch (source) {
      case JourneyEventSource.actual:
      case JourneyEventSource.gpsAuto:
      case JourneyEventSource.gpsAssisted:
        return UtaColors.mint;
      case JourneyEventSource.estimated:
        return UtaColors.sky;
      case JourneyEventSource.skipped:
        return UtaColors.coral;
      case JourneyEventSource.planned:
        return UtaColors.gold;
    }
  }

  IconData _iconForType(JourneyEventType type) {
    switch (type) {
      case JourneyEventType.departure:
        return Icons.home_rounded;
      case JourneyEventType.checkpoint:
        return Icons.flag_rounded;
      case JourneyEventType.stop:
        return Icons.pause_circle_rounded;
      case JourneyEventType.fuel:
        return Icons.local_gas_station_rounded;
      case JourneyEventType.meal:
        return Icons.restaurant_rounded;
      case JourneyEventType.bathroom:
        return Icons.wc_rounded;
      case JourneyEventType.driverSwap:
        return Icons.swap_horiz_rounded;
      case JourneyEventType.reservation:
        return Icons.confirmation_number_rounded;
      case JourneyEventType.trafficDelay:
        return Icons.traffic_rounded;
      case JourneyEventType.arrival:
        return Icons.location_on_rounded;
      case JourneyEventType.note:
        return Icons.notes_rounded;
      case JourneyEventType.custom:
        return Icons.star_rounded;
    }
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source, required this.color});

  final JourneyEventSource source;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        source.label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}
