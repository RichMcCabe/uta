import '../models/profile.dart';

class DriverEligibilityService {
  const DriverEligibilityService();

  bool isEligible(Profile profile, {DateTime? at}) {
    if (!profile.canDrive) return false;
    if (!profile.restriction.hasRestrictions) return true;
    final now = at ?? DateTime.now();
    final minute = now.hour * 60 + now.minute;
    final start = profile.restriction.allowedStartMinutes;
    final end = profile.restriction.allowedEndMinutes;
    if (start != null && minute < start) return false;
    if (end != null && minute >= end) return false;
    return true;
  }

  String eligibilitySummary(Profile profile, {DateTime? at}) {
    if (!profile.canDrive) return 'Not configured as a driver';
    if (!profile.restriction.hasRestrictions) return 'Eligible at any time';
    final now = at ?? DateTime.now();
    final minute = now.hour * 60 + now.minute;
    final start = profile.restriction.allowedStartMinutes;
    final end = profile.restriction.allowedEndMinutes;
    if (start != null && minute < start) {
      return 'Eligible from ${_formatMinutes(start)}';
    }
    if (end != null && minute >= end) {
      return 'Not eligible until ${_formatMinutes(start ?? 0)}';
    }
    if (end != null) return 'Eligible until ${_formatMinutes(end)}';
    return 'Eligible now';
  }

  String _formatMinutes(int value) {
    final hour24 = (value ~/ 60) % 24;
    final minute = value % 60;
    final suffix = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $suffix';
  }
}
