import 'package:flutter/material.dart';

import 'uta_travel_sign.dart';

class UtaModuleChip extends StatelessWidget {
  const UtaModuleChip({
    super.key,
    required this.kind,
    required this.label,
    required this.enabled,
  });

  final UtaSignKind kind;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: UtaTravelSign(kind: kind, label: enabled ? label : '$label off', compact: true),
    );
  }
}
