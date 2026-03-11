import 'package:datahub/datahub.dart';

class ServiceDelegate implements Service {
  final Future<void> Function()? initialize;
  final Future<void> Function()? dispose;
  final Future<void> Function()? postInitialize;

  ServiceDelegate({this.initialize, this.dispose, this.postInitialize});

  @override
  ServiceInstance<ServiceDelegate> createInstance() =>
      _ServiceDelegateInstance();
}

class _ServiceDelegateInstance extends ServiceInstance<ServiceDelegate> {
  @override
  Future<void> initialize() async {
    await super.initialize();
    if (service.initialize case final callback?) {
      await callback();
    }

    if (service.postInitialize case final callback?) {
      registry.registerPostInitializationCallback(callback);
    }
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    if (service.dispose case final callback?) {
      await callback();
    }
  }
}
