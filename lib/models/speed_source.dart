enum SpeedSource {
  postedVerified,
  imported,
  estimated,
  unknown,
  userOverride,
}

extension SpeedSourceX on SpeedSource {
  String get label {
    switch (this) {
      case SpeedSource.postedVerified:
        return 'Posted / verified';
      case SpeedSource.imported:
        return 'Imported';
      case SpeedSource.estimated:
        return 'Estimated';
      case SpeedSource.unknown:
        return 'Unknown';
      case SpeedSource.userOverride:
        return 'User override';
    }
  }

  String get shortLabel {
    switch (this) {
      case SpeedSource.postedVerified:
        return 'Verified';
      case SpeedSource.imported:
        return 'Imported';
      case SpeedSource.estimated:
        return 'Estimated';
      case SpeedSource.unknown:
        return 'Unknown';
      case SpeedSource.userOverride:
        return 'Override';
    }
  }

  bool get isTrusted =>
      this == SpeedSource.postedVerified ||
      this == SpeedSource.imported ||
      this == SpeedSource.userOverride;
}
