import 'dart:async';

import 'package:datahub/datahub.dart';


/// Base class for all isolated services.
///
/// TODO DOCS
/// TODO worker for web
///
/// See [ServiceHost] for more information.
abstract class IsolatedService extends BaseService {
  late final IsolatedHost _isolatedHost;

  String get isolateDebugName => runtimeType.toString();

  IsolatedService([super.path]);

  @override
  Future<void> initialize() async {
    _isolatedHost = IsolatedHost(
      ServiceResolver.current.getIsolatedHostConfiguration(),
      initializeIsolate,
      shutdownIsolate,
      isolateDebugName,
    );
    await _isolatedHost.initialize();
  }

  Future<void> send(dynamic s) async => _isolatedHost.send(s);

  Future<void> initializeIsolate(Stream receivePort) async {}

  Future<void> shutdownIsolate() async {}

  @override
  Future<void> shutdown() async {
    await _isolatedHost.shutdown();
  }
}
