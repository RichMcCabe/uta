import 'package:flutter/material.dart';

import '../models/route_segment.dart';
import '../models/speed_source.dart';
import '../models/trip.dart';
import '../models/trip_leg.dart';
import '../services/leg_builder_service.dart';
import '../services/osm_routing_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/direction_segment_card.dart';
import '../widgets/uta_card.dart';
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
  late List<RouteSegment> _segments;
  List<OsmRoutePlan> _routeOptions = const [];
  int _selectedRouteIndex = 0;
  RoutePreference _routePreference = RoutePreference.fastest;
  SpeedSource _selectedSpeedSource = SpeedSource.userOverride;
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
    final miles = _segments.fold<double>(0, (sum, item) => sum + item.distanceMiles);
    return Scaffold(
      appBar: AppBar(title: Text('Build: ${widget.leg.name}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const WarningBanner(
            title: 'Live leg routing',
            message:
                'Enter a start and destination, generate available OSRM routes, choose one, then save the leg. Interstate preference ranks the alternatives returned by the provider.',
          ),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _startController,
                  decoration: const InputDecoration(
                    labelText: 'Start point',
                    prefixIcon: Icon(Icons.trip_origin_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _endController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<RoutePreference>(
                  initialValue: _routePreference,
                  decoration: const InputDecoration(labelText: 'Route preference'),
                  items: [
                    for (final value in RoutePreference.values)
                      DropdownMenuItem(value: value, child: Text(value.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _routePreference = value);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isGenerating ? null : _generateRoutes,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.alt_route_rounded),
                    label: Text(_isGenerating ? 'Building routes…' : 'Generate routes'),
                  ),
                ),
              ],
            ),
          ),
          if (_routeOptions.isNotEmpty) ...[
            const SizedBox(height: 12),
            UtaCard(
              child: Column(
                children: [
                  for (var index = 0; index < _routeOptions.length; index++)
                    ListTile(
                      leading: Icon(
                        index == _selectedRouteIndex
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: index == _selectedRouteIndex
                            ? UtaColors.gold
                            : UtaColors.muted,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedRouteIndex = index;
                          _segments = [..._routeOptions[index].segments];
                        });
                      },
                      title: Text(index == 0
                          ? 'Recommended route'
                          : 'Alternative ${index + 1}'),
                      subtitle: Text(
                        '${_routeOptions[index].distanceMiles.toStringAsFixed(1)} mi • ${_duration(_routeOptions[index].duration)} • ${_routeOptions[index].averageRouteMph.toStringAsFixed(0)} mph estimated pace',
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          UtaCard(
            child: Row(
              children: [
                const Icon(Icons.route_rounded, color: UtaColors.gold),
                const SizedBox(width: 10),
                Text('${miles.toStringAsFixed(1)} miles',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const Spacer(),
                Text('${_segments.length} steps',
                    style: const TextStyle(color: UtaColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _instructionController,
                  decoration: const InputDecoration(labelText: 'Manual instruction'),
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
                        decoration: const InputDecoration(labelText: 'Planning mph'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<SpeedSource>(
                  initialValue: _selectedSpeedSource,
                  decoration: const InputDecoration(labelText: 'Speed source'),
                  items: [
                    for (final value in SpeedSource.values)
                      DropdownMenuItem(value: value, child: Text(value.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedSpeedSource = value);
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _addManualSegment,
                  icon: const Icon(Icons.add_road_rounded),
                  label: const Text('Add manual step'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var index = 0; index < _segments.length; index++)
            Dismissible(
              key: ValueKey(_segments[index].id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => setState(() => _segments.removeAt(index)),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 18),
                color: Colors.red.withValues(alpha: 0.2),
                child: const Icon(Icons.delete_rounded),
              ),
              child: DirectionSegmentCard(segment: _segments[index], index: index),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _segments.isEmpty ? null : _save,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Save leg'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateRoutes() async {
    final start = _startController.text.trim();
    final end = _endController.text.trim();
    if (start.length < 3 || end.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a start and destination first.')),
      );
      return;
    }
    setState(() => _isGenerating = true);
    try {
      final service = const OsmRoutingService();
      final origin = await service.geocode(start);
      final destination = await service.geocode(end);
      final driverName = widget.trip.profiles
          .where((profile) => profile.canDrive)
          .map((profile) => profile.name)
          .firstWhere((_) => true, orElse: () => '');
      final plans = await service.buildDrivingRoutes(
        origin: origin,
        destination: destination,
        assignedDriverName: driverName,
        preference: _routePreference,
      );
      if (!mounted) return;
      setState(() {
        _routeOptions = plans;
        _selectedRouteIndex = 0;
        _segments = [...plans.first.segments];
        _startController.text = origin.shortLabel;
        _endController.text = destination.shortLabel;
      });
    } on OsmRoutingException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _addManualSegment() {
    final instruction = _instructionController.text.trim();
    final miles = double.tryParse(_milesController.text.trim());
    final speed = int.tryParse(_speedController.text.trim());
    if (instruction.isEmpty || miles == null || speed == null) return;
    final driverName = widget.trip.profiles
        .where((profile) => profile.canDrive)
        .map((profile) => profile.name)
        .firstWhere((_) => true, orElse: () => '');
    final segment = const LegBuilderService()
        .makeManualSegment(
          instruction: instruction,
          miles: miles,
          speedLimitMph: speed,
          driverName: driverName,
        )
        .copyWith(speedSource: _selectedSpeedSource);
    setState(() {
      _segments.add(segment);
      _instructionController.clear();
      _milesController.clear();
    });
  }

  void _save() {
    widget.onSaveLeg(TripLeg(
      id: widget.leg.id,
      name: widget.leg.name,
      startLabel: _startController.text.trim(),
      endLabel: _endController.text.trim(),
      inputMode: LegInputMode.importedDirections,
      segments: _segments,
      note: widget.leg.note,
      isActive: widget.leg.isActive,
    ));
  }

  String _duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    return hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
  }
}
