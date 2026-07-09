enum TripType {
  roadTrip,
  flight,
  cruise,
  rv,
  motorcycle,
  boat,
  other,
}

extension TripTypeX on TripType {
  String get label {
    switch (this) {
      case TripType.roadTrip:
        return 'Road Trip';
      case TripType.flight:
        return 'Flight';
      case TripType.cruise:
        return 'Cruise';
      case TripType.rv:
        return 'RV';
      case TripType.motorcycle:
        return 'Motorcycle';
      case TripType.boat:
        return 'Boat';
      case TripType.other:
        return 'Other';
    }
  }
}
