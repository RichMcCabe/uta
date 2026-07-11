import '../models/driver_restriction.dart';
import '../models/driving_style.dart';
import '../models/profile.dart';
import '../models/travel_document.dart';
import '../models/trip.dart';
import '../models/trip_module.dart';

class DefaultTripData {
  const DefaultTripData._();

  static const trip = Trip(
    name: 'Plan your first trip',
    origin: 'Choose a start',
    destination: 'Choose a destination',
    departureLabel: 'Not set',
    targetArrivalLabel: 'Not set',
    plannedArrivalLabel: 'Needs route',
    currentEtaLabel: 'Needs route',
    sunriseLabel: 'Not set',
    sunsetLabel: 'Not set',
    modules: [
      TripModule.roadTrip,
      TripModule.itinerary,
      TripModule.documents,
      TripModule.fuel,
      TripModule.reservations,
      TripModule.liveTravel,
    ],
    profiles: [
      Profile(
        name: 'Rich',
        role: 'Primary traveler',
        canDrive: true,
        drivingStyle: DrivingStyle.overSixToTen,
        restriction: DriverRestriction(hasRestrictions: false),
      ),
      Profile(
        name: 'Kenzie',
        role: 'Learner driver',
        canDrive: true,
        drivingStyle: DrivingStyle.underLimit,
        restriction: DriverRestriction(
          hasRestrictions: true,
          sunriseRestricted: true,
          sunsetRestricted: true,
          maxContinuousMinutes: 120,
          notes: 'Permit restriction: daylight driving only.',
        ),
      ),
    ],
    route: [],
    stops: [],
    reservations: [],
    documentCategories: [
      TravelDocumentCategory(
        name: 'Transportation',
        types: ['Flight', 'Boarding pass', 'Rental car', 'Parking', 'Other'],
      ),
      TravelDocumentCategory(
        name: 'Accommodation',
        types: ['Hotel', 'Airbnb', 'VRBO', 'Campground', 'Marina', 'Other'],
      ),
      TravelDocumentCategory(
        name: 'Activities',
        types: [
          'Attraction ticket',
          'Theme park',
          'Museum',
          'Restaurant reservation',
          'Boat rental',
          'Other',
        ],
      ),
      TravelDocumentCategory(
        name: 'Legal & Insurance',
        types: [
          'Travel insurance',
          'Vehicle insurance',
          'Passport',
          'Driver license',
          'Medical document',
          'Other',
        ],
      ),
      TravelDocumentCategory(
        name: 'Financial',
        types: [
          'Receipt',
          'Invoice',
          'Toll pass',
          'Deposit confirmation',
          'Rental agreement',
          'Other',
        ],
      ),
      TravelDocumentCategory(
        name: 'Miscellaneous',
        types: ['Notes', 'Photos', 'Maps', 'Emergency contacts', 'Other'],
      ),
    ],
    fuelEntries: [],
  );
}
