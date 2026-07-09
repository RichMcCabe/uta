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
          const SectionHeader('Reservations & itinerary', subtitle: 'Optional module. Enabled for Orlando v1.'),
          for (final reservation in trip.reservations) ReservationCard(reservation: reservation),
        ],
      ),
    );
  }
}
