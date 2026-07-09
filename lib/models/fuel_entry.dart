class FuelEntry {
  const FuelEntry({
    required this.location,
    required this.gallons,
    required this.pricePerGallon,
    required this.odometer,
    required this.note,
  });

  final String location;
  final double gallons;
  final double pricePerGallon;
  final int odometer;
  final String note;

  double get totalCost => gallons * pricePerGallon;
}
