class DriverRestriction {
  const DriverRestriction({
    required this.hasRestrictions,
    this.sunriseRestricted = false,
    this.sunsetRestricted = false,
    this.maxContinuousMinutes,
    this.notes,
  });

  final bool hasRestrictions;
  final bool sunriseRestricted;
  final bool sunsetRestricted;
  final int? maxContinuousMinutes;
  final String? notes;
}
