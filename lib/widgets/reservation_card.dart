import 'package:flutter/material.dart';

import '../models/reservation.dart';
import '../theme/uta_theme.dart';

class ReservationCard extends StatelessWidget {
  const ReservationCard({super.key, required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UtaColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: UtaColors.sunset.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.confirmation_number, color: UtaColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(reservation.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 4),
              Text('${reservation.timeLabel} • ${reservation.location}', style: const TextStyle(color: UtaColors.muted)),
              const SizedBox(height: 4),
              Text(reservation.note, style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ],
      ),
    );
  }
}
