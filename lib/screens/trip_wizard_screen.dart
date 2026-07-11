import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../models/trip_type.dart';
import '../services/trip_factory_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/uta_card.dart';

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

  @override
  void initState() {
    super.initState();
    final isStarter = widget.currentTrip.origin == 'Choose a start';
    _nameController = TextEditingController(
      text: isStarter ? '' : widget.currentTrip.name,
    );
    _originController = TextEditingController(
      text: isStarter ? '' : widget.currentTrip.origin,
    );
    _destinationController = TextEditingController(
      text: isStarter ? '' : widget.currentTrip.destination,
    );
    _startDateController = TextEditingController(
      text: widget.currentTrip.startDateLabel == 'Not set'
          ? ''
          : widget.currentTrip.startDateLabel,
    );
    _endDateController = TextEditingController(
      text: widget.currentTrip.endDateLabel == 'Not set'
          ? ''
          : widget.currentTrip.endDateLabel,
    );
    _departureController = TextEditingController(
      text: widget.currentTrip.departureLabel == 'Not set'
          ? ''
          : widget.currentTrip.departureLabel,
    );
    _targetArrivalController = TextEditingController(
      text: widget.currentTrip.targetArrivalLabel == 'Not set'
          ? ''
          : widget.currentTrip.targetArrivalLabel,
    );
    _bufferController = TextEditingController(
      text: widget.currentTrip.arrivalBufferMinutes.toString(),
    );
    _tripType = widget.currentTrip.tripType;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Plan a trip')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          Text(
            'Where are you going?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start with the journey basics. Route, reservations, fuel and documents can be added afterward.',
            style: TextStyle(color: UtaColors.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _originController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Start location',
                    hintText: 'City, address, hotel or landmark',
                    prefixIcon: Icon(Icons.trip_origin_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _destinationController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    hintText: 'Anywhere in the world',
                    prefixIcon: Icon(Icons.location_on_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          UtaCard(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Trip name',
                    hintText: 'Example: Scotland Golf Trip',
                    prefixIcon: Icon(Icons.luggage_rounded),
                  ),
                ),
                const SizedBox(height: 12),
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
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          UtaCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startDateController,
                        readOnly: true,
                        onTap: () => _pickDate(_startDateController),
                        decoration: const InputDecoration(
                          labelText: 'Start date',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _endDateController,
                        readOnly: true,
                        onTap: () => _pickDate(_endDateController),
                        decoration: const InputDecoration(labelText: 'End date'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _departureController,
                        readOnly: true,
                        onTap: () => _pickTime(_departureController),
                        decoration: const InputDecoration(
                          labelText: 'Departure',
                          prefixIcon: Icon(Icons.schedule_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _targetArrivalController,
                        readOnly: true,
                        onTap: () => _pickTime(_targetArrivalController),
                        decoration: const InputDecoration(labelText: 'Target arrival'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bufferController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Arrival buffer (minutes)',
                    prefixIcon: Icon(Icons.timer_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveTrip,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Create trip'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      initialDate: now,
    );
    if (date == null) return;
    controller.text = '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    controller.text = time.format(context);
  }

  void _saveTrip() {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();
    if (origin.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose both a start and destination.')),
      );
      return;
    }

    final trip = const TripFactoryService().buildTrip(
      name: _nameController.text,
      origin: origin,
      destination: destination,
      tripType: _tripType,
      startDateLabel: _startDateController.text,
      endDateLabel: _endDateController.text,
      departureLabel: _departureController.text,
      targetArrivalLabel: _targetArrivalController.text,
      arrivalBufferMinutes: int.tryParse(_bufferController.text.trim()) ?? 30,
    );
    widget.onTripCreated(trip);
  }
}
