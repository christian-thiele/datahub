import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_redis/datahub_redis.dart';
import 'package:test/test.dart' as dart_test;

const redisPassword = 'datahub';

/// Declares a group of tests that share a single Redis container.
///
/// `declareTest` starts a compose environment per test, which is slow for
/// files with many tests. Every test still gets its own [TestHost] and an
/// empty database.
void redisGroup(String name, void Function(RedisTestEnvironment env) body) {
  dart_test.group(name, () {
    final environment = RedisTestEnvironment._();
    dart_test.setUpAll(environment._up);
    dart_test.tearDownAll(environment._down);
    body(environment);
  });
}

class RedisTestEnvironment {
  static final _compose = ComposeEnvironment.fromFile(
    'test/redis.docker-compose.yml',
  );

  ComposeEnvironmentInstance? _instance;

  RedisTestEnvironment._();

  /// The host port of the Redis container.
  int get port => _instance!.servicePorts
      .firstWhere((p) => p.name == 'redis' && p.containerPort == 6379)
      .hostPort;

  Future<void> _up() async => _instance = await _compose.up();

  Future<void> _down() async {
    await _instance?.down();
    _instance = null;
  }

  /// Base configuration for [RedisService] pointing at the container.
  Map<String, dynamic> get config => {
    'host': '127.0.0.1',
    'port': port,
    'password': redisPassword,
  };

  /// Declares a test that runs [body] inside a [TestHost] with a
  /// [RedisService] and an empty database.
  ///
  /// [config] is merged into the configuration, e.g. to shorten lock leases.
  void test(
    String name,
    Future<void> Function(Redis redis) body, {
    Map<String, dynamic> config = const {},
    dart_test.Timeout? timeout,
  }) {
    dart_test.test(name, () async {
      final host = await startHost(config: config);
      try {
        await host.run(() async {
          final redis = Find<Redis>().find();
          await redis.execute(['FLUSHALL']);
          await body(redis);
        });
      } finally {
        await host.stop();
      }
    }, timeout: timeout);
  }

  /// Starts a [TestHost] with a [RedisService], for tests that need more
  /// than one service instance (e.g. lock contention between instances).
  Future<RedisTestHost> startHost({
    Map<String, dynamic> config = const {},
  }) async {
    final host = TestHost(
      components: [const RedisService(), const _TestRunner()],
      testBody: () {},
    );
    host.configuration.addConfigMap({...this.config, ...config});
    await host.initialize();
    return RedisTestHost._(host);
  }
}

class RedisTestHost {
  final TestHost _host;

  RedisTestHost._(this._host);

  /// The [Redis] instance of this host.
  Redis get redis => _host.findComponent(Find<Redis>(), null);

  /// The [LockProvider] of this host.
  LockProvider<String> get locks =>
      _host.findComponent(Find<LockProvider<String>>(), null);

  /// Runs [body] inside the context of the host, so that `Find` works.
  Future<T> run<T>(Future<T> Function() body) =>
      _host.findComponent(Find<_TestRunnerInstance>(), null).run(body);

  Future<void> stop() async {
    if (_host.state == ServiceHostState.initialized) {
      await _host.shutdown();
    }
  }
}

class _TestRunner implements Service {
  const _TestRunner();

  @override
  ServiceInstance<_TestRunner> createInstance() => _TestRunnerInstance();
}

class _TestRunnerInstance extends ServiceInstance<_TestRunner> {
  Future<T> run<T>(Future<T> Function() body) => context.run(body);
}

/// Polls [condition] until it is true or [timeout] elapsed.
Future<void> eventually(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final watch = Stopwatch()..start();
  while (!await condition()) {
    if (watch.elapsed > timeout) {
      throw TimeoutException('Condition not met within $timeout.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}
