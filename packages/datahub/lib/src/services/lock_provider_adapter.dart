import 'package:datahub/abstract.dart';
import 'package:datahub/scaffold.dart';

class LockProviderAdapter<S extends Object, T extends Object>
    implements Service {
  final Find<LockProvider<T>> target;
  final T Function(S) key;

  const LockProviderAdapter({this.target = const Find(), required this.key});

  @override
  ServiceInstance<LockProviderAdapter<S, T>> createInstance() =>
      _LockProviderAdapterInstance<S, T>();
}

class _LockProviderAdapterInstance<S extends Object, T extends Object>
    extends ServiceInstance<LockProviderAdapter<S, T>>
    implements LockProvider<S> {
  @override
  Future<LockHandle> acquireLock(
    S key, {
    Duration? timeout = Duration.zero,
  }) async {
    return await find(
      service.target,
    ).acquireLock(service.key(key), timeout: timeout);
  }
}
