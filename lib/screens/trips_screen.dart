import 'package:flutter/material.dart';

import '../models/saved_trip_record.dart';
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
          IconButton(
            onPressed: onCreateTrip,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create trip',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Text(
            'Your journeys',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a journey to make it active, or create a new one from anywhere in the world.',
            style: TextStyle(color: Color(0xFFC8BDD6), height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreateTrip,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Create a new trip'),
            ),
          ),
          const SizedBox(height: 20),
          for (final record in records) ...[
            SavedTripCard(
              record: record,
              onSelect: () => onSelectTrip(record.id),
            ),
            const SizedBox(height: 12),
          ],
          if (records.isNotEmpty)
            TextButton.icon(
              onPressed: onCloneActiveTrip,
              icon: const Icon(Icons.copy_all_rounded),
              label: const Text('Duplicate active trip'),
            ),
        ],
      ),
    );
  }
}
