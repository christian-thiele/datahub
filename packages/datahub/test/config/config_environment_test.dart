import 'dart:async';

import 'package:datahub/config.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/test.dart';

/// Captures what [body] writes via `print`, which is where [log] ends up when
/// there is no surrounding [Context].
List<String> captureLog(void Function() body) {
  final lines = <String>[];
  runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (_, _, _, line) => lines.add(line),
    ),
  );
  return lines;
}

Configuration configOf(
  Map<String, dynamic> map, {
  Map<String, String> env = const {},
}) => Configuration(environmentVariables: env)..addConfigMap(map);

void main() {
  group('Configuration - \$env references', () {
    test('reads an environment variable', () {
      final config = configOf(
        {
          'db': {'password': r'$env.DB_PASSWORD'},
        },
        env: {'DB_PASSWORD': 'hunter2'},
      );
      expect(config.read<String>(ConfigPath('db.password')), 'hunter2');
    });

    test('decodes scalars from their string value', () {
      final config = configOf(
        {
          'db': {
            'port': r'$env.DB_PORT',
            'ssl': r'$env.DB_SSL',
            'ratio': r'$env.DB_RATIO',
          },
        },
        env: {'DB_PORT': '5432', 'DB_SSL': 'true', 'DB_RATIO': '0.5'},
      );
      expect(config.read<int>(ConfigPath('db.port')), 5432);
      expect(config.read<bool>(ConfigPath('db.ssl')), isTrue);
      expect(config.read<double>(ConfigPath('db.ratio')), 0.5);
    });

    test('an unset variable behaves like an absent value', () {
      final config = configOf({
        'db': {'password': r'$env.DB_PASSWORD'},
      });
      expect(config.read<String?>(ConfigPath('db.password')), isNull);
      expect(
        () => config.read<String>(ConfigPath('db.password')),
        throwsA(isA<ConfigPathException>()),
      );
    });

    test('an empty variable is a value, not an absence', () {
      final config = configOf(
        {
          'db': {'password': r'$env.DB_PASSWORD'},
        },
        env: {'DB_PASSWORD': ''},
      );
      expect(config.read<String>(ConfigPath('db.password')), '');
    });

    test('resolves inside nested maps and lists', () {
      final config = configOf(
        {
          'hosts': <dynamic>[r'$env.PRIMARY', 'replica.example.com'],
          'db': {
            'nested': {'host': r'$env.PRIMARY'},
          },
        },
        env: {'PRIMARY': 'primary.example.com'},
      );
      expect(
        config.read<List<String>>(ConfigPath('hosts')),
        orderedEquals(['primary.example.com', 'replica.example.com']),
      );
      expect(
        config.read<String>(ConfigPath('db.nested.host')),
        'primary.example.com',
      );
    });

    test('reads a variable whose name contains a dot', () {
      final config = configOf(
        {'value': r'$env.my.var'},
        env: {'my.var': 'dotted'},
      );
      expect(config.read<String>(ConfigPath('value')), 'dotted');
    });

    test(r'\$env is an escaped literal', () {
      final config = configOf(
        {'value': r'\$env.DB_PASSWORD'},
        env: {'DB_PASSWORD': 'hunter2'},
      );
      expect(config.read<String>(ConfigPath('value')), r'$env.DB_PASSWORD');
    });

    test('a bare \$env without a name is an ordinary config reference', () {
      final config = configOf({
        'env': 'a plain config value',
        'value': r'$env',
      });
      expect(config.read<String>(ConfigPath('value')), 'a plain config value');
    });

    test('the environment is not exposed as a config subtree', () {
      // Reading a subtree must never hand out unrelated environment variables.
      final config = configOf(
        {
          'db': {'password': r'$env.DB_PASSWORD'},
        },
        env: {'DB_PASSWORD': 'hunter2', 'AWS_SECRET_ACCESS_KEY': 'do-not-leak'},
      );

      final root = config.read<Map<String, dynamic>>(ConfigPath.root());
      expect(root.keys, orderedEquals(['db']));
      expect(root.toString(), isNot(contains('do-not-leak')));
      expect(
        config.read<String?>(ConfigPath('env.AWS_SECRET_ACCESS_KEY')),
        isNull,
      );
    });

    test('an environment value is never resolved as a reference', () {
      // Otherwise an environment variable could pull an unrelated config
      // value into a place that was only meant to receive external input.
      final config = configOf(
        {'secret': 'do-not-leak', 'value': r'$env.INJECTED'},
        env: {'INJECTED': r'$secret'},
      );
      expect(config.read<String>(ConfigPath('value')), r'$secret');
    });

    test('a config value can override an environment reference', () {
      final config = configOf(
        {
          'db': {'password': r'$env.DB_PASSWORD'},
        },
        env: {'DB_PASSWORD': 'from-env'},
      );
      config.addConfigDirective('db.password=from-cli');
      expect(config.read<String>(ConfigPath('db.password')), 'from-cli');
    });

    test('an env reference does not count as a cycle', () {
      final config = configOf(
        {'a': r'$env.NAME', 'b': r'$env.NAME'},
        env: {'NAME': 'value'},
      );
      expect(config.read<String>(ConfigPath('a')), 'value');
      expect(config.read<String>(ConfigPath('b')), 'value');
    });
  });

  group('Configuration - \$env diagnostics', () {
    test('suggests a misspelled variable name', () {
      final config = configOf(
        {
          'db': {'password': r'$env.DB_PASWORD'},
        },
        env: {'DB_PASSWORD': 'hunter2'},
      );

      final lines = captureLog(
        () => config.read<String?>(ConfigPath('db.password')),
      );
      expect(lines.single, contains('db.password'));
      expect(lines.single, contains('env.DB_PASWORD'));
      expect(lines.single, contains('env.DB_PASSWORD'));
    });

    test('reports the suggestion on a required value', () {
      final config = configOf(
        {
          'db': {'password': r'$env.DB_PASWORD'},
        },
        env: {'DB_PASSWORD': 'hunter2'},
      );

      expect(
        () => config.read<String>(ConfigPath('db.password')),
        throwsA(
          isA<ConfigPathException>().having(
            (e) => e.suggestion,
            'suggestion',
            'env.DB_PASSWORD',
          ),
        ),
      );
    });

    test('follows a chain of references to the failing target', () {
      final config = configOf(
        {'a': r'$b', 'b': r'$env.DB_PASWORD'},
        env: {'DB_PASSWORD': 'hunter2'},
      );

      final lines = captureLog(() => config.read<String?>(ConfigPath('a')));
      expect(lines.single, contains('env.DB_PASSWORD'));
    });

    test('stays silent when no variable resembles the missing one', () {
      final config = configOf(
        {
          'db': {'password': r'$env.DB_PASSWORD'},
        },
        env: {'PATH': '/usr/bin', 'HOME': '/root'},
      );
      expect(
        captureLog(() => config.read<String?>(ConfigPath('db.password'))),
        isEmpty,
      );
    });

    test('stays silent when the environment is empty', () {
      final config = configOf({
        'db': {'password': r'$env.DB_PASSWORD'},
      });
      expect(
        captureLog(() => config.read<String?>(ConfigPath('db.password'))),
        isEmpty,
      );
    });

    test('a dangling plain reference is still diagnosed', () {
      final config = configOf({'host': 'a', 'alias': r'$hsot'});
      final lines = captureLog(() => config.read<String?>(ConfigPath('alias')));
      expect(lines.single, contains('"host"'));
    });
  });

  group('Configuration - reserved env key', () {
    test('warns when a config defines a root "env" section', () {
      final config = Configuration(environmentVariables: const {});
      final lines = captureLog(
        () => config.addConfigMap({
          'env': {'foo': 'bar'},
        }),
      );
      expect(lines.single, contains('reserved'));
      expect(lines.single, contains('env'));

      // The section is still readable by path, just not through references.
      expect(config.read<String>(ConfigPath('env.foo')), 'bar');
    });

    test('stays quiet for configs without an env section', () {
      final config = Configuration(environmentVariables: const {});
      expect(captureLog(() => config.addConfigMap({'db': 1})), isEmpty);
    });
  });

  group('declareTest environmentVariables', () {
    declareTest(
      'injects environment variables into \$env references',
      [],
      () {
        expect(Config<String>('db.password').read(), 'from-test-env');
        expect(Config<int>('db.port', defaultValue: 1).read(), 5432);
      },
      config: const {
        'db': {'password': r'$env.DB_PASSWORD', 'port': r'$env.DB_PORT'},
      },
      environmentVariables: const {
        'DB_PASSWORD': 'from-test-env',
        'DB_PORT': '5432',
      },
    );

    declareTest(
      'falls back to the default when a variable is unset',
      [],
      () {
        expect(
          Config<String>('db.password', defaultValue: 'fallback').read(),
          'fallback',
        );
      },
      config: const {
        'db': {'password': r'$env.DB_PASSWORD'},
      },
      environmentVariables: const {},
    );
  });
}
