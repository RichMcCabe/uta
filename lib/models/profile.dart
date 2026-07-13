import 'driver_restriction.dart';
import 'driving_style.dart';

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.role,
    required this.canDrive,
    required this.drivingStyle,
    required this.restriction,
    this.isPrimary = false,
    this.drivingTargetMinutes = 0,
  });

  final String id;
  final String name;
  final String role;
  final bool canDrive;
  final DrivingStyle drivingStyle;
  final DriverRestriction restriction;
  final bool isPrimary;
  final int drivingTargetMinutes;

  Profile copyWith({
    String? id,
    String? name,
    String? role,
    bool? canDrive,
    DrivingStyle? drivingStyle,
    DriverRestriction? restriction,
    bool? isPrimary,
    int? drivingTargetMinutes,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      canDrive: canDrive ?? this.canDrive,
      drivingStyle: drivingStyle ?? this.drivingStyle,
      restriction: restriction ?? this.restriction,
      isPrimary: isPrimary ?? this.isPrimary,
      drivingTargetMinutes: drivingTargetMinutes ?? this.drivingTargetMinutes,
    );
  }
}
