class CheckpointProximity {
  const CheckpointProximity({
    required this.segmentId,
    required this.label,
    required this.distanceMiles,
    required this.isWithinAutoLogRange,
  });

  final String segmentId;
  final String label;
  final double distanceMiles;
  final bool isWithinAutoLogRange;
}
