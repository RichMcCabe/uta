import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/route_segment.dart';
import '../models/speed_source.dart';

class GeocodedPlace {
  const GeocodedPlace({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.typeLabel,
  });

  final String displayName;
  final double latitude;
  final double longitude;
  final String? typeLabel;

  String get shortLabel {
    final parts = displayName.split(',').map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
    if (parts.length <= 2) return displayName;
    return '${parts[0]}, ${parts[1]}';
  }
}

class OsmRoutePlan {
  const OsmRoutePlan({
    required this.origin,
    required this.destination,
    required this.distanceMiles,
    required this.duration,
    required this.segments,
  });

  final GeocodedPlace origin;
  final GeocodedPlace destination;
  final double distanceMiles;
  final Duration duration;
  final List<RouteSegment> segments;
}

class OsmRoutingException implements Exception {
  const OsmRoutingException(this.message);
  final String message;
  @override
  String toString() => message;
}

class OsmRoutingService {
  const OsmRoutingService();

  static const String _userAgent = 'UTA-Ultimate-Travel-App/1.0 (com.derpapps.uta)';

  Future<List<GeocodedPlace>> searchPlaces(String query, {int limit = 6}) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return const [];

    final coordinateMatch = RegExp(r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$').firstMatch(trimmed);
    if (coordinateMatch != null) {
      return [
        GeocodedPlace(
          displayName: 'Current location',
          latitude: double.parse(coordinateMatch.group(1)!),
          longitude: double.parse(coordinateMatch.group(2)!),
          typeLabel: 'GPS coordinates',
        ),
      ];
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', <String, String>{
      'q': trimmed,
      'format': 'jsonv2',
      'limit': limit.clamp(1, 10).toString(),
      'addressdetails': '1',
      'dedupe': '1',
    });

    final decoded = await _getJsonList(uri, timeout: const Duration(seconds: 12));
    return decoded.map((item) {
      final latitude = double.tryParse(item['lat']?.toString() ?? '');
      final longitude = double.tryParse(item['lon']?.toString() ?? '');
      if (latitude == null || longitude == null) return null;
      return GeocodedPlace(
        displayName: item['display_name']?.toString() ?? trimmed,
        latitude: latitude,
        longitude: longitude,
        typeLabel: _placeType(item),
      );
    }).whereType<GeocodedPlace>().toList(growable: false);
  }

  Future<GeocodedPlace> geocode(String query) async {
    final results = await searchPlaces(query, limit: 1);
    if (results.isEmpty) throw OsmRoutingException('No location matched “${query.trim()}”.');
    return results.first;
  }

  Future<OsmRoutePlan> buildDrivingRoute({
    required GeocodedPlace origin,
    required GeocodedPlace destination,
    String assignedDriverName = 'Rich',
  }) async {
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}',
      <String, String>{
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'true',
        'alternatives': 'false',
      },
    );

    final json = await _getJsonMap(uri, timeout: const Duration(seconds: 15));
    final routes = json['routes'];
    if (routes is! List || routes.isEmpty || routes.first is! Map<String, dynamic>) {
      throw const OsmRoutingException('No drivable route was found between those locations.');
    }

    final route = routes.first as Map<String, dynamic>;
    final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
    final durationSeconds = (route['duration'] as num?)?.round() ?? 0;
    final segments = <RouteSegment>[];
    final legs = route['legs'];

    if (legs is List) {
      for (final leg in legs.whereType<Map<String, dynamic>>()) {
        final steps = leg['steps'];
        if (steps is! List) continue;
        for (final step in steps.whereType<Map<String, dynamic>>()) {
          final stepDistanceMeters = (step['distance'] as num?)?.toDouble() ?? 0;
          if (stepDistanceMeters < 10) continue;
          final maneuver = step['maneuver'];
          final maneuverMap = maneuver is Map<String, dynamic> ? maneuver : const <String, dynamic>{};
          final location = maneuverMap['location'];
          final roadName = (step['name'] as String?)?.trim() ?? '';
          segments.add(RouteSegment(
            id: 'osm-${segments.length + 1}',
            instruction: _instructionFor(maneuverMap: maneuverMap, roadName: roadName),
            distanceMiles: stepDistanceMeters / 1609.344,
            speedLimitMph: _estimatedSpeedMph(
              distanceMeters: stepDistanceMeters,
              durationSeconds: (step['duration'] as num?)?.toDouble() ?? 0,
            ),
            assignedDriverName: assignedDriverName,
            speedSource: SpeedSource.estimated,
            note: 'OSRM maneuver. Route pace is estimated and is not a verified posted speed limit.',
            checkpointLongitude: location is List && location.length >= 2 ? (location[0] as num?)?.toDouble() : null,
            checkpointLatitude: location is List && location.length >= 2 ? (location[1] as num?)?.toDouble() : null,
          ));
        }
      }
    }

    if (segments.isEmpty) {
      segments.add(RouteSegment(
        id: 'osm-destination',
        instruction: 'Continue to ${destination.shortLabel}',
        distanceMiles: distanceMeters / 1609.344,
        speedLimitMph: _estimatedSpeedMph(distanceMeters: distanceMeters, durationSeconds: durationSeconds.toDouble()),
        assignedDriverName: assignedDriverName,
        speedSource: SpeedSource.estimated,
        note: 'OSRM route pace is estimated and is not a verified posted speed limit.',
        checkpointLatitude: destination.latitude,
        checkpointLongitude: destination.longitude,
      ));
    } else {
      segments.add(RouteSegment(
        id: 'osm-arrival-${segments.length + 1}',
        instruction: 'Arrive at ${destination.shortLabel}',
        distanceMiles: 0,
        speedLimitMph: 15,
        assignedDriverName: assignedDriverName,
        speedSource: SpeedSource.estimated,
        note: 'Destination checkpoint used for live navigation and rerouting.',
        checkpointLatitude: destination.latitude,
        checkpointLongitude: destination.longitude,
      ));
    }

    return OsmRoutePlan(
      origin: origin,
      destination: destination,
      distanceMiles: distanceMeters / 1609.344,
      duration: Duration(seconds: durationSeconds),
      segments: segments,
    );
  }

  Future<List<Map<String, dynamic>>> _getJsonList(Uri uri, {required Duration timeout}) async {
    final decoded = await _requestJson(uri, timeout: timeout);
    if (decoded is! List) throw const OsmRoutingException('Location search returned invalid data.');
    return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<Map<String, dynamic>> _getJsonMap(Uri uri, {required Duration timeout}) async {
    final decoded = await _requestJson(uri, timeout: timeout);
    if (decoded is! Map<String, dynamic>) throw const OsmRoutingException('The route service returned invalid data.');
    return decoded;
  }

  Future<dynamic> _requestJson(Uri uri, {required Duration timeout}) async {
    final client = HttpClient()..userAgent = _userAgent;
    try {
      final request = await client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(timeout);
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OsmRoutingException('Map service request failed (${response.statusCode}). Try again.');
      }
      return jsonDecode(body);
    } on SocketException {
      throw const OsmRoutingException('UTA could not reach OpenStreetMap. Check your internet connection.');
    } on TimeoutException {
      throw const OsmRoutingException('The map request timed out. Try again.');
    } finally {
      client.close(force: true);
    }
  }

  String _placeType(Map<String, dynamic> item) {
    final type = item['type']?.toString().replaceAll('_', ' ');
    final category = item['category']?.toString().replaceAll('_', ' ');
    final value = (type?.isNotEmpty ?? false) ? type! : category;
    if (value == null || value.isEmpty) return 'Place';
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _instructionFor({required Map<String, dynamic> maneuverMap, required String roadName}) {
    final type = (maneuverMap['type'] as String?)?.replaceAll('_', ' ') ?? 'continue';
    final modifier = (maneuverMap['modifier'] as String?)?.replaceAll('_', ' ') ?? '';
    final action = modifier.isEmpty ? type : '$type $modifier';
    if (roadName.isEmpty) return _sentenceCase(action);
    return '${_sentenceCase(action)} onto $roadName';
  }

  String _sentenceCase(String value) => value.isEmpty ? 'Continue' : '${value[0].toUpperCase()}${value.substring(1)}';

  int _estimatedSpeedMph({required double distanceMeters, required double durationSeconds}) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return 35;
    return ((distanceMeters / durationSeconds) * 2.2369362921).clamp(15, 75).round();
  }
}
