import 'trip.dart';
import 'trip_leg.dart';
import 'trip_state.dart';

class SavedTripRecord {
  const SavedTripRecord({
    required this.id,
    required this.trip,
    required this.legs,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = false,
  });

  final String id;
  final Trip trip;
  final List<TripLeg> legs;
  final TripState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  SavedTripRecord copyWith({
    String? id,
    Trip? trip,
    List<TripLeg>? legs,
    TripState? state,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return SavedTripRecord(
      id: id ?? this.id,
      trip: trip ?? this.trip,
      legs: legs ?? this.legs,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
