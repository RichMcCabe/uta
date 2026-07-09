import 'package:flutter/material.dart';

import '../models/saved_trip_record.dart';
import '../models/trip_type.dart';
import '../theme/uta_theme.dart';
import 'uta_card.dart';
import 'uta_travel_sign.dart';
import '../models/trip_state.dart';

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
    return UtaCard(
      highlight: record.isActive,
      onTap: onSelect,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.trip.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              if (record.isActive)
                const UtaTravelSign(
                  kind: UtaSignKind.passport,
                  label: 'ACTIVE',
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${record.trip.origin} → ${record.trip.destination}',
            style: const TextStyle(color: UtaColors.muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              UtaTravelSign(
                kind: UtaSignKind.road,
                label: record.trip.tripType.label.toUpperCase(),
                compact: true,
              ),
              UtaTravelSign(
                kind: UtaSignKind.ticket,
                label: record.state.label.toUpperCase(),
                compact: true,
              ),
              UtaTravelSign(
                kind: UtaSignKind.fuel,
                label: '${record.legs.length} LEG${record.legs.length == 1 ? '' : 'S'}',
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
