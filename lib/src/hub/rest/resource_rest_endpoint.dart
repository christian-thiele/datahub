import 'package:datahub/api.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/utils.dart';

import '../collection_resource.dart';
import '../element_resource.dart';
import '../hub_provider.dart';
import '../resource.dart';
import 'collection_resource_rest_endpoint.dart';
import 'element_resource_rest_endpoint.dart';

typedef ResourceSelector<THub> = ResourceProvider Function(
    HubProvider<THub> hub);

abstract class ResourceRestEndpoint extends ApiEndpoint {
  ResourceRestEndpoint(super.routePattern);

  static ResourceRestEndpoint forHubResource<THub>(
      ResourceSelector<THub> selector) {
    final provider = selector(resolve<HubProvider<THub>>());
    if (provider is ElementResourceProvider) {
      return ElementResourceRestEndpoint(provider);
    } else if (provider is CollectionResourceProvider) {
      return CollectionResourceRestEndpoint(provider);
    }

    throw ApiError('Unknown ResourceProvider type ${provider.runtimeType}.');
  }

  static List<ResourceRestEndpoint> allOf<THub>() {
    final resources = resolve<HubProvider<THub>>().resources;
    return [
      ...resources
          .whereType<ElementResourceProvider>()
          .map(ElementResourceRestEndpoint.new),
      ...resources
          .whereType<CollectionResourceProvider>()
          .map(CollectionResourceRestEndpoint.new),
    ];
  }
}
