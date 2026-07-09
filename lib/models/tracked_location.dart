class TrackedLocation {
  const TrackedLocation({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.accuracyMeters,
    this.speedMph,
    this.headingDegrees,
  });

  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final double? accuracyMeters;
  final double? speedMph;
  final double? headingDegrees;

  String get displayLabel =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  String get speedLabel => speedMph == null
      ? 'Speed unknown'
      : '${speedMph!.toStringAsFixed(0)} mph';

  String get accuracyLabel => accuracyMeters == null
      ? 'Accuracy unknown'
      : '${accuracyMeters!.toStringAsFixed(0)}m accuracy';
}
