import 'package:datahub/ioc.dart';

import 'resource.dart';

/// Interface class for generated Hub provider classes.
///
/// This is exclusively used to distinguish HubClients from HubProviders
/// when resolving from IoC.
///
/// When implementing [HubProvider], the implementation must also implement
/// the Hub Interface ([T]).
abstract class HubProvider<T> extends BaseService {
  HubProvider() {
    assert(this is T, 'HubProvider<$T> must implement $T.');
  }

  List<ResourceProvider> get resources;
}
