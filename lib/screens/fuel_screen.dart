import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../services/fuel_calculator.dart';
import '../theme/uta_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/status_tile.dart';
import '../widgets/uta_card.dart';

class FuelScreen extends StatelessWidget {
  const FuelScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final calculator = const FuelCalculator();
    final totalGallons = calculator.totalGallons(trip.fuelEntries);
    final totalCost = calculator.totalCost(trip.fuelEntries);

    return Scaffold(
      appBar: AppBar(title: const Text('Fuel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Fuel & economy', subtitle: 'Optional tracking for gallons, cost, MPG, and segment stats.'),
          Row(
            children: [
              Expanded(child: StatusTile(label: 'Gallons', value: totalGallons.toStringAsFixed(1), icon: Icons.local_gas_station)),
              const SizedBox(width: 10),
              Expanded(child: StatusTile(label: 'Fuel cost', value: '\$${totalCost.toStringAsFixed(2)}', icon: Icons.attach_money, color: UtaColors.green)),
            ],
          ),
          const SizedBox(height: 14),
          const UtaCard(
            child: Text(
              'Next build: add fuel entries with location, gallons, price/gallon, odometer, fuel remaining, and notes. UTA will calculate MPG, trip fuel cost, and cost per mile.',
              style: TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
