import 'dart:async';

import 'package:flutter/material.dart';

import '../models/tracked_location.dart';
import '../models/trip.dart';
import '../models/trip_type.dart';
import '../services/osm_routing_service.dart';
import '../services/trip_factory_service.dart';
import '../services/trip_storage_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/uta_card.dart';

class TripWizardScreen extends StatefulWidget {
  const TripWizardScreen({
    super.key,
    required this.currentTrip,
    required this.onTripCreated,
    required this.onUseCurrentLocation,
  });

  final Trip currentTrip;
  final ValueChanged<Trip> onTripCreated;
  final Future<TrackedLocation?> Function() onUseCurrentLocation;

  @override
  State<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends State<TripWizardScreen> {
  final OsmRoutingService _routingService = const OsmRoutingService();
  final TripStorageService _storageService = const TripStorageService();
  late final TextEditingController _nameController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _departureController;
  late final TextEditingController _targetArrivalController;
  late final TextEditingController _bufferController;

  GeocodedPlace? _origin;
  GeocodedPlace? _destination;
  List<OsmRoutePlan> _routeOptions = const [];
  int _selectedRouteIndex = 0;
  RoutePreference _routePreference = RoutePreference.fastest;

  OsmRoutePlan? get _routePreview =>
      _routeOptions.isEmpty ? null : _routeOptions[_selectedRouteIndex];
  TripType _tripType = TripType.roadTrip;
  bool _isCreating = false;
  bool _isPreviewing = false;
  bool _isLocating = false;
  List<GeocodedPlace> _recentPlaces = const [];

  @override
  void initState() {
    super.initState();
    final isStarter = widget.currentTrip.origin == 'Choose a start';
    _nameController = TextEditingController(text: isStarter ? '' : widget.currentTrip.name);
    _startDateController = TextEditingController(text: widget.currentTrip.startDateLabel == 'Not set' ? '' : widget.currentTrip.startDateLabel);
    _endDateController = TextEditingController(text: widget.currentTrip.endDateLabel == 'Not set' ? '' : widget.currentTrip.endDateLabel);
    _departureController = TextEditingController(text: widget.currentTrip.departureLabel == 'Not set' ? '' : widget.currentTrip.departureLabel);
    _targetArrivalController = TextEditingController(text: widget.currentTrip.targetArrivalLabel == 'Not set' ? '' : widget.currentTrip.targetArrivalLabel);
    _bufferController = TextEditingController(text: widget.currentTrip.arrivalBufferMinutes.toString());
    _tripType = widget.currentTrip.tripType;
    _loadRecentPlaces();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _departureController.dispose();
    _targetArrivalController.dispose();
    _bufferController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan a trip')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
        children: [
          Text('Build your route', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text(
            'Search and select both locations. UTA will then build the route and save the turn-by-turn directions.',
            style: TextStyle(color: UtaColors.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          UtaCard(
            child: Column(
              children: [
                _PlaceSearchField(
                  label: 'Start location',
                  hint: 'Address, city, hotel or landmark',
                  icon: Icons.trip_origin_rounded,
                  routingService: _routingService,
                  selectedPlace: _origin,
                  recentPlaces: _recentPlaces,
                  onSelected: (place) => setState(() {
                    _origin = place;
                    _routeOptions = const [];
                    _selectedRouteIndex = 0;
                  }),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _isLocating ? null : _useCurrentLocation,
                    icon: _isLocating
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.my_location_rounded),
                    label: Text(_isLocating ? 'Finding your location…' : 'Use my current location'),
                  ),
                ),
                const SizedBox(height: 4),
                _PlaceSearchField(
                  label: 'Destination',
                  hint: 'Where are you going?',
                  icon: Icons.location_on_rounded,
                  routingService: _routingService,
                  selectedPlace: _destination,
                  recentPlaces: _recentPlaces,
                  onSelected: (place) => setState(() {
                    _destination = place;
                    _routeOptions = const [];
                    _selectedRouteIndex = 0;
                  }),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isPreviewing || _origin == null || _destination == null ? null : _previewRoute,
                    icon: _isPreviewing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.alt_route_rounded),
                    label: Text(_isPreviewing ? 'Building route…' : 'Preview route and directions'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RoutePreference>(
            initialValue: _routePreference,
            decoration: const InputDecoration(
              labelText: 'Route preference',
              prefixIcon: Icon(Icons.signpost_rounded),
              helperText: 'Interstate preference ranks available OSRM alternatives; it cannot force roads that the provider does not return.',
            ),
            items: [
              for (final value in RoutePreference.values)
                DropdownMenuItem(value: value, child: Text(value.label)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _routePreference = value;
                _routeOptions = const [];
                _selectedRouteIndex = 0;
              });
            },
          ),
          if (_routeOptions.isNotEmpty) ...[
            const SizedBox(height: 14),
            _RouteOptionsCard(
              plans: _routeOptions,
              selectedIndex: _selectedRouteIndex,
              onSelected: (index) => setState(() => _selectedRouteIndex = index),
            ),
          ],
          const SizedBox(height: 14),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Trip name',
                    hintText: 'Optional — UTA can name it for you',
                    prefixIcon: Icon(Icons.luggage_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TripType>(
                  initialValue: _tripType,
                  decoration: const InputDecoration(labelText: 'Trip type', prefixIcon: Icon(Icons.travel_explore_rounded)),
                  items: [for (final type in TripType.values) DropdownMenuItem(value: type, child: Text(type.label))],
                  onChanged: (value) {
                    if (value != null) setState(() => _tripType = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          UtaCard(
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: _dateField(_startDateController, 'Start date', true)),
                  const SizedBox(width: 10),
                  Expanded(child: _dateField(_endDateController, 'End date', false)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _timeField(_departureController, 'Departure', true)),
                  const SizedBox(width: 10),
                  Expanded(child: _timeField(_targetArrivalController, 'Target arrival', false)),
                ]),
                const SizedBox(height: 12),
                TextField(
                  controller: _bufferController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Arrival buffer (minutes)', prefixIcon: Icon(Icons.timer_outlined)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isCreating || _routePreview == null ? null : _saveTrip,
              icon: _isCreating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.navigation_rounded),
              label: Text(_isCreating ? 'Saving trip…' : 'Save trip with directions'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Directions use OpenStreetMap and OSRM. Alternative availability depends on the routing provider; live traffic and verified posted speed limits are not included.',
            textAlign: TextAlign.center,
            style: TextStyle(color: UtaColors.muted, fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _dateField(TextEditingController controller, String label, bool showIcon) => TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(controller),
        decoration: InputDecoration(labelText: label, prefixIcon: showIcon ? const Icon(Icons.calendar_today_rounded) : null),
      );

  Widget _timeField(TextEditingController controller, String label, bool showIcon) => TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickTime(controller),
        decoration: InputDecoration(labelText: label, prefixIcon: showIcon ? const Icon(Icons.schedule_rounded) : null),
      );


  Future<void> _loadRecentPlaces() async {
    final places = await _storageService.loadRecentPlaces();
    if (mounted) setState(() => _recentPlaces = places);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final location = await widget.onUseCurrentLocation();
      if (!mounted) return;
      if (location == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UTA could not access your location. Check Location Services and permissions.')));
        return;
      }
      setState(() {
        _origin = GeocodedPlace(
          displayName: 'Current location',
          latitude: location.latitude,
          longitude: location.longitude,
          typeLabel: 'Live GPS position',
        );
        _routeOptions = const [];
        _selectedRouteIndex = 0;
      });
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _previewRoute() async {
    final origin = _origin;
    final destination = _destination;
    if (origin == null || destination == null) return;
    setState(() => _isPreviewing = true);
    try {
      final plans = await _routingService.buildDrivingRoutes(
        origin: origin,
        destination: destination,
        preference: _routePreference,
      );
      if (mounted) {
        setState(() {
          _routeOptions = plans;
          _selectedRouteIndex = 0;
        });
      }
    } on OsmRoutingException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isPreviewing = false);
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final date = await showDatePicker(context: context, firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 10), initialDate: now);
    if (date != null) controller.text = '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null && mounted) controller.text = time.format(context);
  }

  Future<void> _saveTrip() async {
    final origin = _origin;
    final destination = _destination;
    if (origin == null || destination == null || _routePreview == null) return;
    setState(() => _isCreating = true);
    try {
      final trip = await const TripFactoryService().buildTripWithRoute(
        name: _nameController.text,
        origin: origin,
        destination: destination,
        tripType: _tripType,
        startDateLabel: _startDateController.text,
        endDateLabel: _endDateController.text,
        departureLabel: _departureController.text,
        targetArrivalLabel: _targetArrivalController.text,
        arrivalBufferMinutes: int.tryParse(_bufferController.text.trim()) ?? 30,
        selectedPlan: _routePreview,
      );
      await _storageService.rememberPlaces([origin, destination]);
      if (mounted) widget.onTripCreated(trip);
    } on OsmRoutingException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }
}

class _PlaceSearchField extends StatefulWidget {
  const _PlaceSearchField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.routingService,
    required this.selectedPlace,
    required this.recentPlaces,
    required this.onSelected,
  });

  final String label;
  final String hint;
  final IconData icon;
  final OsmRoutingService routingService;
  final GeocodedPlace? selectedPlace;
  final List<GeocodedPlace> recentPlaces;
  final ValueChanged<GeocodedPlace> onSelected;

  @override
  State<_PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<_PlaceSearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;
  List<GeocodedPlace> _results = const [];
  bool _searching = false;
  String? _error;
  int _requestToken = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedPlace?.displayName ?? '');
  }

  @override
  void didUpdateWidget(covariant _PlaceSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlace != oldWidget.selectedPlace && widget.selectedPlace != null) {
      _controller.text = widget.selectedPlace!.displayName;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _error = null;
    if (value.trim().length < 3) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(value));
  }

  Future<void> _search(String query) async {
    final token = ++_requestToken;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final results = await widget.routingService.searchPlaces(query);
      if (!mounted || token != _requestToken) return;
      setState(() => _results = results);
    } on OsmRoutingException catch (error) {
      if (!mounted || token != _requestToken) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted && token == _requestToken) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon),
            suffixIcon: _searching
                ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2))
                : widget.selectedPlace != null
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
          ),
        ),
        if (_error != null) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Align(alignment: Alignment.centerLeft, child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
        ),
        if (!_searching && _controller.text.trim().length >= 3 && _results.isEmpty && _error == null)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Align(alignment: Alignment.centerLeft, child: Text('No matching locations yet.', style: TextStyle(color: UtaColors.muted, fontSize: 12))),
          ),
        if (_results.isEmpty && !_searching && _controller.text.trim().isEmpty && widget.recentPlaces.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 10, 14, 4),
                  child: Text('Recent destinations', style: TextStyle(color: UtaColors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                for (final place in widget.recentPlaces.take(4))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_rounded),
                    title: Text(place.shortLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(place.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      _controller.text = place.displayName;
                      FocusScope.of(context).unfocus();
                      widget.onSelected(place);
                    },
                  ),
              ],
            ),
          ),
        if (_results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _results.length; i++) ...[
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(_results[i].shortLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(_results[i].displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Text(_results[i].typeLabel ?? 'Place', style: const TextStyle(color: UtaColors.muted, fontSize: 11)),
                    onTap: () {
                      final selected = _results[i];
                      _controller.text = selected.displayName;
                      FocusScope.of(context).unfocus();
                      setState(() => _results = const []);
                      widget.onSelected(selected);
                    },
                  ),
                  if (i != _results.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _RouteOptionsCard extends StatelessWidget {
  const _RouteOptionsCard({
    required this.plans,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<OsmRoutePlan> plans;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plans.length == 1 ? 'Route ready' : 'Choose your route',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < plans.length; index++) ...[
            _RouteChoiceTile(
              plan: plans[index],
              index: index,
              selected: index == selectedIndex,
              onTap: () => onSelected(index),
            ),
            if (index != plans.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _RouteChoiceTile extends StatelessWidget {
  const _RouteChoiceTile({
    required this.plan,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final OsmRoutePlan plan;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hours = plan.duration.inHours;
    final minutes = plan.duration.inMinutes.remainder(60);
    final duration = hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
    return Material(
      color: selected
          ? UtaColors.gold.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? UtaColors.gold : UtaColors.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      index == 0 ? 'Recommended route' : 'Alternative ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${plan.distanceMiles.toStringAsFixed(1)} mi • $duration • ${plan.segments.length} steps',
                      style: const TextStyle(color: UtaColors.muted),
                    ),
                    Text(
                      'Estimated route pace ${plan.averageRouteMph.toStringAsFixed(0)} mph',
                      style: const TextStyle(color: UtaColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
