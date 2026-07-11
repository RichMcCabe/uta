import '../data/default_trip_data.dart';
import '../models/reservation.dart';
import '../models/trip.dart';
import '../models/trip_type.dart';
import 'osm_routing_service.dart';

class TripFactoryService {
  const TripFactoryService({this.routingService = const OsmRoutingService()});

  final OsmRoutingService routingService;

  Future<Trip> buildTripWithRoute({
    required String name,
    required GeocodedPlace origin,
    required GeocodedPlace destination,
    required TripType tripType,
    required String startDateLabel,
    required String endDateLabel,
    required String departureLabel,
    required String targetArrivalLabel,
    required int arrivalBufferMinutes,
  }) async {
    final plan = await routingService.buildDrivingRoute(
      origin: origin,
      destination: destination,
    );

    final now = DateTime.now();
    final plannedArrival = now.add(plan.duration);
    final routeSummary =
        '${plan.distanceMiles.toStringAsFixed(0)} mi • ${_durationLabel(plan.duration)}';

    return DefaultTripData.trip.copyWith(
      name: name.trim().isEmpty ? _defaultTripName(plan.destination.displayName) : name.trim(),
      origin: _shortPlaceLabel(plan.origin.displayName),
      destination: _shortPlaceLabel(plan.destination.displayName),
      tripType: tripType,
      startDateLabel:
          startDateLabel.trim().isEmpty ? 'Not set' : startDateLabel.trim(),
      endDateLabel:
          endDateLabel.trim().isEmpty ? 'Not set' : endDateLabel.trim(),
      departureLabel:
          departureLabel.trim().isEmpty ? 'Not set' : departureLabel.trim(),
      targetArrivalLabel: targetArrivalLabel.trim().isEmpty
          ? _timeLabel(plannedArrival)
          : targetArrivalLabel.trim(),
      plannedArrivalLabel: '${_timeLabel(plannedArrival)} • $routeSummary',
      currentEtaLabel: _timeLabel(plannedArrival),
      arrivalBufferMinutes: arrivalBufferMinutes,
      route: plan.segments,
      stops: const [],
      fuelEntries: const [],
      reservations: [
        Reservation(
          title: 'Arrival target',
          timeLabel: targetArrivalLabel.trim().isEmpty
              ? _timeLabel(plannedArrival)
              : targetArrivalLabel.trim(),
          location: _shortPlaceLabel(plan.destination.displayName),
          category: 'Arrival',
          note: 'Route generated with OpenStreetMap and OSRM.',
        ),
      ],
    );
  }

  Trip buildTrip({
    required String name,
    required String origin,
    required String destination,
    required TripType tripType,
    required String startDateLabel,
    required String endDateLabel,
    required String departureLabel,
    required String targetArrivalLabel,
    required int arrivalBufferMinutes,
  }) {
    final safeOrigin = origin.trim();
    final safeDestination = destination.trim();
    final safeTarget = targetArrivalLabel.trim();

    return DefaultTripData.trip.copyWith(
      name: name.trim().isEmpty ? 'Untitled trip' : name.trim(),
      origin: safeOrigin.isEmpty ? 'Choose a start' : safeOrigin,
      destination:
          safeDestination.isEmpty ? 'Choose a destination' : safeDestination,
      tripType: tripType,
      startDateLabel:
          startDateLabel.trim().isEmpty ? 'Not set' : startDateLabel.trim(),
      endDateLabel:
          endDateLabel.trim().isEmpty ? 'Not set' : endDateLabel.trim(),
      departureLabel:
          departureLabel.trim().isEmpty ? 'Not set' : departureLabel.trim(),
      targetArrivalLabel: safeTarget.isEmpty ? 'Not set' : safeTarget,
      plannedArrivalLabel: 'Needs route',
      currentEtaLabel: 'Needs route',
      arrivalBufferMinutes: arrivalBufferMinutes,
      route: const [],
      stops: const [],
      fuelEntries: const [],
      reservations: safeTarget.isEmpty || safeDestination.isEmpty
          ? const []
          : [
              Reservation(
                title: 'Arrival target',
                timeLabel: safeTarget,
                location: safeDestination,
                category: 'Arrival',
                note: 'Created from trip setup.',
              ),
            ],
    );
  }

  String _defaultTripName(String destination) {
    final short = _shortPlaceLabel(destination);
    return '$short trip';
  }

  String _shortPlaceLabel(String displayName) {
    final parts = displayName.split(',').map((part) => part.trim()).toList();
    if (parts.length <= 2) return displayName;
    return '${parts[0]}, ${parts[1]}';
  }

  String _durationLabel(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  String _timeLabel(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
