import '../models/eta_confidence.dart';
import '../models/speed_source.dart';
import '../models/trip_leg.dart';

class EtaConfidenceService {
  const EtaConfidenceService();

  EtaConfidence confidenceForLeg(TripLeg leg) {
    if (leg.segments.isEmpty) return EtaConfidence.low;

    final driveSegments = leg.segments.where((segment) => !segment.isStop).toList();
    if (driveSegments.isEmpty) return EtaConfidence.low;

    final trusted = driveSegments.where((segment) => segment.speedSource.isTrusted).length;
    final ratio = trusted / driveSegments.length;

    if (ratio >= 0.8) return EtaConfidence.high;
    if (ratio >= 0.45) return EtaConfidence.medium;
    return EtaConfidence.low;
  }

  String confidenceDetail(TripLeg leg) {
    if (leg.segments.isEmpty) return 'No route segments yet.';

    final driveSegments = leg.segments.where((segment) => !segment.isStop).toList();
    if (driveSegments.isEmpty) return 'No drive segments yet.';

    final trusted = driveSegments.where((segment) => segment.speedSource.isTrusted).length;
    return '$trusted of ${driveSegments.length} drive segments have trusted speed assumptions.';
  }
}
