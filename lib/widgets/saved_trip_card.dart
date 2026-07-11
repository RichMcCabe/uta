import 'package:flutter/material.dart';

import '../models/saved_trip_record.dart';
import '../models/trip_state.dart';
import '../theme/uta_theme.dart';
import 'uta_card.dart';

class SavedTripCard extends StatelessWidget {
  const SavedTripCard({
    super.key,
    required this.record,
    required this.onSelect,
  });

  final SavedTripRecord record;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final miles = record.trip.route.fold<double>(0, (sum, segment) => sum + segment.distanceMiles);
    final isComplete = record.state == TripState.completed || record.state == TripState.arrived;
    final statusColor = isComplete ? UtaColors.mint : record.isActive ? UtaColors.gold : UtaColors.sky;

    return UtaCard(
      highlight: record.isActive,
      onTap: onSelect,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 92,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
              gradient: LinearGradient(
                colors: record.isActive
                    ? const [Color(0xFF1C4B70), Color(0xFF102238)]
                    : const [Color(0xFF17324B), Color(0xFF0B1A2C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -12,
                  top: -24,
                  child: Icon(Icons.public_rounded, size: 130, color: Colors.white.withValues(alpha: 0.06)),
                ),
                Positioned(
                  left: 18,
                  top: 17,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: UtaColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: UtaColors.gold.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.route_rounded, color: UtaColors.gold),
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      record.isActive ? 'ACTIVE' : record.state.label.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.trip.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  '${record.trip.origin}  →  ${record.trip.destination}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: UtaColors.muted, height: 1.35),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 15, color: UtaColors.gold),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${record.trip.startDateLabel} — ${record.trip.endDateLabel}',
                        style: const TextStyle(color: UtaColors.muted, fontSize: 12),
                      ),
                    ),
                    Text(
                      miles <= 0 ? '${record.legs.length} leg${record.legs.length == 1 ? '' : 's'}' : '${miles.toStringAsFixed(0)} mi',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: isComplete ? 1 : record.state == TripState.active ? 0.08 : 0,
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(statusColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.chevron_right_rounded, color: UtaColors.muted),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
