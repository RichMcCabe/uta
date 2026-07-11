import '../data/default_trip_data.dart';
import '../models/saved_trip_record.dart';
import '../models/trip.dart';
import '../models/trip_leg.dart';
import '../models/trip_state.dart';
import 'leg_builder_service.dart';

class TripRepository {
  TripRepository.seeded() {
    final now = DateTime.now();
    final seedTrip = DefaultTripData.trip;
    final seedLeg = const LegBuilderService().buildCurrentTripLeg(seedTrip);

    _records = [
      SavedTripRecord(
        id: 'starter-trip',
        trip: seedTrip,
        legs: [seedLeg],
        state: TripState.ready,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      ),
    ];
    _activeTripId = 'starter-trip';
    _activeLegId = seedLeg.id;
  }

  late List<SavedTripRecord> _records;
  late String _activeTripId;
  late String _activeLegId;

  List<SavedTripRecord> get records => List.unmodifiable(_records);

  SavedTripRecord get activeRecord =>
      _records.firstWhere((record) => record.id == _activeTripId);

  Trip get activeTrip => activeRecord.trip;

  List<TripLeg> get activeTripLegs => activeRecord.legs;

  TripLeg get activeLeg {
    final legs = activeRecord.legs;
    if (legs.isEmpty) return const LegBuilderService().buildCurrentTripLeg(activeTrip);
    return legs.firstWhere(
      (leg) => leg.id == _activeLegId,
      orElse: () => legs.first,
    );
  }

  void createTrip(Trip trip) {
    final now = DateTime.now();
    final leg = const LegBuilderService().buildCurrentTripLeg(trip);
    final id = _makeId(trip.name);
    final starterOnly = _records.length == 1 && _records.first.id == 'starter-trip';

    final newRecord = SavedTripRecord(
      id: id,
      trip: trip,
      legs: [leg],
      state: TripState.ready,
      createdAt: now,
      updatedAt: now,
      isActive: true,
    );

    _records = [
      if (!starterOnly)
        ..._records.map((record) => record.copyWith(isActive: false)),
      newRecord,
    ];
    _activeTripId = id;
    _activeLegId = leg.id;
  }

  void upsertTrip(Trip trip) {
    final now = DateTime.now();
    final existingIndex = _records.indexWhere((record) => record.id == _activeTripId);

    if (existingIndex == -1) {
      final id = _makeId(trip.name);
      final leg = const LegBuilderService().buildCurrentTripLeg(trip);
      _records = [
        ..._records.map((record) => record.copyWith(isActive: false)),
        SavedTripRecord(
          id: id,
          trip: trip,
          legs: [leg],
          state: TripState.ready,
          createdAt: now,
          updatedAt: now,
          isActive: true,
        ),
      ];
      _activeTripId = id;
      _activeLegId = leg.id;
      return;
    }

    final leg = const LegBuilderService().buildCurrentTripLeg(trip);
    final current = _records[existingIndex];
    final updated = current.copyWith(
      trip: trip,
      legs: [leg],
      state: TripState.ready,
      updatedAt: now,
      isActive: true,
    );

    _records = [
      for (var i = 0; i < _records.length; i++)
        if (i == existingIndex)
          updated
        else
          _records[i].copyWith(isActive: false),
    ];
    _activeLegId = leg.id;
  }

  void saveActiveLeg(TripLeg leg) {
    final now = DateTime.now();
    final legs = [
      for (final existing in activeRecord.legs)
        if (existing.id == leg.id)
          leg.copyWith(isActive: existing.id == _activeLegId)
        else
          existing.copyWith(isActive: existing.id == _activeLegId),
    ];

    _records = [
      for (final record in _records)
        if (record.id == _activeTripId)
          record.copyWith(legs: legs, updatedAt: now)
        else
          record,
    ];
  }

  void addLeg(TripLeg leg) {
    final now = DateTime.now();
    final normalizedLeg = leg.copyWith(isActive: false);

    _records = [
      for (final record in _records)
        if (record.id == _activeTripId)
          record.copyWith(
            legs: [...record.legs, normalizedLeg],
            updatedAt: now,
          )
        else
          record,
    ];
  }

  void cloneLeg(String legId) {
    final leg = activeRecord.legs.firstWhere(
      (item) => item.id == legId,
      orElse: () => activeLeg,
    );
    addLeg(const LegBuilderService().cloneLeg(leg));
  }

  void deleteLeg(String legId) {
    final currentLegs = activeRecord.legs;
    if (currentLegs.length <= 1) return;

    final remaining = currentLegs.where((leg) => leg.id != legId).toList();
    if (!remaining.any((leg) => leg.id == _activeLegId)) {
      _activeLegId = remaining.first.id;
    }

    final now = DateTime.now();
    _records = [
      for (final record in _records)
        if (record.id == _activeTripId)
          record.copyWith(
            legs: [
              for (final leg in remaining)
                leg.copyWith(isActive: leg.id == _activeLegId),
            ],
            updatedAt: now,
          )
        else
          record,
    ];
  }

  void selectLeg(String legId) {
    if (!activeRecord.legs.any((leg) => leg.id == legId)) return;
    _activeLegId = legId;
    final now = DateTime.now();

    _records = [
      for (final record in _records)
        if (record.id == _activeTripId)
          record.copyWith(
            legs: [
              for (final leg in record.legs)
                leg.copyWith(isActive: leg.id == legId),
            ],
            updatedAt: now,
          )
        else
          record,
    ];
  }

  void cloneActiveTrip() {
    final now = DateTime.now();
    final active = activeRecord;
    final clonedTrip = active.trip.copyWith(name: '${active.trip.name} Copy');
    final id = _makeId(clonedTrip.name);
    final clonedLegs = [
      for (var i = 0; i < active.legs.length; i++)
        active.legs[i].copyWith(isActive: i == 0),
    ];

    _records = [
      ..._records.map((record) => record.copyWith(isActive: false)),
      SavedTripRecord(
        id: id,
        trip: clonedTrip,
        legs: clonedLegs,
        state: TripState.ready,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      ),
    ];
    _activeTripId = id;
    _activeLegId = clonedLegs.isEmpty
        ? const LegBuilderService().buildCurrentTripLeg(clonedTrip).id
        : clonedLegs.first.id;
  }

  void selectTrip(String id) {
    if (!_records.any((record) => record.id == id)) return;
    _activeTripId = id;
    final selected = _records.firstWhere((record) => record.id == id);
    _activeLegId = selected.legs.isEmpty ? '' : selected.legs.first.id;

    _records = [
      for (final record in _records)
        record.copyWith(
          isActive: record.id == id,
          legs: [
            for (var i = 0; i < record.legs.length; i++)
              record.legs[i].copyWith(
                isActive: record.id == id && i == 0,
              ),
          ],
        ),
    ];
  }

  void updateActiveState(TripState state) {
    final now = DateTime.now();
    _records = [
      for (final record in _records)
        if (record.id == _activeTripId)
          record.copyWith(state: state, updatedAt: now)
        else
          record,
    ];
  }

  String _makeId(String name) {
    final safeName = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return '$safeName-${DateTime.now().microsecondsSinceEpoch}';
  }
}
