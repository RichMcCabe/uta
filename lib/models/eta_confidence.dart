enum EtaConfidence {
  high,
  medium,
  low,
}

extension EtaConfidenceX on EtaConfidence {
  String get label {
    switch (this) {
      case EtaConfidence.high:
        return 'High confidence';
      case EtaConfidence.medium:
        return 'Medium confidence';
      case EtaConfidence.low:
        return 'Low confidence';
    }
  }

  String get shortLabel {
    switch (this) {
      case EtaConfidence.high:
        return 'High';
      case EtaConfidence.medium:
        return 'Medium';
      case EtaConfidence.low:
        return 'Low';
    }
  }
}
