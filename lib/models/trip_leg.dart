import 'route_segment.dart';

enum LegInputMode {
  manualDirections,
  importedDirections,
  mapPin,
  savedPlace,
}

extension LegInputModeX on LegInputMode {
  String get label {
    switch (this) {
      case LegInputMode.manualDirections:
        return 'Manual directions';
      case LegInputMode.importedDirections:
        return 'Imported directions';
      case LegInputMode.mapPin:
        return 'Map pin';
      case LegInputMode.savedPlace:
        return 'Saved place';
    }
  }
}

class TripLeg {
  const TripLeg({
    required this.id,
    required this.name,
    required this.startLabel,
    required this.endLabel,
    required this.inputMode,
    required this.segments,
    this.note,
    this.isActive = false,
  });

  final String id;
  final String name;
  final String startLabel;
  final String endLabel;
  final LegInputMode inputMode;
  final List<RouteSegment> segments;
  final String? note;
  final bool isActive;

  double get totalMiles =>
      segments.fold(0, (sum, segment) => sum + segment.distanceMiles);

  int get checkpointCount => segments.length;

  TripLeg copyWith({
    String? id,
    String? name,
    String? startLabel,
    String? endLabel,
    LegInputMode? inputMode,
    List<RouteSegment>? segments,
    String? note,
    bool? isActive,
  }) {
    return TripLeg(
      id: id ?? this.id,
      name: name ?? this.name,
      startLabel: startLabel ?? this.startLabel,
      endLabel: endLabel ?? this.endLabel,
      inputMode: inputMode ?? this.inputMode,
      segments: segments ?? this.segments,
      note: note ?? this.note,
      isActive: isActive ?? this.isActive,
    );
  }
}
