part of 'service_host.dart';

abstract interface class Session() {
  String get debugName;

  /// Returns a unique identifier of the user / account.
  String get identity;
}

final class Context._({
  required final ServiceRegistry _registry,
  required final TreeNode _scope,
  required final Environment environment,
  required final List<Session> sessions,
  required final String debugName,
}) {
  static const _symbol = #datahub.context;
  final Context? parent;
  this : parent = maybeOfZone();

  static Context? maybeOfZone([Zone? zone]) {
    if ((zone ?? Zone.current)[_symbol] case final Context context) {
      return context;
    } else {
      return null;
    }
  }

  static Context ofZone([Zone? zone]) {
    return maybeOfZone(zone) ??
        (throw const ApiException(
          'Context.ofZone called for zone without context.',
        ));
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
          final telemetry = _registry.findComponent(
            const Find<Telemetry?>(),
            _scope,
          );
          if (telemetry == null) {
            parent.print(zone, line);
            return;
          }

          telemetry.publishLog(
            LogMessage(
              timestamp: DateTime.timestamp(),
              level: SeverityLevel.debug,
              line: line,
            ),
          );
        },
      ),
    );
  }
}
