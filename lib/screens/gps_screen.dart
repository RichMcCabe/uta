import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/gps_tracking_state.dart';
import '../models/location_permission_status.dart';
import '../models/tracked_location.dart';
import '../models/trip.dart';
import '../models/trip_state.dart';
import '../services/driver_eligibility_service.dart';
import '../services/navigation_progress_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/gps_status_card.dart';
import '../widgets/route_map_card.dart';
import '../widgets/uta_card.dart';
import '../widgets/warning_banner.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({
    super.key,
    required this.trip,
    required this.tripState,
    required this.departureTime,
    required this.permissionStatus,
    required this.trackingState,
    required this.lastLocation,
    required this.locationMessage,
    required this.onRequestLocation,
    required this.onStartTracking,
    required this.onStopTracking,
    required this.onStartJourney,
    required this.onEndJourney,
    required this.onReroute,
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  final Trip trip;
  final TripState tripState;
  final DateTime departureTime;
  final LocationPermissionStatus permissionStatus;
  final GpsTrackingState trackingState;
  final TrackedLocation? lastLocation;
  final String locationMessage;
  final VoidCallback onRequestLocation;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;
  final VoidCallback onStartJourney;
  final VoidCallback onEndJourney;
  final Future<void> Function(TrackedLocation location) onReroute;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  static const _offRouteReadingsRequired = 3;
  static const _rerouteCooldown = Duration(seconds: 30);

  final _navigationService = const NavigationProgressService();
  int _offRouteReadings = 0;
  DateTime? _lastRerouteAt;
  bool _isRerouting = false;
  String? _rerouteError;

  @override
  void didUpdateWidget(covariant GpsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastLocation?.capturedAt != oldWidget.lastLocation?.capturedAt) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _evaluateReroute());
    }
  }

  Future<void> _evaluateReroute() async {
    if (!mounted || _isRerouting || widget.tripState != TripState.active) return;
    final location = widget.lastLocation;
    if (location == null || widget.trip.route.length < 2) return;
    if ((location.accuracyMeters ?? 0) > 80) return;

    final snapshot = _snapshot;
    if (!snapshot.isOffRoute) {
      if (_offRouteReadings != 0) setState(() => _offRouteReadings = 0);
      return;
    }

    _offRouteReadings += 1;
    if (_offRouteReadings < _offRouteReadingsRequired) {
      if (mounted) setState(() {});
      return;
    }

    final now = DateTime.now();
    if (_lastRerouteAt != null && now.difference(_lastRerouteAt!) < _rerouteCooldown) return;

    setState(() {
      _isRerouting = true;
      _rerouteError = null;
      _offRouteReadings = 0;
    });
    try {
      await widget.onReroute(location);
      _lastRerouteAt = DateTime.now();
    } catch (error) {
      _rerouteError = error.toString();
    } finally {
      if (mounted) setState(() => _isRerouting = false);
    }
  }

  NavigationSnapshot get _snapshot => _navigationService.calculate(
        trip: widget.trip,
        location: widget.lastLocation,
        departureTime: widget.departureTime,
      );

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final isActive = widget.tripState == TripState.active;
    final driver = widget.trip.route.isEmpty
        ? null
        : widget.trip.route[math.min(math.max(snapshot.activeSegmentIndex, 0), widget.trip.route.length - 1)].assignedDriverName;
    final profile = driver == null
        ? null
        : widget.trip.profiles.where((item) => item.name == driver).firstOrNull;
    final restriction = profile == null
        ? 'Driver not assigned'
        : const DriverEligibilityService().eligibilitySummary(
            profile,
            widget.trip.sunriseLabel,
            widget.trip.sunsetLabel,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Flight Deck'),
        actions: [
          _NavBadge(active: isActive, rerouting: _isRerouting),
          const SizedBox(width: 14),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
        children: [
          if (widget.trip.route.isEmpty)
            const WarningBanner(
              title: 'Create a routed trip first',
              message: 'Choose a start and destination in Trips so UTA can generate directions and monitor the route.',
            ),
          if (_isRerouting)
            const _ReroutingBanner(),
          if (_rerouteError != null)
            WarningBanner(
              title: 'Reroute unavailable',
              message: 'UTA kept the current route. ${_rerouteError!}',
            ),
          if (widget.trip.route.isNotEmpty) ...[
            _ManeuverCard(snapshot: snapshot),
            const SizedBox(height: 12),
            RouteMapCard(
              trip: widget.trip,
              lastLocation: widget.lastLocation,
              activeSegmentIndex: snapshot.activeSegmentIndex,
              followLocation: isActive,
            ),
            const SizedBox(height: 12),
            _FlightMetrics(
              snapshot: snapshot,
              location: widget.lastLocation,
            ),
            const SizedBox(height: 12),
            _ProgressCard(snapshot: snapshot),
            const SizedBox(height: 12),
            _DriverCard(
              driver: driver ?? 'Unassigned',
              restriction: restriction,
              isWarning: profile?.restriction.hasRestrictions ?? false,
            ),
            if (snapshot.isOffRoute && !_isRerouting) ...[
              const SizedBox(height: 12),
              WarningBanner(
                title: 'Checking route position',
                message:
                    'UTA sees the device about ${snapshot.distanceFromRouteMiles.toStringAsFixed(1)} miles from the planned path. Rerouting begins after $_offRouteReadings of $_offRouteReadingsRequired reliable readings.',
              ),
            ],
          ],
          const SizedBox(height: 12),
          GpsStatusCard(
            permissionStatus: widget.permissionStatus,
            trackingState: widget.trackingState,
            lastLocation: widget.lastLocation,
            message: widget.locationMessage,
            onRequestPermission: widget.onRequestLocation,
            onStartTracking: widget.onStartTracking,
            onStopTracking: widget.onStopTracking,
            onOpenAppSettings: widget.onOpenAppSettings,
            onOpenLocationSettings: widget.onOpenLocationSettings,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.trip.route.isEmpty
                ? null
                : isActive
                    ? widget.onEndJourney
                    : () {
                        widget.onStartJourney();
                        widget.onStartTracking();
                      },
            icon: Icon(isActive ? Icons.stop_circle_rounded : Icons.navigation_rounded),
            label: Text(isActive ? 'End navigation' : 'Start navigation'),
          ),
          const SizedBox(height: 10),
          const Text(
            'GPS speed is device-reported. Route pace is estimated from OSRM and is not a verified posted speed limit. Live traffic is not included.',
            textAlign: TextAlign.center,
            style: TextStyle(color: UtaColors.muted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ManeuverCard extends StatelessWidget {
  const _ManeuverCard({required this.snapshot});

  final NavigationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      highlight: true,
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: UtaColors.gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.turn_right_rounded, color: UtaColors.gold, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_distanceLabel(snapshot.distanceToNextMiles), style: UtaText.label),
                const SizedBox(height: 5),
                Text(
                  snapshot.nextInstruction,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightMetrics extends StatelessWidget {
  const _FlightMetrics({required this.snapshot, required this.location});

  final NavigationSnapshot snapshot;
  final TrackedLocation? location;

  @override
  Widget build(BuildContext context) {
    final delta = snapshot.scheduleDelta;
    final onTime = delta.inMinutes.abs() < 2;
    return Row(
      children: [
        Expanded(child: _Metric(label: 'SPEED', value: location?.speedMph == null ? '--' : location!.speedMph!.toStringAsFixed(0), unit: 'mph')),
        const SizedBox(width: 10),
        Expanded(child: _Metric(label: 'ETA', value: _clock(snapshot.liveEta), unit: 'live')),
        const SizedBox(width: 10),
        Expanded(
          child: _Metric(
            label: 'SCHEDULE',
            value: onTime ? 'On time' : '${delta.isNegative ? '-' : '+'}${delta.inMinutes.abs()}m',
            unit: onTime ? 'baseline' : (delta.isNegative ? 'ahead' : 'late'),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: UtaText.label),
          const SizedBox(height: 6),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
          Text(unit, style: const TextStyle(color: UtaColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.snapshot});
  final NavigationSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text('Route progress', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
              const Spacer(),
              Text('${(snapshot.progress * 100).round()}%', style: const TextStyle(color: UtaColors.gold, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(value: snapshot.progress, minHeight: 9),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('${snapshot.completedMiles.toStringAsFixed(0)} mi complete', style: const TextStyle(color: UtaColors.muted)),
              const Spacer(),
              Text('${snapshot.remainingMiles.toStringAsFixed(0)} mi remaining', style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver, required this.restriction, required this.isWarning});
  final String driver;
  final String restriction;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return UtaCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (isWarning ? UtaColors.sunset : UtaColors.mint).withValues(alpha: 0.16),
            child: Icon(isWarning ? Icons.warning_amber_rounded : Icons.verified_user_rounded, color: isWarning ? UtaColors.sunset : UtaColors.mint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT DRIVER', style: UtaText.label),
                Text(driver, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                Text(restriction, style: const TextStyle(color: UtaColors.muted, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.active, required this.rerouting});
  final bool active;
  final bool rerouting;

  @override
  Widget build(BuildContext context) {
    final label = rerouting ? 'REROUTING' : active ? 'LIVE' : 'READY';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: (active ? UtaColors.mint : UtaColors.gold).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(label, style: TextStyle(color: active ? UtaColors.mint : UtaColors.gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
      ),
    );
  }
}

class _ReroutingBanner extends StatelessWidget {
  const _ReroutingBanner();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: UtaCard(
        highlight: true,
        child: Row(
          children: [
            SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 3)),
            SizedBox(width: 12),
            Expanded(child: Text('Rerouting from your current position…', style: TextStyle(fontWeight: FontWeight.w900))),
          ],
        ),
      ),
    );
  }
}

String _clock(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _distanceLabel(double miles) {
  if (miles < 0.1) return '${math.max(50, (miles * 5280).round())} ft';
  return '${miles.toStringAsFixed(miles < 10 ? 1 : 0)} mi';
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
