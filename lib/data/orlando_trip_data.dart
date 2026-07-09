import '../models/driver_restriction.dart';
import '../models/driving_style.dart';
import '../models/fuel_entry.dart';
import '../models/profile.dart';
import '../models/reservation.dart';
import '../models/route_segment.dart';
import '../models/travel_document.dart';
import '../models/trip.dart';
import '../models/trip_module.dart';
import '../models/trip_stop.dart';

class OrlandoTripData {
  static const trip = Trip(
    name: 'Orlando Adventure',
    origin: 'Waxhaw, NC',
    destination: 'Titanic Exhibition, Orlando',
    departureLabel: '1:45 AM',
    targetArrivalLabel: '11:00 AM',
    plannedArrivalLabel: '10:24 AM',
    currentEtaLabel: '10:24 AM',
    sunriseLabel: '6:34 AM',
    sunsetLabel: '8:21 PM',
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
    route: [
      RouteSegment(id: 'home', instruction: 'Depart Waxhaw', distanceMiles: 0, speedLimitMph: 0, assignedDriverName: 'Rich', note: 'Leave home at 1:45 AM.', checkpointLatitude: 34.9249, checkpointLongitude: -80.7434),
      RouteSegment(id: 'sc5', instruction: 'SC-5 W / US-21 toward Rock Hill', distanceMiles: 21.8, speedLimitMph: 55, assignedDriverName: 'Rich', checkpointLatitude: 34.9247, checkpointLongitude: -81.0251),
      RouteSegment(id: 'i77', instruction: 'Merge onto I-77 S toward Columbia', distanceMiles: 76.5, speedLimitMph: 65, assignedDriverName: 'Rich', checkpointLatitude: 34.0007, checkpointLongitude: -81.0348),
      RouteSegment(id: 'i26', instruction: 'Merge onto I-26 E toward Charleston', distanceMiles: 52.8, speedLimitMph: 65, assignedDriverName: 'Rich', checkpointLatitude: 33.4963, checkpointLongitude: -80.8556),
      RouteSegment(id: 'i95', instruction: 'Take exit 169A onto I-95 S toward Savannah', distanceMiles: 131.0, speedLimitMph: 70, assignedDriverName: 'Rich', checkpointLatitude: 32.2892, checkpointLongitude: -81.0809),
      RouteSegment(id: 'breakfast', instruction: 'Breakfast / gas / driver change', distanceMiles: 0, speedLimitMph: 0, assignedDriverName: 'Rich', isStop: true, plannedStopMinutes: 45, note: 'Kenzie may drive only after sunrise.', checkpointLatitude: 31.9843, checkpointLongitude: -81.2784),
      RouteSegment(id: 'kenzie1', instruction: 'I-95 S daylight driving segment', distanceMiles: 88.0, speedLimitMph: 70, assignedDriverName: 'Kenzie', note: 'Target learner-driver segment.', checkpointLatitude: 31.1499, checkpointLongitude: -81.4915),
      RouteSegment(id: 'jax', instruction: 'Use I-295 around Jacksonville', distanceMiles: 49.5, speedLimitMph: 65, assignedDriverName: 'Rich', checkpointLatitude: 30.3322, checkpointLongitude: -81.6557),
      RouteSegment(id: 'daytona', instruction: 'Merge onto I-95 S toward Daytona Beach', distanceMiles: 94.7, speedLimitMph: 70, assignedDriverName: 'Rich', checkpointLatitude: 29.2108, checkpointLongitude: -81.0228),
      RouteSegment(id: 'i4', instruction: 'Take I-4 W toward Orlando', distanceMiles: 38.8, speedLimitMph: 70, assignedDriverName: 'Rich', checkpointLatitude: 28.8029, checkpointLongitude: -81.2695),
      RouteSegment(id: 'arrival', instruction: 'Arrive near International Drive', distanceMiles: 15.8, speedLimitMph: 40, assignedDriverName: 'Rich', note: 'Park and walk to Titanic Exhibition.', checkpointLatitude: 28.4493, checkpointLongitude: -81.4728),
    ],
    stops: [
      TripStop(name: 'Breakfast + gas', type: TripStopType.meal, plannedMinutes: 45, note: 'Target after sunrise window opens.'),
      TripStop(name: 'Driver swap', type: TripStopType.driverSwap, plannedMinutes: 5, note: 'Kenzie daylight segment begins.'),
      TripStop(name: 'Bathroom / stretch', type: TripStopType.bathroom, plannedMinutes: 10, note: 'Use only if buffer remains healthy.'),
      TripStop(name: 'Fuel top-off', type: TripStopType.fuel, plannedMinutes: 10, note: 'Optional if tank/range requires it.'),
    ],
    reservations: [
      Reservation(title: 'Titanic: The Artifact Exhibition', timeLabel: '11:00 AM', location: 'Orlando, FL', category: 'Attraction', note: 'Main arrival target.'),
      Reservation(title: 'Bubba Gump Dinner', timeLabel: 'Evening', location: 'Universal CityWalk', category: 'Restaurant', note: 'Dinner reservation / planned dinner.'),
      Reservation(title: 'Jurassic Escape Room', timeLabel: '7:00 PM', location: 'Universal CityWalk', category: 'Activity', note: 'Leave enough CityWalk buffer.'),
    ],
    documentCategories: [
      TravelDocumentCategory(name: 'Transportation', types: ['Flight', 'Boarding pass', 'Rental car', 'Parking', 'Other']),
      TravelDocumentCategory(name: 'Accommodation', types: ['Hotel', 'Airbnb', 'VRBO', 'Campground', 'Marina', 'Other']),
      TravelDocumentCategory(name: 'Activities', types: ['Attraction ticket', 'Theme park', 'Museum', 'Restaurant reservation', 'Boat rental', 'Other']),
      TravelDocumentCategory(name: 'Legal & Insurance', types: ['Travel insurance', 'Vehicle insurance', 'Passport', 'Driver license', 'Medical document', 'Other']),
      TravelDocumentCategory(name: 'Financial', types: ['Receipt', 'Invoice', 'Toll pass', 'Deposit confirmation', 'Rental agreement', 'Other']),
      TravelDocumentCategory(name: 'Miscellaneous', types: ['Notes', 'Photos', 'Maps', 'Emergency contacts', 'Other']),
    ],
    fuelEntries: [
      FuelEntry(location: 'Planned trip start', gallons: 0, pricePerGallon: 0, odometer: 0, note: 'Actual fuel entries will calculate MPG and cost per mile.'),
    ],
  );
}
