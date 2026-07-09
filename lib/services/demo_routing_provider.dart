import '../models/routing_result.dart';
import '../models/speed_source.dart';
import '../models/trip.dart';
import 'routing_provider.dart';

class DemoRoutingProvider extends RoutingProvider {
  const DemoRoutingProvider();

  @override
  RoutingProviderType get providerType => RoutingProviderType.demo;

  @override
  Future<RoutingResult> buildRoute({
    required Trip trip,
    required String startLabel,
    required String endLabel,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return RoutingResult(
      providerType: providerType,
      summary: 'Suggested route generated from UTA demo data. User may edit every segment.',
      segments: [
        for (final segment in trip.route)
          segment.copyWith(speedSource: SpeedSource.imported),
      ],
      warning: 'This is not live navigation. Verify route, traffic, closures, and road conditions.',
    );
  }
}
