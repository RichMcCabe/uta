import 'package:flutter/material.dart';

import '../models/trip_leg.dart';
import '../theme/uta_theme.dart';
import 'uta_card.dart';
import 'uta_travel_sign.dart';

class LegSummaryCard extends StatelessWidget {
  const LegSummaryCard({
    super.key,
    required this.leg,
    required this.onSelect,
    required this.onClone,
    required this.onDelete,
  });

  final TripLeg leg;
  final VoidCallback onSelect;
  final VoidCallback onClone;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      highlight: leg.isActive,
      onTap: onSelect,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  leg.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              if (leg.isActive)
                const UtaTravelSign(
                  kind: UtaSignKind.road,
                  label: 'ACTIVE LEG',
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${leg.startLabel} → ${leg.endLabel}',
            style: const TextStyle(color: UtaColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              UtaTravelSign(
                kind: UtaSignKind.fuel,
                label: '${leg.totalMiles.toStringAsFixed(1)} MI',
                compact: true,
              ),
              UtaTravelSign(
                kind: UtaSignKind.ticket,
                label: '${leg.checkpointCount} SEGMENTS',
                compact: true,
              ),
              UtaTravelSign(
                kind: UtaSignKind.passport,
                label: leg.inputMode.label.toUpperCase(),
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClone,
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Clone'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_rounded),
                tooltip: 'Delete leg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
