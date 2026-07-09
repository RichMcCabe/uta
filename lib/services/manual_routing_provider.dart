import '../models/routing_result.dart';
import '../models/trip.dart';
import 'routing_provider.dart';

class ManualRoutingProvider extends RoutingProvider {
  const ManualRoutingProvider();

  @override
  RoutingProviderType get providerType => RoutingProviderType.manual;

  @override
  Future<RoutingResult> buildRoute({
    required Trip trip,
    required String startLabel,
    required String endLabel,
  }) async {
    return const RoutingResult(
      providerType: RoutingProviderType.manual,
      summary: 'Manual route builder ready.',
      segments: [],
    );
  }
}
