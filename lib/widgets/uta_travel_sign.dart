import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';

enum UtaSignKind {
  road,
  airport,
  boat,
  hotel,
  food,
  ticket,
  fuel,
  warning,
  passport,
}

class UtaTravelSign extends StatelessWidget {
  const UtaTravelSign({
    super.key,
    required this.kind,
    required this.label,
    this.compact = false,
  });

  final UtaSignKind kind;
  final String label;
  final bool compact;

  IconData get icon {
    switch (kind) {
      case UtaSignKind.road:
        return Icons.alt_route_rounded;
      case UtaSignKind.airport:
        return Icons.flight_takeoff_rounded;
      case UtaSignKind.boat:
        return Icons.sailing_rounded;
      case UtaSignKind.hotel:
        return Icons.hotel_rounded;
      case UtaSignKind.food:
        return Icons.restaurant_rounded;
      case UtaSignKind.ticket:
        return Icons.confirmation_number_rounded;
      case UtaSignKind.fuel:
        return Icons.local_gas_station_rounded;
      case UtaSignKind.warning:
        return Icons.warning_amber_rounded;
      case UtaSignKind.passport:
        return Icons.badge_rounded;
    }
  }

  Color get color {
    switch (kind) {
      case UtaSignKind.road:
        return UtaColors.sky;
      case UtaSignKind.airport:
        return UtaColors.gold;
      case UtaSignKind.boat:
        return UtaColors.mint;
      case UtaSignKind.hotel:
        return UtaColors.passport;
      case UtaSignKind.food:
        return UtaColors.sunset;
      case UtaSignKind.ticket:
        return UtaColors.gold;
      case UtaSignKind.fuel:
        return UtaColors.mint;
      case UtaSignKind.warning:
        return UtaColors.coral;
      case UtaSignKind.passport:
        return UtaColors.passport;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: compact ? 16 : 18),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}
