import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../models/trip_type.dart';
import '../services/trip_factory_service.dart';
import '../widgets/section_header.dart';
import '../widgets/trip_dashboard_card.dart';
import '../widgets/uta_card.dart';
import '../widgets/warning_banner.dart';

class TripWizardScreen extends StatefulWidget {
  const TripWizardScreen({
    super.key,
    required this.currentTrip,
    required this.onTripCreated,
  });

  final Trip currentTrip;
  final ValueChanged<Trip> onTripCreated;

  @override
  State<TripWizardScreen> createState() => _TripWizardScreenState();
}

class _TripWizardScreenState extends State<TripWizardScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _originController;
  late final TextEditingController _destinationController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _departureController;
  late final TextEditingController _targetArrivalController;
  late final TextEditingController _bufferController;

  TripType _tripType = TripType.roadTrip;
  Trip? _previewTrip;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentTrip.name);
    _originController = TextEditingController(text: widget.currentTrip.origin);
    _destinationController = TextEditingController(text: widget.currentTrip.destination);
    _startDateController = TextEditingController(text: widget.currentTrip.startDateLabel == 'Not set' ? '' : widget.currentTrip.startDateLabel);
    _endDateController = TextEditingController(text: widget.currentTrip.endDateLabel == 'Not set' ? '' : widget.currentTrip.endDateLabel);
    _departureController = TextEditingController(text: widget.currentTrip.departureLabel);
    _targetArrivalController = TextEditingController(text: widget.currentTrip.targetArrivalLabel);
    _bufferController = TextEditingController(text: widget.currentTrip.arrivalBufferMinutes.toString());
    _tripType = widget.currentTrip.tripType;
    _previewTrip = widget.currentTrip;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _departureController.dispose();
    _targetArrivalController.dispose();
    _bufferController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewTrip ?? widget.currentTrip;

    return Scaffold(
      appBar: AppBar(title: const Text('New Trip')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const WarningBanner(
            title: 'Trip creation v0.9',
            message: 'This creates an in-memory trip for the current session. Storage comes next, but the app is no longer limited to the hardcoded Orlando labels.',
          ),
          const SectionHeader('Trip basics'),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Trip name',
                    hintText: 'Example: Orlando Family Vacation',
                    prefixIcon: Icon(Icons.card_travel_rounded),
                  ),
                  onChanged: (_) => _refreshPreview(),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<TripType>(
                  initialValue: _tripType,
                  decoration: const InputDecoration(
                    labelText: 'Trip type',
                    prefixIcon: Icon(Icons.travel_explore_rounded),
                  ),
                  items: [
                    for (final type in TripType.values)
                      DropdownMenuItem(value: type, child: Text(type.label)),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _tripType = value);
                    _refreshPreview();
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startDateController,
                        decoration: const InputDecoration(labelText: 'Start date'),
                        onChanged: (_) => _refreshPreview(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _endDateController,
                        decoration: const InputDecoration(labelText: 'End date'),
                        onChanged: (_) => _refreshPreview(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SectionHeader('Journey target'),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _originController,
                  decoration: const InputDecoration(
                    labelText: 'Start location',
                    hintText: 'Address, hotel, current location, or map pin later',
                    prefixIcon: Icon(Icons.trip_origin_rounded),
                  ),
                  onChanged: (_) => _refreshPreview(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'Address, hotel, attraction, or map pin later',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                  onChanged: (_) => _refreshPreview(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _departureController,
                        decoration: const InputDecoration(labelText: 'Departure'),
                        onChanged: (_) => _refreshPreview(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _targetArrivalController,
                        decoration: const InputDecoration(labelText: 'Target arrival'),
                        onChanged: (_) => _refreshPreview(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bufferController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Desired arrival buffer minutes',
                    helperText: 'Example: arrive 30 minutes before a reservation.',
                  ),
                  onChanged: (_) => _refreshPreview(),
                ),
              ],
            ),
          ),
          const SectionHeader('Preview'),
          TripDashboardCard(trip: preview),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saveTrip,
            icon: const Icon(Icons.save_rounded),
            label: const Text('Create / Update Current Trip'),
          ),
        ],
      ),
    );
  }

  void _refreshPreview() {
    setState(() {
      _previewTrip = _buildTrip();
    });
  }

  void _saveTrip() {
    final trip = _buildTrip();
    widget.onTripCreated(trip);
    setState(() => _previewTrip = trip);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current trip updated')),
    );
  }

  Trip _buildTrip() {
    final buffer = int.tryParse(_bufferController.text.trim()) ?? 30;

    return const TripFactoryService().buildTrip(
      name: _nameController.text,
      origin: _originController.text,
      destination: _destinationController.text,
      tripType: _tripType,
      startDateLabel: _startDateController.text,
      endDateLabel: _endDateController.text,
      departureLabel: _departureController.text,
      targetArrivalLabel: _targetArrivalController.text,
      arrivalBufferMinutes: buffer,
    );
  }
}
