import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';

class UtaMetricRing extends StatelessWidget {
  const UtaMetricRing({
    super.key,
    required this.value,
    required this.label,
    required this.progress,
    this.color = UtaColors.gold,
  });

  final String value;
  final String label;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 122,
      width: 122,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(122),
            painter: _RingPainter(progress: progress.clamp(0, 1), color: color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: UtaColors.muted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 10.0;
    final rect = Offset.zero & size;
    final ringRect = rect.deflate(stroke / 2);
    final basePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [color, UtaColors.sunset, color],
      ).createShader(ringRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(ringRect, -math.pi / 2, math.pi * 2, false, basePaint);
    canvas.drawArc(ringRect, -math.pi / 2, math.pi * 2 * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
