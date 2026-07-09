import 'package:flutter/material.dart';

import '../models/route_segment.dart';
import '../models/speed_source.dart';
import '../theme/uta_theme.dart';

class CheckpointTile extends StatelessWidget {
  const CheckpointTile({
    super.key,
    required this.segment,
    required this.index,
    required this.plannedMinutes,
    required this.plannedTimeLabel,
    required this.actualTimeLabel,
    required this.differenceLabel,
    required this.isLogged,
    required this.onLogNow,
    required this.onLogTenMinutesAgo,
    required this.onLogThirtyMinutesAgo,
    required this.onClear,
  });

  final RouteSegment segment;
  final int index;
  final int plannedMinutes;
  final String plannedTimeLabel;
  final String actualTimeLabel;
  final String differenceLabel;
  final bool isLogged;
  final VoidCallback onLogNow;
  final VoidCallback onLogTenMinutesAgo;
  final VoidCallback onLogThirtyMinutesAgo;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final accent = segment.isStop ? UtaColors.gold : UtaColors.sunset;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UtaColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLogged ? accent.withValues(alpha: 0.40) : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isLogged ? UtaColors.mint : accent,
                child: Icon(
                  isLogged ? Icons.check_rounded : Icons.flag_rounded,
                  color: UtaColors.night,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(segment.instruction, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(
                    segment.isStop
                        ? '${segment.plannedStopMinutes} min stop • ${segment.assignedDriverName}'
                        : '${segment.distanceMiles.toStringAsFixed(1)} mi • limit ${segment.speedLimitMph} • ${segment.assignedDriverName} • ${segment.speedSource.shortLabel}',
                    style: const TextStyle(color: UtaColors.muted),
                  ),
                  if (segment.note != null) ...[
                    const SizedBox(height: 5),
                    Text(segment.note!, style: const TextStyle(color: UtaColors.gold, fontSize: 12)),
                  ],
                ]),
              ),
              const SizedBox(width: 8),
              Text('${plannedMinutes}m', style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: UtaColors.cardSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(child: _MiniStat(label: 'Planned', value: plannedTimeLabel)),
                Expanded(child: _MiniStat(label: 'Actual', value: actualTimeLabel)),
                Expanded(child: _MiniStat(label: 'Diff', value: differenceLabel)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: onLogNow,
                icon: const Icon(Icons.touch_app_rounded),
                label: Text(isLogged ? 'Update now' : 'Passed now'),
              ),
              OutlinedButton(
                onPressed: onLogTenMinutesAgo,
                child: const Text('10m ago'),
              ),
              OutlinedButton(
                onPressed: onLogThirtyMinutesAgo,
                child: const Text('30m ago'),
              ),
              if (isLogged)
                IconButton.filledTonal(
                  onPressed: onClear,
                  icon: const Icon(Icons.undo_rounded),
                  tooltip: 'Clear checkpoint',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: UtaColors.muted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
      ],
    );
  }
}
