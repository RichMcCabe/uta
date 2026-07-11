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
import 'screens/trip_tools_screen.dart';
import 'screens/trip_wizard_screen.dart';
import 'screens/trips_screen.dart';
import 'services/checkpoint_proximity_service.dart';
import 'services/event_detector.dart';
import 'services/location_service.dart';
import 'services/osm_routing_service.dart';
import 'services/trip_repository.dart';
import 'theme/uta_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tripRepository = await TripRepository.load();
  runApp(UtaApp(tripRepository: tripRepository));
}

class UtaApp extends StatelessWidget {
  const UtaApp({
    required this.tripRepository,
    super.key,
  });

  final TripRepository tripRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultimate Travel App',
      debugShowCheckedModeBanner: false,
      theme: UtaTheme.darkTheme,
      home: UtaHomeShell(tripRepository: tripRepository),
    );
  }
}

class UtaHomeShell extends StatefulWidget {
  const UtaHomeShell({
    required this.tripRepository,
    super.key,
  });

  final TripRepository tripRepository;

  @override
  State<UtaHomeShell> createState() => _UtaHomeShellState();
}

class _UtaHomeShellState extends State<UtaHomeShell> {
  int _selectedIndex = 0;
  late final TripRepository tripRepository = widget.tripRepository;
  final LocationService locationService = const LocationService();
  final CheckpointProximityService checkpointProximityService =
      const CheckpointProximityService();
  StreamSubscription<LocationServiceSnapshot>? locationSubscription;
  bool _locationRequestInFlight = false;

  late Trip trip = tripRepository.activeTrip;
  late TripLeg activeLeg = tripRepository.activeLeg;

  TripState tripState = TripState.ready;
  TrackingMode trackingMode = TrackingMode.manual;
  LocationPermissionStatus locationPermissionStatus =
      LocationPermissionStatus.notRequested;
  GpsTrackingState gpsTrackingState = GpsTrackingState.off;
  TrackedLocation? lastLocation;
  String locationMessage = const LocationService().initialSnapshot().message;

  late DateTime departureTime = DateTime.now();
  late DateTime targetArrivalTime = DateTime.now().add(const Duration(hours: 8));
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
      tripRepository.createTrip(newTrip);
      _syncFromRepository();
    });
  }

  void _startTripNow() {
    setState(() {
      final now = DateTime.now();
      departureTime = now;
      targetArrivalTime = now.add(_estimatedRouteDuration(activeLegTripView));
      completedTime = null;
      tripState = TripState.active;
      tripRepository.updateActiveState(TripState.active);
      statuses = _freshStatusesForActiveLeg();
      manualEvents = const [];
    });
  }


  Duration _estimatedRouteDuration(Trip routeTrip) {
    if (routeTrip.route.isEmpty) return const Duration(hours: 1);
    final minutes = routeTrip.route.fold<double>(
      0,
      (sum, segment) =>
          sum + (segment.distanceMiles / segment.speedLimitMph.clamp(15, 80)) * 60,
    );
    final safeMinutes = minutes.round().clamp(1, 10080).toInt();
    return Duration(minutes: safeMinutes);
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

  Future<void> _rerouteFromCurrentLocation(TrackedLocation location) async {
    final destinationSegment = activeLeg.segments.lastWhere(
      (segment) => segment.hasCheckpointLocation,
      orElse: () => activeLeg.segments.last,
    );
    if (!destinationSegment.hasCheckpointLocation) {
      throw const OsmRoutingException(
        'The saved route does not contain destination coordinates.',
      );
    }

    final driverName = activeLeg.segments.isEmpty
        ? 'Rich'
        : activeLeg.segments.first.assignedDriverName;
    final plan = await const OsmRoutingService().buildDrivingRoute(
      origin: GeocodedPlace(
        displayName: 'Current location',
        latitude: location.latitude,
        longitude: location.longitude,
        typeLabel: 'GPS position',
      ),
      destination: GeocodedPlace(
        displayName: activeLeg.endLabel,
        latitude: destinationSegment.checkpointLatitude!,
        longitude: destinationSegment.checkpointLongitude!,
        typeLabel: 'Destination',
      ),
      assignedDriverName: driverName,
    );

    if (!mounted) return;
    setState(() {
      activeLeg = activeLeg.copyWith(
        startLabel: 'Current location',
        segments: plan.segments,
        note: 'Automatically rerouted from live GPS position.',
      );
      tripRepository.saveActiveLeg(activeLeg);
      trip = trip.copyWith(
        origin: 'Current location',
        route: plan.segments,
        currentEtaLabel: plan.duration.inMinutes < 60
            ? '${plan.duration.inMinutes} min'
            : '${plan.duration.inHours}h ${plan.duration.inMinutes.remainder(60)}m',
      );
      statuses = _freshStatusesForActiveLeg();
      targetArrivalTime = DateTime.now().add(plan.duration);
    });
  }


  Future<void> _requestLocationPermission() async {
    if (_locationRequestInFlight) return;
    _locationRequestInFlight = true;
    try {
      final snapshot = await locationService.requestCurrentLocation();
      if (!mounted) return;

      setState(() {
        _applyLocationSnapshot(snapshot);
        trackingMode = snapshot.permissionStatus.canTrack
            ? TrackingMode.assisted
            : TrackingMode.manual;
      });
    } finally {
      _locationRequestInFlight = false;
    }
  }

  Future<TrackedLocation?> _captureCurrentLocation() async {
    await _requestLocationPermission();
    return lastLocation;
  }

  Future<void> _openAppSettings() async {
    await locationService.openAppSettings();
  }

  Future<void> _openLocationSettings() async {
    await locationService.openLocationSettings();
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
      departureTime = DateTime.now();
      targetArrivalTime = DateTime.now().add(const Duration(hours: 8));
      completedTime = null;
      statuses = _freshStatusesForActiveLeg();
      manualEvents = const [];
    });
  }


  void _openScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _openTripWizard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (routeContext) => TripWizardScreen(
          currentTrip: trip,
          onUseCurrentLocation: _captureCurrentLocation,
          onTripCreated: (newTrip) {
            _setCurrentTrip(newTrip);
            Navigator.of(routeContext).pop();
            setState(() => _selectedIndex = 0);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final legTrip = activeLegTripView;

    final routeScreen = RouteTrackerScreen(
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
    );
    final timelineScreen = TimelineScreen(
      trip: legTrip,
      statuses: statuses,
      departureTime: departureTime,
      manualEvents: manualEvents,
      completedTime: completedTime,
      onAddQuickEvent: _addQuickEvent,
    );
    final legsScreen = LegsScreen(
      trip: trip,
      legs: tripRepository.activeTripLegs,
      activeLeg: activeLeg,
      onSelectLeg: _selectLeg,
      onAddLeg: _addLeg,
      onCloneLeg: _cloneLeg,
      onDeleteLeg: _deleteLeg,
    );
    final legBuilderScreen = LegBuilderScreen(
      trip: legTrip,
      leg: activeLeg,
      onSaveLeg: _saveLeg,
    );

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
        locationPermissionStatus: locationPermissionStatus,
        gpsTrackingState: gpsTrackingState,
        lastLocation: lastLocation,
        onStartTrip: _startTripNow,
        onEndTrip: _endJourney,
        onPlanTrip: _openTripWizard,
        onOpenTrips: () => setState(() => _selectedIndex = 1),
        onOpenGps: () => setState(() => _selectedIndex = 2),
        onOpenTools: () => setState(() => _selectedIndex = 3),
      ),
      TripsScreen(
        records: tripRepository.records,
        onSelectTrip: (id) {
          _selectTrip(id);
          setState(() => _selectedIndex = 0);
        },
        onCloneActiveTrip: _cloneActiveTrip,
        onCreateTrip: _openTripWizard,
      ),
      GpsScreen(
        trip: legTrip,
        tripState: tripState,
        departureTime: departureTime,
        permissionStatus: locationPermissionStatus,
        trackingState: gpsTrackingState,
        lastLocation: lastLocation,
        locationMessage: locationMessage,
        onRequestLocation: _requestLocationPermission,
        onStartTracking: _startGpsTracking,
        onStopTracking: _stopGpsTracking,
        onStartJourney: _startTripNow,
        onEndJourney: _endJourney,
        onReroute: _rerouteFromCurrentLocation,
        onOpenAppSettings: _openAppSettings,
        onOpenLocationSettings: _openLocationSettings,
      ),
      TripToolsScreen(
        onOpenRoute: () => _openScreen(routeScreen),
        onOpenTimeline: () => _openScreen(timelineScreen),
        onOpenLegs: () => _openScreen(legsScreen),
        onOpenLegBuilder: () => _openScreen(legBuilderScreen),
        onOpenPlans: () => _openScreen(ReservationsScreen(trip: trip)),
        onOpenVault: () => _openScreen(DocumentsScreen(trip: trip)),
        onOpenFuel: () => _openScreen(FuelScreen(trip: trip)),
      ),
      ProfileScreen(trip: trip),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2 &&
              locationPermissionStatus ==
                  LocationPermissionStatus.notRequested) {
            _requestLocationPermission();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage_rounded),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.gps_fixed_rounded),
            label: 'GPS',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Tools',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
