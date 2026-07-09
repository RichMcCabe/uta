import 'route_segment.dart';

enum RoutingProviderType {
  manual,
  demo,
  osmFuture,
}

extension RoutingProviderTypeX on RoutingProviderType {
  String get label {
    switch (this) {
      case RoutingProviderType.manual:
        return 'Manual';
      case RoutingProviderType.demo:
        return 'Suggested demo';
      case RoutingProviderType.osmFuture:
        return 'OpenStreetMap later';
    }
  }
}

class RoutingResult {
  const RoutingResult({
    required this.providerType,
    required this.summary,
    required this.segments,
    this.warning,
  });

  final RoutingProviderType providerType;
  final String summary;
  final List<RouteSegment> segments;
  final String? warning;
}
