import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../models/trip_leg.dart';
import '../services/leg_builder_service.dart';
import '../widgets/leg_summary_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_tile.dart';
import '../widgets/uta_card.dart';
import '../widgets/warning_banner.dart';

class LegsScreen extends StatefulWidget {
  const LegsScreen({
    super.key,
    required this.trip,
    required this.legs,
    required this.activeLeg,
    required this.onSelectLeg,
    required this.onAddLeg,
    required this.onCloneLeg,
    required this.onDeleteLeg,
  });

  final Trip trip;
  final List<TripLeg> legs;
  final TripLeg activeLeg;
  final ValueChanged<String> onSelectLeg;
  final ValueChanged<TripLeg> onAddLeg;
  final ValueChanged<String> onCloneLeg;
  final ValueChanged<String> onDeleteLeg;

  @override
  State<LegsScreen> createState() => _LegsScreenState();
}

class _LegsScreenState extends State<LegsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _startController = TextEditingController(text: widget.activeLeg.endLabel);
    _endController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant LegsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeLeg.id != widget.activeLeg.id && _startController.text.trim().isEmpty) {
      _startController.text = widget.activeLeg.endLabel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMiles = widget.legs.fold<double>(0, (sum, leg) => sum + leg.totalMiles);
    final totalSegments = widget.legs.fold<int>(0, (sum, leg) => sum + leg.checkpointCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Legs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WarningBanner(
            title: 'Multi-leg trips',
            message:
                'Use legs for hotel stays, day trips, returns, park-to-restaurant hops, airport transfers, and anything else that punctuates the journey.',
          ),
          Row(
            children: [
              Expanded(
                child: StatusTile(
                  label: 'Legs',
                  value: '${widget.legs.length}',
                  icon: Icons.alt_route_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatusTile(
                  label: 'Total miles',
                  value: totalMiles.toStringAsFixed(1),
                  icon: Icons.route_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StatusTile(
            label: 'Route segments',
            value: '$totalSegments across all legs',
            icon: Icons.format_list_bulleted_rounded,
          ),
          const SectionHeader('Add leg'),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Leg name',
                    hintText: 'Example: Hotel to Universal',
                    prefixIcon: Icon(Icons.label_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _startController,
                  decoration: const InputDecoration(
                    labelText: 'Start',
                    prefixIcon: Icon(Icons.trip_origin_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _endController,
                  decoration: const InputDecoration(
                    labelText: 'End',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _addLeg,
                  icon: const Icon(Icons.add_road_rounded),
                  label: const Text('Add leg'),
                ),
              ],
            ),
          ),
          const SectionHeader(
            'Legs',
            subtitle: 'Tap a leg to make it active. Build tab edits the active leg.',
          ),
          for (final leg in widget.legs) ...[
            LegSummaryCard(
              leg: leg,
              onSelect: () => widget.onSelectLeg(leg.id),
              onClone: () => widget.onCloneLeg(leg.id),
              onDelete: () => widget.onDeleteLeg(leg.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  void _addLeg() {
    final leg = const LegBuilderService().buildBlankLeg(
      startLabel: _startController.text,
      endLabel: _endController.text,
      name: _nameController.text,
    );

    widget.onAddLeg(leg);
    _nameController.clear();
    _startController.text = leg.endLabel;
    _endController.clear();
  }
}
