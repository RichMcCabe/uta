import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver_restriction.dart';
import '../models/driving_style.dart';
import '../models/fuel_entry.dart';
import '../models/profile.dart';
import '../models/reservation.dart';
import '../models/route_segment.dart';
import '../models/saved_trip_record.dart';
import '../models/speed_source.dart';
import '../models/travel_document.dart';
import '../models/trip.dart';
import '../models/trip_leg.dart';
import '../models/trip_module.dart';
import '../models/trip_state.dart';
import '../models/trip_stop.dart';
import '../models/trip_type.dart';
import 'osm_routing_service.dart';

class TripStorageSnapshot {
  const TripStorageSnapshot({
    required this.records,
    required this.activeTripId,
    required this.activeLegId,
  });

  final List<SavedTripRecord> records;
  final String? activeTripId;
  final String? activeLegId;
}

class TripStorageService {
  const TripStorageService();

  static const _recordsKey = 'uta.trip_records.v1';
  static const _activeTripKey = 'uta.active_trip_id.v1';
  static const _activeLegKey = 'uta.active_leg_id.v1';
  static const _recentPlacesKey = 'uta.recent_places.v1';

  Future<TripStorageSnapshot?> loadTrips() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_recordsKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      final records = decoded
          .whereType<Map<String, dynamic>>()
          .map(_recordFromJson)
          .toList(growable: false);
      if (records.isEmpty) return null;
      return TripStorageSnapshot(
        records: records,
        activeTripId: preferences.getString(_activeTripKey),
        activeLegId: preferences.getString(_activeLegKey),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTrips({
    required List<SavedTripRecord> records,
    required String activeTripId,
    required String activeLegId,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _recordsKey,
      jsonEncode(records.map(_recordToJson).toList(growable: false)),
    );
    await preferences.setString(_activeTripKey, activeTripId);
    await preferences.setString(_activeLegKey, activeLegId);
  }

  Future<List<GeocodedPlace>> loadRecentPlaces() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_recentPlacesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<Map<String, dynamic>>().map((item) {
        return GeocodedPlace(
          displayName: item['displayName']?.toString() ?? 'Saved place',
          latitude: (item['latitude'] as num?)?.toDouble() ?? 0,
          longitude: (item['longitude'] as num?)?.toDouble() ?? 0,
          typeLabel: item['typeLabel']?.toString(),
        );
      }).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> rememberPlaces(Iterable<GeocodedPlace> places) async {
    final existing = await loadRecentPlaces();
    final combined = <GeocodedPlace>[];
    for (final place in [...places, ...existing]) {
      final duplicate = combined.any(
        (item) =>
            (item.latitude - place.latitude).abs() < 0.00001 &&
            (item.longitude - place.longitude).abs() < 0.00001,
      );
      if (!duplicate) combined.add(place);
      if (combined.length == 8) break;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _recentPlacesKey,
      jsonEncode([
        for (final place in combined)
          {
            'displayName': place.displayName,
            'latitude': place.latitude,
            'longitude': place.longitude,
            'typeLabel': place.typeLabel,
          },
      ]),
    );
  }

  Map<String, dynamic> _recordToJson(SavedTripRecord record) => {
        'id': record.id,
        'trip': _tripToJson(record.trip),
        'legs': record.legs.map(_legToJson).toList(growable: false),
        'state': record.state.name,
        'createdAt': record.createdAt.toIso8601String(),
        'updatedAt': record.updatedAt.toIso8601String(),
        'isActive': record.isActive,
      };

  SavedTripRecord _recordFromJson(Map<String, dynamic> json) => SavedTripRecord(
        id: json['id']?.toString() ?? 'saved-trip',
        trip: _tripFromJson(json['trip'] as Map<String, dynamic>? ?? const {}),
        legs: (json['legs'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_legFromJson)
            .toList(growable: false),
        state: _enumByName(TripState.values, json['state']?.toString(), TripState.ready),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
        isActive: json['isActive'] == true,
      );

  Map<String, dynamic> _tripToJson(Trip trip) => {
        'name': trip.name,
        'origin': trip.origin,
        'destination': trip.destination,
        'departureLabel': trip.departureLabel,
        'targetArrivalLabel': trip.targetArrivalLabel,
        'plannedArrivalLabel': trip.plannedArrivalLabel,
        'currentEtaLabel': trip.currentEtaLabel,
        'sunriseLabel': trip.sunriseLabel,
        'sunsetLabel': trip.sunsetLabel,
        'modules': trip.modules.map((item) => item.name).toList(growable: false),
        'profiles': trip.profiles.map(_profileToJson).toList(growable: false),
        'route': trip.route.map(_segmentToJson).toList(growable: false),
        'stops': trip.stops.map(_stopToJson).toList(growable: false),
        'reservations': trip.reservations.map(_reservationToJson).toList(growable: false),
        'documentCategories': trip.documentCategories.map(_documentToJson).toList(growable: false),
        'fuelEntries': trip.fuelEntries.map(_fuelToJson).toList(growable: false),
        'tripType': trip.tripType.name,
        'startDateLabel': trip.startDateLabel,
        'endDateLabel': trip.endDateLabel,
        'arrivalBufferMinutes': trip.arrivalBufferMinutes,
      };

  Trip _tripFromJson(Map<String, dynamic> json) => Trip(
        name: json['name']?.toString() ?? 'Saved trip',
        origin: json['origin']?.toString() ?? 'Choose a start',
        destination: json['destination']?.toString() ?? 'Choose a destination',
        departureLabel: json['departureLabel']?.toString() ?? 'Not set',
        targetArrivalLabel: json['targetArrivalLabel']?.toString() ?? 'Not set',
        plannedArrivalLabel: json['plannedArrivalLabel']?.toString() ?? 'Needs route',
        currentEtaLabel: json['currentEtaLabel']?.toString() ?? 'Needs route',
        sunriseLabel: json['sunriseLabel']?.toString() ?? 'Not set',
        sunsetLabel: json['sunsetLabel']?.toString() ?? 'Not set',
        modules: (json['modules'] as List? ?? const [])
            .map((item) => _enumByName(TripModule.values, item?.toString(), TripModule.roadTrip))
            .toList(growable: false),
        profiles: (json['profiles'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_profileFromJson)
            .toList(growable: false),
        route: (json['route'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_segmentFromJson)
            .toList(growable: false),
        stops: (json['stops'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_stopFromJson)
            .toList(growable: false),
        reservations: (json['reservations'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_reservationFromJson)
            .toList(growable: false),
        documentCategories: (json['documentCategories'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_documentFromJson)
            .toList(growable: false),
        fuelEntries: (json['fuelEntries'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_fuelFromJson)
            .toList(growable: false),
        tripType: _enumByName(TripType.values, json['tripType']?.toString(), TripType.roadTrip),
        startDateLabel: json['startDateLabel']?.toString() ?? 'Not set',
        endDateLabel: json['endDateLabel']?.toString() ?? 'Not set',
        arrivalBufferMinutes: (json['arrivalBufferMinutes'] as num?)?.round() ?? 30,
      );

  Map<String, dynamic> _legToJson(TripLeg leg) => {
        'id': leg.id,
        'name': leg.name,
        'startLabel': leg.startLabel,
        'endLabel': leg.endLabel,
        'inputMode': leg.inputMode.name,
        'segments': leg.segments.map(_segmentToJson).toList(growable: false),
        'note': leg.note,
        'isActive': leg.isActive,
      };

  TripLeg _legFromJson(Map<String, dynamic> json) => TripLeg(
        id: json['id']?.toString() ?? 'saved-leg',
        name: json['name']?.toString() ?? 'Saved route',
        startLabel: json['startLabel']?.toString() ?? 'Start',
        endLabel: json['endLabel']?.toString() ?? 'Destination',
        inputMode: _enumByName(LegInputMode.values, json['inputMode']?.toString(), LegInputMode.importedDirections),
        segments: (json['segments'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_segmentFromJson)
            .toList(growable: false),
        note: json['note']?.toString(),
        isActive: json['isActive'] == true,
      );

  Map<String, dynamic> _segmentToJson(RouteSegment item) => {
        'id': item.id,
        'instruction': item.instruction,
        'distanceMiles': item.distanceMiles,
        'speedLimitMph': item.speedLimitMph,
        'assignedDriverName': item.assignedDriverName,
        'speedSource': item.speedSource.name,
        'isStop': item.isStop,
        'plannedStopMinutes': item.plannedStopMinutes,
        'note': item.note,
        'checkpointLatitude': item.checkpointLatitude,
        'checkpointLongitude': item.checkpointLongitude,
      };

  RouteSegment _segmentFromJson(Map<String, dynamic> json) => RouteSegment(
        id: json['id']?.toString() ?? 'saved-segment',
        instruction: json['instruction']?.toString() ?? 'Continue',
        distanceMiles: (json['distanceMiles'] as num?)?.toDouble() ?? 0,
        speedLimitMph: (json['speedLimitMph'] as num?)?.round() ?? 35,
        assignedDriverName: json['assignedDriverName']?.toString() ?? 'Rich',
        speedSource: _enumByName(SpeedSource.values, json['speedSource']?.toString(), SpeedSource.estimated),
        isStop: json['isStop'] == true,
        plannedStopMinutes: (json['plannedStopMinutes'] as num?)?.round() ?? 0,
        note: json['note']?.toString(),
        checkpointLatitude: (json['checkpointLatitude'] as num?)?.toDouble(),
        checkpointLongitude: (json['checkpointLongitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> _profileToJson(Profile item) => {
        'name': item.name,
        'role': item.role,
        'canDrive': item.canDrive,
        'drivingStyle': item.drivingStyle.name,
        'restriction': {
          'hasRestrictions': item.restriction.hasRestrictions,
          'sunriseRestricted': item.restriction.sunriseRestricted,
          'sunsetRestricted': item.restriction.sunsetRestricted,
          'maxContinuousMinutes': item.restriction.maxContinuousMinutes,
          'notes': item.restriction.notes,
        },
      };

  Profile _profileFromJson(Map<String, dynamic> json) {
    final restriction = json['restriction'] as Map<String, dynamic>? ?? const {};
    return Profile(
      name: json['name']?.toString() ?? 'Traveler',
      role: json['role']?.toString() ?? 'Traveler',
      canDrive: json['canDrive'] == true,
      drivingStyle: _enumByName(DrivingStyle.values, json['drivingStyle']?.toString(), DrivingStyle.postedLimit),
      restriction: DriverRestriction(
        hasRestrictions: restriction['hasRestrictions'] == true,
        sunriseRestricted: restriction['sunriseRestricted'] == true,
        sunsetRestricted: restriction['sunsetRestricted'] == true,
        maxContinuousMinutes: (restriction['maxContinuousMinutes'] as num?)?.round(),
        notes: restriction['notes']?.toString(),
      ),
    );
  }

  Map<String, dynamic> _stopToJson(TripStop item) => {
        'name': item.name,
        'type': item.type.name,
        'plannedMinutes': item.plannedMinutes,
        'note': item.note,
      };

  TripStop _stopFromJson(Map<String, dynamic> json) => TripStop(
        name: json['name']?.toString() ?? 'Stop',
        type: _enumByName(TripStopType.values, json['type']?.toString(), TripStopType.other),
        plannedMinutes: (json['plannedMinutes'] as num?)?.round() ?? 0,
        note: json['note']?.toString() ?? '',
      );

  Map<String, dynamic> _reservationToJson(Reservation item) => {
        'title': item.title,
        'timeLabel': item.timeLabel,
        'location': item.location,
        'category': item.category,
        'note': item.note,
      };

  Reservation _reservationFromJson(Map<String, dynamic> json) => Reservation(
        title: json['title']?.toString() ?? 'Reservation',
        timeLabel: json['timeLabel']?.toString() ?? 'Not set',
        location: json['location']?.toString() ?? '',
        category: json['category']?.toString() ?? 'Other',
        note: json['note']?.toString() ?? '',
      );

  Map<String, dynamic> _documentToJson(TravelDocumentCategory item) => {
        'name': item.name,
        'types': item.types,
      };

  TravelDocumentCategory _documentFromJson(Map<String, dynamic> json) => TravelDocumentCategory(
        name: json['name']?.toString() ?? 'Documents',
        types: (json['types'] as List? ?? const []).map((item) => item.toString()).toList(growable: false),
      );

  Map<String, dynamic> _fuelToJson(FuelEntry item) => {
        'location': item.location,
        'gallons': item.gallons,
        'pricePerGallon': item.pricePerGallon,
        'odometer': item.odometer,
        'note': item.note,
      };

  FuelEntry _fuelFromJson(Map<String, dynamic> json) => FuelEntry(
        location: json['location']?.toString() ?? '',
        gallons: (json['gallons'] as num?)?.toDouble() ?? 0,
        pricePerGallon: (json['pricePerGallon'] as num?)?.toDouble() ?? 0,
        odometer: (json['odometer'] as num?)?.round() ?? 0,
        note: json['note']?.toString() ?? '',
      );

  T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
