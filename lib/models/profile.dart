import 'driver_restriction.dart';
import 'driving_style.dart';

class Profile {
  const Profile({
    required this.name,
    required this.role,
    required this.canDrive,
    required this.drivingStyle,
    required this.restriction,
  });

  final String name;
  final String role;
  final bool canDrive;
  final DrivingStyle drivingStyle;
  final DriverRestriction restriction;
}
