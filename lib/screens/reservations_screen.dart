import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../widgets/reservation_card.dart';
import '../widgets/section_header.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            'Reservations & itinerary',
            subtitle: trip.reservations.isEmpty
                ? 'No plans have been added to this trip yet.'
                : 'Everything scheduled for ${trip.name}.',
          ),
          if (trip.reservations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  'Add reservations after creating the trip.',
                  style: TextStyle(color: Color(0xFFC8BDD6)),
                ),
              ),
            ),
          for (final reservation in trip.reservations)
            ReservationCard(reservation: reservation),
        ],
      ),
    );
  }
}
