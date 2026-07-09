import 'package:flutter/material.dart';

import '../models/eta_confidence.dart';
import '../models/route_segment.dart';
import '../models/speed_source.dart';
import '../models/routing_result.dart';
import '../models/trip.dart';
import '../models/trip_leg.dart';
import '../services/demo_routing_provider.dart';
import '../services/eta_confidence_service.dart';
import '../services/leg_builder_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/direction_segment_card.dart';
import '../widgets/section_header.dart';
import '../widgets/status_tile.dart';
import '../widgets/uta_card.dart';
import '../widgets/uta_travel_sign.dart';
import '../widgets/warning_banner.dart';

class LegBuilderScreen extends StatefulWidget {
  const LegBuilderScreen({
    super.key,
    required this.trip,
    required this.leg,
    required this.onSaveLeg,
  });

  final Trip trip;
  final TripLeg leg;
  final ValueChanged<TripLeg> onSaveLeg;

  @override
  State<LegBuilderScreen> createState() => _LegBuilderScreenState();
}

class _LegBuilderScreenState extends State<LegBuilderScreen> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _instructionController;
  late final TextEditingController _milesController;
  late final TextEditingController _speedController;

  SpeedSource _selectedSpeedSource = SpeedSource.userOverride;
  late List<RouteSegment> _segments;
  RoutingResult? _lastRoutingResult;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(text: widget.leg.startLabel);
    _endController = TextEditingController(text: widget.leg.endLabel);
    _instructionController = TextEditingController();
    _milesController = TextEditingController();
    _speedController = TextEditingController(text: '65');
    _segments = [...widget.leg.segments];
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _instructionController.dispose();
    _milesController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draftLeg = _draftLeg();
    final plannedMinutes =
        const LegBuilderService().plannedMinutesForLeg(widget.trip, draftLeg);
    final confidence = const EtaConfidenceService().confidenceForLeg(draftLeg);
    final confidenceDetail = const EtaConfidenceService().confidenceDetail(draftLeg);

    return Scaffold(
      appBar: AppBar(title: Text('Build: ${widget.leg.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WarningBanner(
            title: 'Routing strategy',
            message:
                'UTA should provide suggested directions, then let the user override them. This build uses a demo/free-provider architecture so we can later swap in OpenStreetMap routing without changing the UI.',
          ),
          const SectionHeader('Start and end'),
          UtaCard(
            highlight: true,
            child: Column(
              children: [
                TextField(
                  controller: _startController,
                  decoration: const InputDecoration(
                    labelText: 'Start point',
                    hintText: 'Address, place, hotel, current location, or map pin later',
                    prefixIcon: Icon(Icons.trip_origin_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _endController,
                  decoration: const InputDecoration(
                    labelText: 'End point',
                    hintText: 'Address, place, hotel, attraction, or map pin later',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    UtaTravelSign(kind: UtaSignKind.road, label: 'SUGGESTED', compact: true),
                    UtaTravelSign(kind: UtaSignKind.passport, label: 'EDITABLE', compact: true),
                    UtaTravelSign(kind: UtaSignKind.warning, label: 'OSM READY', compact: true),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader('Generate directions'),
          UtaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suggested directions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'For now this uses UTA demo route data. Later this button can call OSRM, Valhalla, GraphHopper, or another OpenStreetMap-based routing provider.',
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<SpeedSource>(
                  initialValue: _selectedSpeedSource,
                  decoration: const InputDecoration(
                    labelText: 'Speed source',
                    helperText: 'UTA should be honest about speed limit assumptions.',
                  ),
                  items: [
                    for (final source in SpeedSource.values)
                      DropdownMenuItem(
                        value: source,
                        child: Text(source.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedSpeedSource = value);
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _isGenerating ? null : _generateSuggestedRoute,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate suggested directions'),
                ),
                if (_lastRoutingResult != null) ...[
                  const SizedBox(height: 12),
                  WarningBanner(
                    title: _lastRoutingResult!.providerType.label,
                    message: [
                      _lastRoutingResult!.summary,
                      if (_lastRoutingResult!.warning != null) _lastRoutingResult!.warning!,
                    ].join('\n\n'),
                  ),
                ],
              ],
            ),
          ),
          const SectionHeader('Leg summary'),
          Row(
            children: [
              Expanded(
                child: StatusTile(
                  label: 'Miles',
                  value: draftLeg.totalMiles.toStringAsFixed(1),
                  icon: Icons.route_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatusTile(
                  label: 'Planned',
                  value: _formatMinutes(plannedMinutes),
                  icon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StatusTile(
            label: 'ETA confidence',
            value: '${confidence.shortLabel} • $confidenceDetail',
            icon: Icons.verified_rounded,
            color: _confidenceColor(confidence),
          ),
          const SectionHeader('Add direction segment'),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _instructionController,
                  decoration: const InputDecoration(
                    labelText: 'Instruction',
                    hintText: 'Example: Take I-95 S toward Savannah',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _milesController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Miles'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _speedController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Posted mph'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<SpeedSource>(
                  initialValue: _selectedSpeedSource,
                  decoration: const InputDecoration(
                    labelText: 'Speed source',
                    helperText: 'UTA should be honest about speed limit assumptions.',
                  ),
                  items: [
                    for (final source in SpeedSource.values)
                      DropdownMenuItem(
                        value: source,
                        child: Text(source.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedSpeedSource = value);
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _addSegment,
                  icon: const Icon(Icons.add_road_rounded),
                  label: const Text('Add segment'),
                ),
              ],
            ),
          ),
          const SectionHeader(
            'Directions',
            subtitle: 'Swipe a row left to delete it. Future map-drag edits will update this same segment list.',
          ),
          for (var i = 0; i < _segments.length; i++)
            Dismissible(
              key: ValueKey(_segments[i].id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => setState(() => _segments.removeAt(i)),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 18),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.delete_rounded),
              ),
              child: DirectionSegmentCard(segment: _segments[i], index: i),
            ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => widget.onSaveLeg(_draftLeg()),
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save leg'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSuggestedRoute() async {
    setState(() => _isGenerating = true);

    final result = await const DemoRoutingProvider().buildRoute(
      trip: widget.trip,
      startLabel: _startController.text.trim(),
      endLabel: _endController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _segments = [...result.segments];
      _lastRoutingResult = result;
      _isGenerating = false;
    });
  }

  void _addSegment() {
    final instruction = _instructionController.text.trim();
    final miles = double.tryParse(_milesController.text.trim());
    final speed = int.tryParse(_speedController.text.trim());

    if (instruction.isEmpty || miles == null || speed == null) return;

    final segment = const LegBuilderService().makeManualSegment(
      instruction: instruction,
      miles: miles,
      speedLimitMph: speed,
      driverName: widget.trip.profiles.first.name,
    ).copyWith(speedSource: _selectedSpeedSource);

    setState(() {
      _segments.add(segment);
      _instructionController.clear();
      _milesController.clear();
    });
  }

  TripLeg _draftLeg() {
    return TripLeg(
      id: widget.leg.id,
      name: widget.leg.name,
      startLabel: _startController.text.trim().isEmpty
          ? widget.leg.startLabel
          : _startController.text.trim(),
      endLabel: _endController.text.trim().isEmpty
          ? widget.leg.endLabel
          : _endController.text.trim(),
      inputMode: LegInputMode.manualDirections,
      segments: _segments,
      note: widget.leg.note,
    );
  }

  Color _confidenceColor(EtaConfidence confidence) {
    switch (confidence) {
      case EtaConfidence.high:
        return UtaColors.mint;
      case EtaConfidence.medium:
        return UtaColors.gold;
      case EtaConfidence.low:
        return UtaColors.coral;
    }
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
