import '../models/profile.dart';

class DriverEligibilityService {
  const DriverEligibilityService();

  String eligibilitySummary(Profile profile, String sunriseLabel, String sunsetLabel) {
    if (!profile.canDrive) return 'Not listed as a driver';
    if (!profile.restriction.hasRestrictions) return 'No driving restrictions';
    final parts = <String>[];
    if (profile.restriction.sunriseRestricted) parts.add('after $sunriseLabel');
    if (profile.restriction.sunsetRestricted) parts.add('before $sunsetLabel');
    if (profile.restriction.maxContinuousMinutes != null) {
      parts.add('max ${profile.restriction.maxContinuousMinutes! ~/ 60}h segment');
    }
    return parts.join(' • ');
  }
}
