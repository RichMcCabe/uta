import 'package:flutter/material.dart';

import '../theme/uta_theme.dart';

class TripToolsScreen extends StatelessWidget {
  const TripToolsScreen({
    super.key,
    required this.onOpenRoute,
    required this.onOpenDirections,
    required this.onOpenTimeline,
    required this.onOpenLegs,
    required this.onOpenLegBuilder,
    required this.onOpenPlans,
    required this.onOpenVault,
    required this.onOpenFuel,
  });

  final VoidCallback onOpenRoute;
  final VoidCallback onOpenDirections;
  final VoidCallback onOpenTimeline;
  final VoidCallback onOpenLegs;
  final VoidCallback onOpenLegBuilder;
  final VoidCallback onOpenPlans;
  final VoidCallback onOpenVault;
  final VoidCallback onOpenFuel;

  @override
  Widget build(BuildContext context) {
    final tools = [
      _Tool('Route', 'Checkpoints and progress', Icons.route_rounded, onOpenRoute),
      _Tool('Directions', 'Every maneuver and ETA', Icons.list_alt_rounded, onOpenDirections),
      _Tool('Timeline', 'Journey pace and events', Icons.timeline_rounded, onOpenTimeline),
      _Tool('Legs', 'Multi-leg journeys', Icons.alt_route_rounded, onOpenLegs),
      _Tool('Build route', 'Edit a journey leg', Icons.edit_road_rounded, onOpenLegBuilder),
      _Tool('Plans', 'Reservations and itinerary', Icons.event_note_rounded, onOpenPlans),
      _Tool('Vault', 'Travel documents', Icons.folder_special_rounded, onOpenVault),
      _Tool('Fuel', 'Fuel and trip economy', Icons.local_gas_station_rounded, onOpenFuel),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Trip tools')),
      body: GridView.builder(
        padding: const EdgeInsets.all(18),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) => _ToolCard(tool: tools[index]),
      ),
    );
  }
}

class _Tool {
  const _Tool(this.title, this.detail, this.icon, this.onTap);

  final String title;
  final String detail;
  final IconData icon;
  final VoidCallback onTap;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});

  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: UtaColors.card,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: tool.onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: UtaColors.cardSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tool.icon, color: UtaColors.gold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(tool.detail, style: const TextStyle(color: UtaColors.muted, height: 1.25)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
