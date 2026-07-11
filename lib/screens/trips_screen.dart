import 'package:flutter/material.dart';

import '../models/saved_trip_record.dart';
import '../theme/uta_theme.dart';
import '../widgets/saved_trip_card.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({
    super.key,
    required this.records,
    required this.onSelectTrip,
    required this.onCloneActiveTrip,
    required this.onCreateTrip,
  });

  final List<SavedTripRecord> records;
  final ValueChanged<String> onSelectTrip;
  final VoidCallback onCloneActiveTrip;
  final VoidCallback onCreateTrip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          IconButton.filled(
            onPressed: onCreateTrip,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create trip',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF071629), UtaColors.night],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
          children: [
            Text(
              'Every journey. One place.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a trip to bring it into Mission Control, or create the next adventure.',
              style: TextStyle(color: UtaColors.muted, height: 1.45),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCreateTrip,
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Plan a new trip'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('SAVED TRIPS', style: UtaText.label.copyWith(color: UtaColors.gold)),
                const Spacer(),
                Text('${records.length}', style: const TextStyle(color: UtaColors.muted, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 12),
            for (final record in records) ...[
              SavedTripCard(
                record: record,
                onSelect: () => onSelectTrip(record.id),
              ),
              const SizedBox(height: 14),
            ],
            if (records.isNotEmpty)
              OutlinedButton.icon(
                onPressed: onCloneActiveTrip,
                icon: const Icon(Icons.copy_all_rounded),
                label: const Text('Duplicate active trip'),
              ),
          ],
        ),
      ),
    );
  }
}
