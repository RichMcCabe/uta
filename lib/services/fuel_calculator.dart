import '../models/fuel_entry.dart';

class FuelCalculator {
  const FuelCalculator();

  double totalGallons(List<FuelEntry> entries) =>
      entries.fold(0, (sum, entry) => sum + entry.gallons);

  double totalCost(List<FuelEntry> entries) =>
      entries.fold(0, (sum, entry) => sum + entry.totalCost);

  double? mpgForDistance(double miles, List<FuelEntry> entries) {
    final gallons = totalGallons(entries);
    if (gallons <= 0) return null;
    return miles / gallons;
  }
}
