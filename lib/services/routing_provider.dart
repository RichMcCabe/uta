import '../models/routing_result.dart';
import '../models/trip.dart';

abstract class RoutingProvider {
  const RoutingProvider();

  RoutingProviderType get providerType;

  Future<RoutingResult> buildRoute({
    required Trip trip,
    required String startLabel,
    required String endLabel,
  });
}
