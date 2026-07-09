import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';

class UtaLogo extends StatelessWidget {
  const UtaLogo({
    super.key,
    this.size = 54,
    this.showWordmark = false,
  });

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          colors: [UtaColors.sunset, UtaColors.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: UtaColors.sunset.withValues(alpha: 0.34),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.public_rounded, size: size * 0.54, color: UtaColors.night),
          Positioned(
            right: size * 0.18,
            top: size * 0.14,
            child: Transform.rotate(
              angle: -0.55,
              child: Icon(Icons.navigation_rounded, size: size * 0.30, color: UtaColors.plum),
            ),
          ),
          Positioned(
            bottom: size * 0.13,
            child: Container(
              width: size * 0.45,
              height: size * 0.06,
              decoration: BoxDecoration(
                color: UtaColors.plum.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'UTA',
              style: TextStyle(
                fontSize: 28,
                height: 0.95,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              'Ultimate Travel',
              style: TextStyle(
                color: UtaColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
