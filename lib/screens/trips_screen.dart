import 'package:flutter/material.dart';

import '../models/saved_trip_record.dart';
import '../widgets/saved_trip_card.dart';
import '../widgets/section_header.dart';
import '../widgets/warning_banner.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({
    super.key,
    required this.records,
    required this.onSelectTrip,
    required this.onCloneActiveTrip,
  });

  final List<SavedTripRecord> records;
  final ValueChanged<String> onSelectTrip;
  final VoidCallback onCloneActiveTrip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          IconButton(
            onPressed: onCloneActiveTrip,
            icon: const Icon(Icons.copy_all_rounded),
            tooltip: 'Clone active trip',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WarningBanner(
            title: 'Trip Repository v1.0',
            message:
                'This is an in-memory repository. It creates the app structure for saved trips now; device storage comes next.',
          ),
          const SectionHeader(
            'Saved trips',
            subtitle: 'Select a trip to make it active. Clone creates a reusable starting point.',
          ),
          for (final record in records) ...[
            SavedTripCard(
              record: record,
              onSelect: () => onSelectTrip(record.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
