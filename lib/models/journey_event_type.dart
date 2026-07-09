enum JourneyEventType {
  departure,
  checkpoint,
  stop,
  fuel,
  meal,
  bathroom,
  driverSwap,
  reservation,
  trafficDelay,
  arrival,
  note,
  custom,
}

extension JourneyEventTypeX on JourneyEventType {
  String get label {
    switch (this) {
      case JourneyEventType.departure:
        return 'Departure';
      case JourneyEventType.checkpoint:
        return 'Checkpoint';
      case JourneyEventType.stop:
        return 'Stop';
      case JourneyEventType.fuel:
        return 'Fuel';
      case JourneyEventType.meal:
        return 'Meal';
      case JourneyEventType.bathroom:
        return 'Bathroom';
      case JourneyEventType.driverSwap:
        return 'Driver swap';
      case JourneyEventType.reservation:
        return 'Reservation';
      case JourneyEventType.trafficDelay:
        return 'Traffic delay';
      case JourneyEventType.arrival:
        return 'Arrival';
      case JourneyEventType.note:
        return 'Note';
      case JourneyEventType.custom:
        return 'Custom';
    }
  }
}
