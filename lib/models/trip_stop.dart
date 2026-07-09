enum TripStopType { meal, fuel, bathroom, stretch, driverSwap, other }

class TripStop {
  const TripStop({
    required this.name,
    required this.type,
    required this.plannedMinutes,
    required this.note,
  });

  final String name;
  final TripStopType type;
  final int plannedMinutes;
  final String note;
}
