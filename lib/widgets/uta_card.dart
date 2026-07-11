import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';

class UtaCard extends StatelessWidget {
  const UtaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: highlight
          ? const LinearGradient(
              colors: [Color(0xFF12314D), UtaColors.card],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [UtaColors.cardSoft, UtaColors.card],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: highlight
            ? UtaColors.gold.withValues(alpha: 0.34)
            : Colors.white.withValues(alpha: 0.07),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );

    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: content,
      ),
    );
  }
}
