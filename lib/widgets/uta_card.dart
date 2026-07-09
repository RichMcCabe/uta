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
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: highlight
            ? const LinearGradient(
                colors: [UtaColors.grape, UtaColors.card],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: highlight ? null : UtaColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: highlight
              ? UtaColors.sunset.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: card,
    );
  }
}
