import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';

class ProgressStatusBadge extends StatelessWidget {
  const ProgressStatusBadge({
    super.key,
    required this.label,
    required this.detail,
    required this.minutesAheadBehind,
  });

  final String label;
  final String detail;
  final int minutesAheadBehind;

  Color get color {
    if (minutesAheadBehind <= -15) return UtaColors.mint;
    if (minutesAheadBehind >= 15) return UtaColors.coral;
    return UtaColors.gold;
  }

  IconData get icon {
    if (minutesAheadBehind <= -15) return Icons.trending_up_rounded;
    if (minutesAheadBehind >= 15) return Icons.warning_amber_rounded;
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
              Text(detail, style: const TextStyle(color: UtaColors.muted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
