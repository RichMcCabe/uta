import 'journey_event_type.dart';

enum JourneyEventSource {
  planned,
  actual,
  estimated,
  gpsAuto,
  gpsAssisted,
  skipped,
}

extension JourneyEventSourceX on JourneyEventSource {
  String get label {
    switch (this) {
      case JourneyEventSource.planned:
        return 'Planned';
      case JourneyEventSource.actual:
        return 'Actual';
      case JourneyEventSource.estimated:
        return 'Estimated';
      case JourneyEventSource.gpsAuto:
        return 'GPS auto';
      case JourneyEventSource.gpsAssisted:
        return 'GPS assisted';
      case JourneyEventSource.skipped:
        return 'Skipped';
    }
  }
}

class JourneyEvent {
  const JourneyEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.source,
    required this.time,
    this.subtitle,
    this.relatedSegmentId,
  });

  final String id;
  final String title;
  final JourneyEventType type;
  final JourneyEventSource source;
  final DateTime time;
  final String? subtitle;
  final String? relatedSegmentId;
}
