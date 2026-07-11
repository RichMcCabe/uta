import '../data/default_trip_data.dart';
import '../models/reservation.dart';
import '../models/trip.dart';
import '../models/trip_type.dart';

class TripFactoryService {
  const TripFactoryService();

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
}
