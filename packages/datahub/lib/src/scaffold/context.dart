part of 'service_host.dart';

abstract interface class Session {
  String get debugName;

  /// Returns a unique identifier of the user / account.
  String get identity;
}

final class Context {
  static const _symbol = #datahub.context;
  final String debugName;
  final Context? parent;
  final ServiceRegistry _registry;
  final TreeNode _scope;
  final Environment environment;
  final List<Session> sessions;

  Context._({
    required ServiceRegistry registry,
    required TreeNode scope,
    required this.environment,
    required this.sessions,
    required this.debugName,
  }) : _registry = registry,
       _scope = scope,
       parent = maybeOfZone();

  static Context? maybeOfZone() {
    if (Zone.current[_symbol] case final Context context) {
      return context;
    } else {
      return null;
    }
  }

  static Context ofZone() {
    return maybeOfZone() ??
        (throw ApiException('Context.ofZone called outside of context zone.'));
  }

  static T zoneFind<T>(Find<T> finder) => Context.ofZone().find<T>(finder);

  static T zoneRead<T>(Config<T> config) => Context.ofZone().read<T>(config);

  static T zoneSession<T extends Session?>() => Context.ofZone().session<T>();

  T find<T>(Find<T> finder) => _registry.findComponent(finder, _scope);

  T read<T>(Config<T> config) => _registry.readConfig(config, _scope);

  T session<T extends Session?>() {
    final session = sessions.whereType<T>().firstOrNull;
    if (session != null || null is T) {
      return session as T;
    } else {
      throw ApiRequestException.unauthorized();
    }
  }

  R withSession<R>(Session session, R Function() body) {
    final fork = Context._(
      registry: _registry,
      scope: _scope,
      environment: environment,
      sessions: [session, ...sessions],
      debugName: '$debugName/${session.debugName}',
    );

    return fork.run(body);
  }

  R run<R>(R Function() body) {
    return runZoned<R>(
      body,
      zoneValues: {_symbol: this},
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
          final message = LogMessage(
            timestamp: DateTime.timestamp(),
            level: SeverityLevel.debug,
            line: line,
          );
          _registry
              .findComponent(Find<Telemetry>(), _scope)
              .publishLog(message);
        },
      ),
    );
  }
}
