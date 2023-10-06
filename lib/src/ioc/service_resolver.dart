import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/src/ioc/isolated_host_configuration.dart';

import 'base_service.dart';

/// Convenience method for injecting services.
///
/// See [ServiceResolver.resolveService].
TService resolve<TService extends BaseService?>() =>
    ServiceResolver.current.resolveService<TService>();

abstract class ServiceResolver {
  /// Returns the current zones [ServiceResolver].
  ///
  /// A service resolver is usually provided to the zone by the
  /// applications [ServiceHost].
  ///
  /// See:  [ApplicationHost]
  ///       [TestHost]
  static ServiceResolver get current {
    final resolver = Zone.current[#serviceResolver];
    if (resolver is ServiceResolver) {
      return resolver;
    } else {
      throw Exception('No service resolver registered in current zone.');
    }
  }

  TService resolveService<TService extends BaseService?>();

  Notifier get servicesReady;

  IsolatedHostConfiguration getIsolatedHostConfiguration();
}
