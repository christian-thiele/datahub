import 'dart:io';

import 'package:datahub/config.dart';
import 'package:datahub/data.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/test.dart';

enum TestEnumConfig implements DataEnum {
  a('optionA'),
  b('optionB'),
  c('optionC');

  const TestEnumConfig(this.jsonValue);

  @override
  final String jsonValue;
}

// Values used for both code-based and file-based assertions.
const _fullConfig = {
  'stringValue': 'hello',
  'strList': <dynamic>['a', 'list', 'of', 'strings'],
  'intList': <dynamic>[1, 2, 3, 4, 5],
  'dynList': <dynamic>[1, 2, 'three', true],
  'isBool': true,
  'isNotBool': false,
  'intValue': 1,
  'doubleValue': 1.123,
  'enumValue': 'optionB',
  'nested': {
    'key': 'value',
    'deep': {'level': 'deep_value'},
  },
};

void assertAllConfigValues() {
  expect(Config<String>('stringValue').read(), 'hello');
  expect(
    Config<List<String>>('strList').read(),
    orderedEquals(['a', 'list', 'of', 'strings']),
  );
  expect(Config<List<int>>('intList').read(), orderedEquals([1, 2, 3, 4, 5]));
  expect(
    Config<List<dynamic>>('dynList').read(),
    orderedEquals([1, 2, 'three', true]),
  );
  expect(Config<bool>('isBool').read(), isTrue);
  expect(Config<bool>('isNotBool').read(), isFalse);
  expect(Config<int>('intValue').read(), 1);
  expect(Config<double>('doubleValue').read(), 1.123);
  expect(
    Config<TestEnumConfig>('enumValue', values: TestEnumConfig.values).read(),
    TestEnumConfig.b,
  );
  expect(Config<String>('nested.key').read(), 'value');
  expect(Config<String>('nested.deep.level').read(), 'deep_value');
}

void main() {
  // -------------------------------------------------------------------------
  // Code-based configuration
  // -------------------------------------------------------------------------

  declareTest(
    'Code-based: all types',
    [],
    assertAllConfigValues,
    config: _fullConfig,
  );

  declareTest('Code-based: default value used when key is absent', [], () {
    expect(
      Config<String>('missing', defaultValue: 'fallback').read(),
      'fallback',
    );
    expect(Config<int>('missing', defaultValue: 42).read(), 42);
    expect(Config<bool>('missing', defaultValue: false).read(), isFalse);
    expect(
      Config<TestEnumConfig>(
        'missing',
        defaultValue: TestEnumConfig.c,
        values: TestEnumConfig.values,
      ).read(),
      TestEnumConfig.c,
    );
  }, config: const {});

  declareTest(
    'Code-based: Config.value() always returns its fixed value',
    [],
    () {
      expect(Config<String>.value('fixed').read(), 'fixed');
      expect(Config<int>.value(99).read(), 99);
    },
    config: const {},
  );

  // -------------------------------------------------------------------------
  // File-based configuration — YAML
  // -------------------------------------------------------------------------

  declareTest(
    'File-based (YAML): all types',
    [],
    assertAllConfigValues,
    configFiles: [File('test/config/config_file.yaml')],
  );

  // -------------------------------------------------------------------------
  // File-based configuration — JSON
  // -------------------------------------------------------------------------

  declareTest(
    'File-based (JSON): all types',
    [],
    assertAllConfigValues,
    configFiles: [File('test/config/config_file.json')],
  );

  // -------------------------------------------------------------------------
  // Directive-based configuration
  //
  // Directives use the "path=value" command-line syntax. The value is always
  // treated as a raw string. These tests operate on Configuration directly
  // since they don't need the service-host zone.
  // -------------------------------------------------------------------------

  group('Directive: basic string value', () {
    test('sets a top-level key', () {
      final config = Configuration();
      config.addConfigDirective('host=localhost');
      expect(config.read<String>(ConfigPath('host')), 'localhost');
    });

    test('sets an empty string value', () {
      final config = Configuration();
      config.addConfigDirective('key=');
      expect(config.read<String>(ConfigPath('key')), '');
    });

    test('value containing equals signs', () {
      final config = Configuration();
      config.addConfigDirective('token=abc=def=ghi');
      expect(config.read<String>(ConfigPath('token')), 'abc=def=ghi');
    });
  });

  group('Directive: dotted path', () {
    test('creates nested structure', () {
      final config = Configuration();
      config.addConfigDirective('database.host=db.example.com');
      expect(
        config.read<String>(ConfigPath('database.host')),
        'db.example.com',
      );
    });

    test('creates deeply nested structure', () {
      final config = Configuration();
      config.addConfigDirective('a.b.c=deep');
      expect(config.read<String>(ConfigPath('a.b.c')), 'deep');
    });
  });

  group('Directive: ordering and overrides', () {
    test('directive overrides a value set by addConfigMap', () {
      final config = Configuration();
      config.addConfigMap({'host': 'original'});
      config.addConfigDirective('host=overridden');
      expect(config.read<String>(ConfigPath('host')), 'overridden');
    });

    test('addConfigMap after directive overrides the directive', () {
      final config = Configuration();
      config.addConfigDirective('host=from_directive');
      config.addConfigMap({'host': 'from_map'});
      expect(config.read<String>(ConfigPath('host')), 'from_map');
    });

    test('second directive for the same key overrides the first', () {
      final config = Configuration();
      config.addConfigDirective('key=first');
      config.addConfigDirective('key=second');
      expect(config.read<String>(ConfigPath('key')), 'second');
    });
  });

  group('Directive: invalid input', () {
    test('directive without = is ignored', () {
      final config = Configuration();
      config.addConfigDirective('noEqualsSign');
      expect(config.read<String?>(ConfigPath('noEqualsSign')), isNull);
    });

    test('directive starting with = is ignored (empty path)', () {
      final config = Configuration();
      // splitPoint == 0 fails the > 0 check, so nothing is written.
      config.addConfigDirective('=value');
      expect(config.read<String?>(ConfigPath('value')), isNull);
    });
  });
}
