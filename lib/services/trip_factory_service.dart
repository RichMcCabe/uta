import '../data/orlando_trip_data.dart';
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
    final base = OrlandoTripData.trip;

    return base.copyWith(
      name: name.trim().isEmpty ? 'New Trip' : name.trim(),
      origin: origin.trim().isEmpty ? 'Start location' : origin.trim(),
      destination: destination.trim().isEmpty ? 'Destination' : destination.trim(),
      tripType: tripType,
      startDateLabel: startDateLabel.trim().isEmpty ? 'Not set' : startDateLabel.trim(),
      endDateLabel: endDateLabel.trim().isEmpty ? 'Not set' : endDateLabel.trim(),
      departureLabel: departureLabel.trim().isEmpty ? 'Not set' : departureLabel.trim(),
      targetArrivalLabel: targetArrivalLabel.trim().isEmpty ? 'Not set' : targetArrivalLabel.trim(),
      plannedArrivalLabel: 'Needs route',
      currentEtaLabel: 'Needs route',
      arrivalBufferMinutes: arrivalBufferMinutes,
      reservations: [
        Reservation(
          title: 'Primary arrival target',
          timeLabel: targetArrivalLabel.trim().isEmpty ? 'Not set' : targetArrivalLabel.trim(),
          location: destination.trim().isEmpty ? 'Destination' : destination.trim(),
          category: 'Arrival',
          note: 'Created from New Trip wizard. Add exact reservations later.',
        ),
      ],
    );
  }
}
