import 'package:flutter/material.dart';

import '../models/route_segment.dart';
import '../models/speed_source.dart';
import '../theme/uta_theme.dart';

class DirectionSegmentCard extends StatelessWidget {
  const DirectionSegmentCard({
    super.key,
    required this.segment,
    required this.index,
  });

  final RouteSegment segment;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isStop = segment.isStop;
    final speedColor = _colorForSource(segment.speedSource);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UtaColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isStop ? UtaColors.gold : UtaColors.sky,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: UtaColors.night,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(segment.instruction, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(
                isStop
                    ? '${segment.plannedStopMinutes} min stop'
                    : '${segment.distanceMiles.toStringAsFixed(1)} mi • ${segment.speedLimitMph} mph posted • ${segment.assignedDriverName}',
                style: const TextStyle(color: UtaColors.muted),
              ),
              if (!isStop) ...[
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: speedColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: speedColor.withValues(alpha: 0.28)),
                  ),
                  child: Text(
                    'Speed: ${segment.speedSource.shortLabel}',
                    style: TextStyle(
                      color: speedColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              if (segment.note != null) ...[
                const SizedBox(height: 5),
                Text(segment.note!, style: const TextStyle(color: UtaColors.gold, fontSize: 12)),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Color _colorForSource(SpeedSource source) {
    switch (source) {
      case SpeedSource.postedVerified:
      case SpeedSource.userOverride:
        return UtaColors.mint;
      case SpeedSource.imported:
        return UtaColors.sky;
      case SpeedSource.estimated:
        return UtaColors.gold;
      case SpeedSource.unknown:
        return UtaColors.coral;
    }
  }
}
