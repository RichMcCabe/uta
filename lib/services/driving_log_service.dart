import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/driving_session.dart';

class DrivingLogService {
  const DrivingLogService();

  static const _key = 'uta.driving_sessions.v1';

  Future<List<DrivingSession>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.whereType<Map<String, dynamic>>().map(_fromJson).toList();
  }

  Future<void> save(List<DrivingSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(sessions.map(_toJson).toList(growable: false)),
    );
  }

  Map<String, dynamic> _toJson(DrivingSession item) => {
        'id': item.id,
        'profileId': item.profileId,
        'driverName': item.driverName,
        'tripId': item.tripId,
        'tripName': item.tripName,
        'legId': item.legId,
        'legName': item.legName,
        'startedAt': item.startedAt.toIso8601String(),
        'endedAt': item.endedAt?.toIso8601String(),
        'distanceMiles': item.distanceMiles,
        'startLatitude': item.startLatitude,
        'startLongitude': item.startLongitude,
        'endLatitude': item.endLatitude,
        'endLongitude': item.endLongitude,
        'isManual': item.isManual,
      };

  DrivingSession _fromJson(Map<String, dynamic> json) => DrivingSession(
        id: json['id']?.toString() ?? '',
        profileId: json['profileId']?.toString() ?? '',
        driverName: json['driverName']?.toString() ?? 'Driver',
        tripId: json['tripId']?.toString() ?? '',
        tripName: json['tripName']?.toString() ?? 'Trip',
        legId: json['legId']?.toString() ?? '',
        legName: json['legName']?.toString() ?? 'Leg',
        startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? '') ??
            DateTime.now(),
        endedAt: DateTime.tryParse(json['endedAt']?.toString() ?? ''),
        distanceMiles: (json['distanceMiles'] as num?)?.toDouble() ?? 0,
        startLatitude: (json['startLatitude'] as num?)?.toDouble(),
        startLongitude: (json['startLongitude'] as num?)?.toDouble(),
        endLatitude: (json['endLatitude'] as num?)?.toDouble(),
        endLongitude: (json['endLongitude'] as num?)?.toDouble(),
        isManual: json['isManual'] == true,
      );
}
