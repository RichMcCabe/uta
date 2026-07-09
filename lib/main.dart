import 'dart:async';

import 'package:flutter/material.dart';

import 'models/journey_event.dart';
import 'models/gps_tracking_state.dart';
import 'models/journey_event_type.dart';
import 'models/location_permission_status.dart';
import 'models/route_checkpoint_status.dart';
import 'models/trip.dart';
import 'models/trip_leg.dart';
import 'models/tracked_location.dart';
import 'models/trip_state.dart';
import 'screens/documents_screen.dart';
import 'screens/fuel_screen.dart';
import 'screens/gps_screen.dart';
import 'screens/leg_builder_screen.dart';
import 'screens/legs_screen.dart';
import 'screens/mission_control_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reservations_screen.dart';
import 'screens/route_tracker_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/trip_wizard_screen.dart';
import 'screens/trips_screen.dart';
import 'services/checkpoint_proximity_service.dart';
import 'services/event_detector.dart';
import 'services/location_service.dart';
import 'services/trip_repository.dart';
import 'theme/uta_theme.dart';

void main() {
  runApp(const UtaApp());
}

class UtaApp extends StatelessWidget {
  const UtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultimate Travel App',
      debugShowCheckedModeBanner: false,
      theme: UtaTheme.darkTheme,
      home: const UtaHomeShell(),
    );
  }
}

class UtaHomeShell extends StatefulWidget {
  const UtaHomeShell({super.key});

  @override
  State<UtaHomeShell> createState() => _UtaHomeShellState();
}

class _UtaHomeShellState extends State<UtaHomeShell> {
  int _selectedIndex = 0;
  final TripRepository tripRepository = TripRepository.seeded();
  final LocationService locationService = const LocationService();
  final CheckpointProximityService checkpointProximityService =
      const CheckpointProximityService();
  StreamSubscription<LocationServiceSnapshot>? locationSubscription;

  late Trip trip = tripRepository.activeTrip;
  late TripLeg activeLeg = tripRepository.activeLeg;

  TripState tripState = TripState.ready;
  TrackingMode trackingMode = TrackingMode.manual;
  LocationPermissionStatus locationPermissionStatus =
      LocationPermissionStatus.notRequested;
  GpsTrackingState gpsTrackingState = GpsTrackingState.off;
  TrackedLocation? lastLocation;
  String locationMessage = const LocationService().initialSnapshot().message;

  late DateTime departureTime = DateTime(2026, 7, 17, 1, 45);
  late DateTime targetArrivalTime = DateTime(2026, 7, 17, 11);
  DateTime? completedTime;

  late List<RouteCheckpointStatus> statuses = _freshStatusesForActiveLeg();

  List<JourneyEvent> manualEvents = const [];

  Trip get activeLegTripView {
    return trip.copyWith(
      origin: activeLeg.startLabel,
      destination: activeLeg.endLabel,
      route: activeLeg.segments,
    );
  }

  List<RouteCheckpointStatus> _freshStatusesForActiveLeg() {
    return [
      for (final segment in activeLeg.segments)
        RouteCheckpointStatus(segmentId: segment.id),
    ];
  }

  void _syncFromRepository() {
    trip = tripRepository.activeTrip;
    activeLeg = tripRepository.activeLeg;
    tripState = tripRepository.activeRecord.state;
    statuses = _freshStatusesForActiveLeg();
    completedTime = null;
    manualEvents = const [];
  }

  void _selectTrip(String id) {
    setState(() {
      tripRepository.selectTrip(id);
      _syncFromRepository();
    });
  }

  void _cloneActiveTrip() {
    setState(() {
      tripRepository.cloneActiveTrip();
      _syncFromRepository();
    });
  }

  void _setCurrentTrip(Trip newTrip) {
    setState(() {
      tripRepository.upsertTrip(newTrip);
      _syncFromRepository();
    });
  }

  void _startTripNow() {
    setState(() {
      final now = DateTime.now();
      departureTime = now;
      targetArrivalTime = now.add(const Duration(hours: 9, minutes: 15));
      completedTime = null;
      tripState = TripState.active;
      tripRepository.updateActiveState(TripState.active);
      statuses = _freshStatusesForActiveLeg();
      manualEvents = const [];
    });
  }

  void _endJourney() {
    setState(() {
      completedTime = DateTime.now();
      tripState = TripState.completed;
      tripRepository.updateActiveState(TripState.completed);
    });
  }

  void _logCheckpoint(String segmentId, DateTime actualTime) {
    setState(() {
      statuses = [
        for (final status in statuses)
          if (status.segmentId == segmentId)
            status.copyWith(
              actualTime: actualTime,
              source: JourneyEventSource.actual,
            )
          else
            status,
      ];
    });
  }

  void _clearCheckpoint(String segmentId) {
    setState(() {
      statuses = [
        for (final status in statuses)
          if (status.segmentId == segmentId)
            status.copyWith(clearActualTime: true)
          else
            status,
      ];
    });
  }

  void _addQuickEvent(JourneyEventType type, String title) {
    final now = DateTime.now();
    setState(() {
      manualEvents = [
        ...manualEvents,
        JourneyEvent(
          id: 'manual-${now.microsecondsSinceEpoch}',
          title: title,
          type: type,
          source: JourneyEventSource.actual,
          time: now,
          subtitle: 'Quick logged now',
        ),
      ];
    });
  }

  void _selectLeg(String legId) {
    setState(() {
      tripRepository.selectLeg(legId);
      activeLeg = tripRepository.activeLeg;
      statuses = _freshStatusesForActiveLeg();
      completedTime = null;
      manualEvents = const [];
    });
  }

  void _addLeg(TripLeg leg) {
    setState(() {
      tripRepository.addLeg(leg);
      activeLeg = tripRepository.activeLeg;
      statuses = _freshStatusesForActiveLeg();
    });
  }

  void _cloneLeg(String legId) {
    setState(() {
      tripRepository.cloneLeg(legId);
      activeLeg = tripRepository.activeLeg;
      statuses = _freshStatusesForActiveLeg();
    });
  }

  void _deleteLeg(String legId) {
    setState(() {
      tripRepository.deleteLeg(legId);
      activeLeg = tripRepository.activeLeg;
      statuses = _freshStatusesForActiveLeg();
    });
  }

  void _saveLeg(TripLeg leg) {
    setState(() {
      activeLeg = leg;
      tripRepository.saveActiveLeg(leg);
      statuses = _freshStatusesForActiveLeg();
      completedTime = null;
      manualEvents = const [];
    });
  }


  Future<void> _requestLocationPermission() async {
    final snapshot = await locationService.requestCurrentLocation();
    if (!mounted) return;

    setState(() {
      _applyLocationSnapshot(snapshot);
      trackingMode = snapshot.permissionStatus.canTrack
          ? TrackingMode.assisted
          : TrackingMode.manual;
    });
  }

  void _startGpsTracking() {
    locationSubscription?.cancel();
    locationSubscription = locationService.trackingSnapshots().listen(
      (snapshot) {
        if (!mounted) return;
        setState(() {
          _applyLocationSnapshot(snapshot);
          trackingMode = snapshot.trackingState == GpsTrackingState.active
              ? TrackingMode.automatic
              : TrackingMode.assisted;
          _autoLogNearbyCheckpoints(snapshot.lastLocation);
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          gpsTrackingState = GpsTrackingState.unavailable;
          locationMessage = 'GPS tracking stopped: $error';
          trackingMode = TrackingMode.manual;
        });
      },
    );
  }

  void _stopGpsTracking() {
    locationSubscription?.cancel();
    locationSubscription = null;
    setState(() {
      gpsTrackingState = locationPermissionStatus.canTrack
          ? GpsTrackingState.ready
          : GpsTrackingState.off;
      locationMessage = 'GPS tracking stopped. Manual checkpoints remain available.';
      trackingMode = TrackingMode.manual;
    });
  }

  void _applyLocationSnapshot(LocationServiceSnapshot snapshot) {
    locationPermissionStatus = snapshot.permissionStatus;
    gpsTrackingState = snapshot.trackingState;
    lastLocation = snapshot.lastLocation;
    locationMessage = snapshot.message;
  }

  void _autoLogNearbyCheckpoints(TrackedLocation? location) {
    if (location == null) return;

    final proximities = checkpointProximityService.estimateProximity(
      trip: activeLegTripView,
      location: location,
    );
    final loggedSegmentIds = {
      for (final status in statuses)
        if (status.isLogged) status.segmentId,
    };
    final matchedProximities = proximities.where(
      (proximity) =>
          proximity.isWithinAutoLogRange &&
          !loggedSegmentIds.contains(proximity.segmentId),
    );

    if (matchedProximities.isEmpty) return;

    for (final proximity in matchedProximities) {
      statuses = [
        for (final status in statuses)
          if (status.segmentId == proximity.segmentId)
            status.copyWith(
              actualTime: location.capturedAt,
              source: JourneyEventSource.gpsAuto,
            )
          else
            status,
      ];
    }
  }

  void _resetProgress() {
    setState(() {
      tripState = TripState.ready;
      tripRepository.updateActiveState(TripState.ready);
      departureTime = DateTime(2026, 7, 17, 1, 45);
      targetArrivalTime = DateTime(2026, 7, 17, 11);
      completedTime = null;
      statuses = _freshStatusesForActiveLeg();
      manualEvents = const [];
    });
  }


  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final legTrip = activeLegTripView;

    final screens = [
      MissionControlScreen(
        trip: legTrip,
        statuses: statuses,
        departureTime: departureTime,
        targetArrivalTime: targetArrivalTime,
        tripState: tripState,
        trackingMode: trackingMode,
        manualEvents: manualEvents,
        completedTime: completedTime,
        onStartTrip: _startTripNow,
        onEndTrip: _endJourney,
      ),
      TripsScreen(
        records: tripRepository.records,
        onSelectTrip: _selectTrip,
        onCloneActiveTrip: _cloneActiveTrip,
      ),
      TripWizardScreen(
        currentTrip: trip,
        onTripCreated: _setCurrentTrip,
      ),
      RouteTrackerScreen(
        trip: legTrip,
        statuses: statuses,
        departureTime: departureTime,
        targetArrivalTime: targetArrivalTime,
        tripState: tripState,
        trackingMode: trackingMode,
        onStartTrip: _startTripNow,
        onEndTrip: _endJourney,
        onLogCheckpoint: _logCheckpoint,
        onClearCheckpoint: _clearCheckpoint,
        onResetProgress: _resetProgress,
      ),
      TimelineScreen(
        trip: legTrip,
        statuses: statuses,
        departureTime: departureTime,
        manualEvents: manualEvents,
        completedTime: completedTime,
        onAddQuickEvent: _addQuickEvent,
      ),
      GpsScreen(
        trip: legTrip,
        permissionStatus: locationPermissionStatus,
        trackingState: gpsTrackingState,
        lastLocation: lastLocation,
        locationMessage: locationMessage,
        onRequestLocation: _requestLocationPermission,
        onStartTracking: _startGpsTracking,
        onStopTracking: _stopGpsTracking,
      ),
      LegsScreen(
        trip: trip,
        legs: tripRepository.activeTripLegs,
        activeLeg: activeLeg,
        onSelectLeg: _selectLeg,
        onAddLeg: _addLeg,
        onCloneLeg: _cloneLeg,
        onDeleteLeg: _deleteLeg,
      ),
      LegBuilderScreen(
        trip: legTrip,
        leg: activeLeg,
        onSaveLeg: _saveLeg,
      ),
      ReservationsScreen(trip: trip),
      DocumentsScreen(trip: trip),
      FuelScreen(trip: trip),
      ProfileScreen(trip: trip),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.flight_takeoff), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.add_location_alt), label: 'New'),
          NavigationDestination(icon: Icon(Icons.route), label: 'Route'),
          NavigationDestination(icon: Icon(Icons.timeline), label: 'Pace'),
          NavigationDestination(icon: Icon(Icons.gps_fixed), label: 'GPS'),
          NavigationDestination(icon: Icon(Icons.alt_route), label: 'Legs'),
          NavigationDestination(icon: Icon(Icons.edit_road), label: 'Build'),
          NavigationDestination(icon: Icon(Icons.confirmation_number), label: 'Plans'),
          NavigationDestination(icon: Icon(Icons.folder_special), label: 'Vault'),
          NavigationDestination(icon: Icon(Icons.local_gas_station), label: 'Fuel'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
