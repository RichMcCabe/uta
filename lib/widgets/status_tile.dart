import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';

class StatusTile extends StatelessWidget {
  const StatusTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = UtaColors.gold,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UtaColors.cardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: UtaText.label),
                const SizedBox(height: 4),
                Text(value, style: UtaText.value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
