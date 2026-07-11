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
  });

  final String displayName;
  final double latitude;
  final double longitude;
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

  static const String _userAgent =
      'UTA-Ultimate-Travel-App/1.0 (com.derpapps.uta)';

  Future<OsmRoutePlan> buildDrivingRoute({
    required String originQuery,
    required String destinationQuery,
    String assignedDriverName = 'Rich',
  }) async {
    final origin = await geocode(originQuery);
    final destination = await geocode(destinationQuery);

    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/'
          '${origin.longitude},${origin.latitude};'
          '${destination.longitude},${destination.latitude}',
      <String, String>{
        'overview': 'false',
        'steps': 'true',
        'alternatives': 'false',
      },
    );

    final json = await _getJson(uri);
    final routes = json['routes'];
    if (routes is! List || routes.isEmpty) {
      throw const OsmRoutingException(
        'No drivable route was found between those locations.',
      );
    }

    final route = routes.first;
    if (route is! Map<String, dynamic>) {
      throw const OsmRoutingException('The route service returned invalid data.');
    }

    final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
    final durationSeconds = (route['duration'] as num?)?.round() ?? 0;
    final legs = route['legs'];

    final segments = <RouteSegment>[];
    if (legs is List) {
      for (final leg in legs) {
        if (leg is! Map<String, dynamic>) continue;
        final steps = leg['steps'];
        if (steps is! List) continue;

        for (final step in steps) {
          if (step is! Map<String, dynamic>) continue;
          final stepDistanceMeters =
              (step['distance'] as num?)?.toDouble() ?? 0;
          if (stepDistanceMeters < 15) continue;

          final maneuver = step['maneuver'];
          final maneuverMap = maneuver is Map<String, dynamic>
              ? maneuver
              : const <String, dynamic>{};
          final location = maneuverMap['location'];
          final roadName = (step['name'] as String?)?.trim() ?? '';
          final instruction = _instructionFor(
            maneuverMap: maneuverMap,
            roadName: roadName,
          );
          final estimatedSpeed = _estimatedSpeedMph(
            distanceMeters: stepDistanceMeters,
            durationSeconds: (step['duration'] as num?)?.toDouble() ?? 0,
          );

          segments.add(
            RouteSegment(
              id: 'osm-${segments.length + 1}',
              instruction: instruction,
              distanceMiles: stepDistanceMeters / 1609.344,
              speedLimitMph: estimatedSpeed,
              assignedDriverName: assignedDriverName,
              speedSource: SpeedSource.estimated,
              note:
                  'Estimated route pace from OSRM. This is not a verified posted speed limit.',
              checkpointLongitude: location is List && location.length >= 2
                  ? (location[0] as num?)?.toDouble()
                  : null,
              checkpointLatitude: location is List && location.length >= 2
                  ? (location[1] as num?)?.toDouble()
                  : null,
            ),
          );
        }
      }
    }

    if (segments.isEmpty) {
      segments.add(
        RouteSegment(
          id: 'osm-destination',
          instruction: 'Continue to ${destination.displayName}',
          distanceMiles: distanceMeters / 1609.344,
          speedLimitMph: _estimatedSpeedMph(
            distanceMeters: distanceMeters,
            durationSeconds: durationSeconds.toDouble(),
          ),
          assignedDriverName: assignedDriverName,
          speedSource: SpeedSource.estimated,
          note:
              'Estimated route pace from OSRM. This is not a verified posted speed limit.',
          checkpointLatitude: destination.latitude,
          checkpointLongitude: destination.longitude,
        ),
      );
    }

    return OsmRoutePlan(
      origin: origin,
      destination: destination,
      distanceMiles: distanceMeters / 1609.344,
      duration: Duration(seconds: durationSeconds),
      segments: segments,
    );
  }

  Future<GeocodedPlace> geocode(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw const OsmRoutingException('Enter a location to search.');
    }

    final coordinateMatch = RegExp(
      r'^\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)\s*$',
    ).firstMatch(trimmed);
    if (coordinateMatch != null) {
      final latitude = double.parse(coordinateMatch.group(1)!);
      final longitude = double.parse(coordinateMatch.group(2)!);
      return GeocodedPlace(
        displayName: 'Current location',
        latitude: latitude,
        longitude: longitude,
      );
    }

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      <String, String>{
        'q': trimmed,
        'format': 'jsonv2',
        'limit': '1',
        'addressdetails': '0',
      },
    );

    final client = HttpClient();
    client.userAgent = _userAgent;
    try {
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 12));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(const Duration(seconds: 12));
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OsmRoutingException(
          'Location search failed (${response.statusCode}). Try again.',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! List || decoded.isEmpty) {
        throw OsmRoutingException('No location matched “$trimmed”.');
      }

      final first = decoded.first;
      if (first is! Map<String, dynamic>) {
        throw const OsmRoutingException('Location search returned invalid data.');
      }

      final latitude = double.tryParse(first['lat']?.toString() ?? '');
      final longitude = double.tryParse(first['lon']?.toString() ?? '');
      if (latitude == null || longitude == null) {
        throw const OsmRoutingException('Location coordinates were unavailable.');
      }

      return GeocodedPlace(
        displayName: (first['display_name'] as String?) ?? trimmed,
        latitude: latitude,
        longitude: longitude,
      );
    } on SocketException {
      throw const OsmRoutingException(
        'UTA could not reach OpenStreetMap. Check your internet connection.',
      );
    } on TimeoutException {
      throw const OsmRoutingException('The location search timed out. Try again.');
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final client = HttpClient();
    client.userAgent = _userAgent;
    try {
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 15));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(const Duration(seconds: 15));
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OsmRoutingException(
          'Routing failed (${response.statusCode}). Try again.',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const OsmRoutingException('The route service returned invalid data.');
      }
      return decoded;
    } on SocketException {
      throw const OsmRoutingException(
        'UTA could not reach the routing service. Check your internet connection.',
      );
    } on TimeoutException {
      throw const OsmRoutingException('The route request timed out. Try again.');
    } finally {
      client.close(force: true);
    }
  }

  String _instructionFor({
    required Map<String, dynamic> maneuverMap,
    required String roadName,
  }) {
    final type = (maneuverMap['type'] as String?)?.replaceAll('_', ' ') ?? 'continue';
    final modifier =
        (maneuverMap['modifier'] as String?)?.replaceAll('_', ' ') ?? '';
    final action = modifier.isEmpty ? type : '$type $modifier';
    if (roadName.isEmpty) return _sentenceCase(action);
    return '${_sentenceCase(action)} onto $roadName';
  }

  String _sentenceCase(String value) {
    if (value.isEmpty) return 'Continue';
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  int _estimatedSpeedMph({
    required double distanceMeters,
    required double durationSeconds,
  }) {
    if (distanceMeters <= 0 || durationSeconds <= 0) return 35;
    final mph = (distanceMeters / durationSeconds) * 2.2369362921;
    return mph.clamp(15, 75).round();
  }
}
