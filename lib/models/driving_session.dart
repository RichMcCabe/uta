class DrivingSession {
  const DrivingSession({
    required this.id,
    required this.profileId,
    required this.driverName,
    required this.tripId,
    required this.tripName,
    required this.legId,
    required this.legName,
    required this.startedAt,
    this.endedAt,
    this.distanceMiles = 0,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.isManual = false,
  });

  final String id;
  final String profileId;
  final String driverName;
  final String tripId;
  final String tripName;
  final String legId;
  final String legName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceMiles;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final bool isManual;

  bool get isActive => endedAt == null;
  Duration get duration => (endedAt ?? DateTime.now()).difference(startedAt);

  DrivingSession copyWith({
    DateTime? endedAt,
    double? distanceMiles,
    double? endLatitude,
    double? endLongitude,
  }) {
    return DrivingSession(
      id: id,
      profileId: profileId,
      driverName: driverName,
      tripId: tripId,
      tripName: tripName,
      legId: legId,
      legName: legName,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      isManual: isManual,
    );
  }
}
