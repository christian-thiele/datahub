import 'package:datahub/abstract.dart';
import 'package:datahub/scaffold.dart';

class const LockProviderAdapter<S extends Object, T extends Object>({
  final Find<LockProvider<T>> target = const Find(),
  required final T Function(S) key,
}) implements Service {
  @override
  ServiceInstance<LockProviderAdapter<S, T>> createInstance() =>
      _LockProviderAdapterInstance<S, T>();
}

class _LockProviderAdapterInstance<S extends Object, T extends Object>()
    extends ServiceInstance<LockProviderAdapter<S, T>>
    implements LockProvider<S> {
  @override
  Future<LockHandle> acquireLock(
    S key, {
    Duration? timeout = Duration.zero,
  }) async {
    return await find(service.target)
        .acquireLock(service.key(key), timeout: timeout);
  }
}
