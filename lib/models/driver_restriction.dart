class DriverRestriction {
  const DriverRestriction({
    required this.hasRestrictions,
    this.allowedStartMinutes,
    this.allowedEndMinutes,
    this.maxContinuousMinutes,
    this.notes,
  });

  final bool hasRestrictions;
  final int? allowedStartMinutes;
  final int? allowedEndMinutes;
  final int? maxContinuousMinutes;
  final String? notes;

  DriverRestriction copyWith({
    bool? hasRestrictions,
    int? allowedStartMinutes,
    int? allowedEndMinutes,
    int? maxContinuousMinutes,
    String? notes,
    bool clearAllowedStart = false,
    bool clearAllowedEnd = false,
    bool clearMaxContinuous = false,
    bool clearNotes = false,
  }) {
    return DriverRestriction(
      hasRestrictions: hasRestrictions ?? this.hasRestrictions,
      allowedStartMinutes: clearAllowedStart
          ? null
          : allowedStartMinutes ?? this.allowedStartMinutes,
      allowedEndMinutes:
          clearAllowedEnd ? null : allowedEndMinutes ?? this.allowedEndMinutes,
      maxContinuousMinutes: clearMaxContinuous
          ? null
          : maxContinuousMinutes ?? this.maxContinuousMinutes,
      notes: clearNotes ? null : notes ?? this.notes,
    );
  }
}
