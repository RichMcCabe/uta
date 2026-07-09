enum DrivingStyle {
  underLimit,
  postedLimit,
  overOneToFive,
  overSixToTen,
  custom,
}

extension DrivingStyleX on DrivingStyle {
  String get label {
    switch (this) {
      case DrivingStyle.underLimit:
        return '1–5 mph below limit';
      case DrivingStyle.postedLimit:
        return 'Posted speed limit';
      case DrivingStyle.overOneToFive:
        return '1–5 mph above limit';
      case DrivingStyle.overSixToTen:
        return '6–10 mph above limit';
      case DrivingStyle.custom:
        return 'Custom planning profile';
    }
  }

  bool get isAboveLimit =>
      this == DrivingStyle.overOneToFive ||
      this == DrivingStyle.overSixToTen ||
      this == DrivingStyle.custom;

  int get defaultAdjustmentMph {
    switch (this) {
      case DrivingStyle.underLimit:
        return -3;
      case DrivingStyle.postedLimit:
        return 0;
      case DrivingStyle.overOneToFive:
        return 4;
      case DrivingStyle.overSixToTen:
        return 8;
      case DrivingStyle.custom:
        return 0;
    }
  }
}
