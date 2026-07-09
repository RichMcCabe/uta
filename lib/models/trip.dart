import 'fuel_entry.dart';
import 'profile.dart';
import 'reservation.dart';
import 'route_segment.dart';
import 'travel_document.dart';
import 'trip_module.dart';
import 'trip_stop.dart';
import 'trip_type.dart';

class Trip {
  const Trip({
    required this.name,
    required this.origin,
    required this.destination,
    required this.departureLabel,
    required this.targetArrivalLabel,
    required this.plannedArrivalLabel,
    required this.currentEtaLabel,
    required this.sunriseLabel,
    required this.sunsetLabel,
    required this.modules,
    required this.profiles,
    required this.route,
    required this.stops,
    required this.reservations,
    required this.documentCategories,
    required this.fuelEntries,
    this.tripType = TripType.roadTrip,
    this.startDateLabel = 'Not set',
    this.endDateLabel = 'Not set',
    this.arrivalBufferMinutes = 30,
  });

  final String name;
  final String origin;
  final String destination;
  final String departureLabel;
  final String targetArrivalLabel;
  final String plannedArrivalLabel;
  final String currentEtaLabel;
  final String sunriseLabel;
  final String sunsetLabel;
  final List<TripModule> modules;
  final List<Profile> profiles;
  final List<RouteSegment> route;
  final List<TripStop> stops;
  final List<Reservation> reservations;
  final List<TravelDocumentCategory> documentCategories;
  final List<FuelEntry> fuelEntries;
  final TripType tripType;
  final String startDateLabel;
  final String endDateLabel;
  final int arrivalBufferMinutes;

  Trip copyWith({
    String? name,
    String? origin,
    String? destination,
    String? departureLabel,
    String? targetArrivalLabel,
    String? plannedArrivalLabel,
    String? currentEtaLabel,
    String? sunriseLabel,
    String? sunsetLabel,
    List<TripModule>? modules,
    List<Profile>? profiles,
    List<RouteSegment>? route,
    List<TripStop>? stops,
    List<Reservation>? reservations,
    List<TravelDocumentCategory>? documentCategories,
    List<FuelEntry>? fuelEntries,
    TripType? tripType,
    String? startDateLabel,
    String? endDateLabel,
    int? arrivalBufferMinutes,
  }) {
    return Trip(
      name: name ?? this.name,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureLabel: departureLabel ?? this.departureLabel,
      targetArrivalLabel: targetArrivalLabel ?? this.targetArrivalLabel,
      plannedArrivalLabel: plannedArrivalLabel ?? this.plannedArrivalLabel,
      currentEtaLabel: currentEtaLabel ?? this.currentEtaLabel,
      sunriseLabel: sunriseLabel ?? this.sunriseLabel,
      sunsetLabel: sunsetLabel ?? this.sunsetLabel,
      modules: modules ?? this.modules,
      profiles: profiles ?? this.profiles,
      route: route ?? this.route,
      stops: stops ?? this.stops,
      reservations: reservations ?? this.reservations,
      documentCategories: documentCategories ?? this.documentCategories,
      fuelEntries: fuelEntries ?? this.fuelEntries,
      tripType: tripType ?? this.tripType,
      startDateLabel: startDateLabel ?? this.startDateLabel,
      endDateLabel: endDateLabel ?? this.endDateLabel,
      arrivalBufferMinutes: arrivalBufferMinutes ?? this.arrivalBufferMinutes,
    );
  }
}
