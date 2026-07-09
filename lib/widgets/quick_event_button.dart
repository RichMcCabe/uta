import 'package:flutter/material.dart';

import '../models/journey_event_type.dart';
import '../theme/uta_theme.dart';

class QuickEventButton extends StatelessWidget {
  const QuickEventButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
  });

  final String label;
  final JourneyEventType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(type);

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(_iconForType(type), size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.42)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      ),
    );
  }

  Color _colorForType(JourneyEventType type) {
    switch (type) {
      case JourneyEventType.fuel:
        return UtaColors.mint;
      case JourneyEventType.meal:
        return UtaColors.sunset;
      case JourneyEventType.bathroom:
        return UtaColors.sky;
      case JourneyEventType.driverSwap:
        return UtaColors.gold;
      case JourneyEventType.trafficDelay:
        return UtaColors.coral;
      case JourneyEventType.note:
      case JourneyEventType.custom:
        return UtaColors.passport;
      default:
        return UtaColors.gold;
    }
  }

  IconData _iconForType(JourneyEventType type) {
    switch (type) {
      case JourneyEventType.fuel:
        return Icons.local_gas_station_rounded;
      case JourneyEventType.meal:
        return Icons.restaurant_rounded;
      case JourneyEventType.bathroom:
        return Icons.wc_rounded;
      case JourneyEventType.driverSwap:
        return Icons.swap_horiz_rounded;
      case JourneyEventType.trafficDelay:
        return Icons.traffic_rounded;
      case JourneyEventType.note:
      case JourneyEventType.custom:
        return Icons.add_comment_rounded;
      default:
        return Icons.add_rounded;
    }
  }
}
