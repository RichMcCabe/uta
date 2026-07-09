import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../theme/uta_theme.dart';
import 'uta_card.dart';
import 'uta_travel_sign.dart';
import '../models/trip_type.dart';

class TripDashboardCard extends StatelessWidget {
  const TripDashboardCard({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            '${trip.origin} → ${trip.destination}',
            style: const TextStyle(color: UtaColors.muted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              UtaTravelSign(kind: UtaSignKind.road, label: trip.tripType.label.toUpperCase(), compact: true),
              UtaTravelSign(kind: UtaSignKind.ticket, label: 'TARGET ${trip.targetArrivalLabel}', compact: true),
              UtaTravelSign(kind: UtaSignKind.warning, label: '${trip.arrivalBufferMinutes}M BUFFER', compact: true),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _MiniField(label: 'Start', value: trip.startDateLabel)),
              const SizedBox(width: 10),
              Expanded(child: _MiniField(label: 'End', value: trip.endDateLabel)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  const _MiniField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UtaColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: UtaText.label),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
