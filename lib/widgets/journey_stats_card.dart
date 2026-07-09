import 'package:flutter/material.dart';

import '../services/journey_stats_service.dart';
import '../theme/uta_theme.dart';
import 'uta_card.dart';

class JourneyStatsCard extends StatelessWidget {
  const JourneyStatsCard({super.key, required this.stats});

  final JourneyStats stats;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stats.statusLabel == 'Completed' ? 'Journey summary' : 'Journey stats so far',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatPill(label: 'Miles', value: stats.totalDistanceMiles.toStringAsFixed(0)),
              _StatPill(label: 'Planned', value: _formatMinutes(stats.plannedDrivingMinutes)),
              _StatPill(label: 'Elapsed', value: _formatMinutes(stats.elapsedMinutes)),
              _StatPill(label: 'Checkpoints', value: '${stats.loggedCheckpointCount}/${stats.totalCheckpointCount}'),
              _StatPill(label: 'Events', value: '${stats.manualEventCount}'),
              _StatPill(label: 'Stops', value: '${stats.stopEventCount}'),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UtaColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: UtaText.label),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
