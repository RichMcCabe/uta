import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';
import 'uta_travel_sign.dart';

class UtaPatternBackground extends StatelessWidget {
  const UtaPatternBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.25,
                colors: [UtaColors.passport, UtaColors.plum, UtaColors.night],
                stops: [0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
        const Positioned(
          right: -18,
          top: 18,
          child: Opacity(
            opacity: 0.28,
            child: _FloatingSign(kind: UtaSignKind.airport, label: 'GATE B12', rotation: -0.13),
          ),
        ),
        const Positioned(
          right: 120,
          top: 104,
          child: Opacity(
            opacity: 0.22,
            child: _FloatingSign(kind: UtaSignKind.road, label: 'I-95 S', rotation: 0.11),
          ),
        ),
        const Positioned(
          right: 36,
          bottom: 48,
          child: Opacity(
            opacity: 0.20,
            child: _FloatingSign(kind: UtaSignKind.boat, label: 'NO WAKE', rotation: 0.08),
          ),
        ),
        const Positioned(
          left: 18,
          bottom: 28,
          child: Opacity(
            opacity: 0.18,
            child: _FloatingSign(kind: UtaSignKind.ticket, label: 'TICKETS', rotation: -0.08),
          ),
        ),
        child,
      ],
    );
  }
}

class _FloatingSign extends StatelessWidget {
  const _FloatingSign({
    required this.kind,
    required this.label,
    required this.rotation,
  });

  final UtaSignKind kind;
  final String label;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: UtaTravelSign(kind: kind, label: label),
    );
  }
}
