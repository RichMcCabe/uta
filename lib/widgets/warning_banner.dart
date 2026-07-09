import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';

class WarningBanner extends StatelessWidget {
  const WarningBanner({
    super.key,
    required this.title,
    required this.message,
    this.isSevere = false,
  });

  final String title;
  final String message;
  final bool isSevere;

  @override
  Widget build(BuildContext context) {
    final color = isSevere ? UtaColors.coral : UtaColors.gold;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
