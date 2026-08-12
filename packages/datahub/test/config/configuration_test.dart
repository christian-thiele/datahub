import 'package:datahub/config.dart';
import 'package:test/test.dart';

void main() {
  group('Configuration - types', () {
    late Configuration config;

    setUp(() {
      config = Configuration();
      config.addConfigMap({
        'stringValue': 'hello',
        'intValue': 42,
        'doubleValue': 3.14,
        'boolTrue': true,
        'boolFalse': false,
        'strList': <dynamic>['a', 'b', 'c'],
        'intList': <dynamic>[1, 2, 3],
        'nested': {'key': 'value'},
      });
    });

    test('reads String', () {
      expect(config.read<String>(ConfigPath('stringValue')), 'hello');
    });

    test('reads int', () {
      expect(config.read<int>(ConfigPath('intValue')), 42);
    });

    test('reads double', () {
      expect(config.read<double>(ConfigPath('doubleValue')), 3.14);
    });

    test('reads bool true', () {
      expect(config.read<bool>(ConfigPath('boolTrue')), isTrue);
    });

    test('reads bool false', () {
      expect(config.read<bool>(ConfigPath('boolFalse')), isFalse);
    });

    test('reads List<String>', () {
      expect(
        config.read<List<String>>(ConfigPath('strList')),
        orderedEquals(['a', 'b', 'c']),
      );
    });

    test('reads List<int>', () {
      expect(
        config.read<List<int>>(ConfigPath('intList')),
        orderedEquals([1, 2, 3]),
      );
    });

    test('reads nested value via dotted path', () {
      expect(config.read<String>(ConfigPath('nested.key')), 'value');
    });

    test('returns null for missing nullable', () {
      expect(config.read<String?>(ConfigPath('nonExistent')), isNull);
    });

    test('throws ConfigPathException for missing non-nullable', () {
      expect(
        () => config.read<String>(ConfigPath('nonExistent')),
        throwsA(isA<ConfigPathException>()),
      );
    });

    test('throws ConfigTypeException for type mismatch', () {
      expect(
        () => config.read<int>(ConfigPath('stringValue')),
        throwsA(isA<ConfigTypeException>()),
      );
    });

    test('reads nullable List<String>', () {
      // Regression: List<String>? matched none of the decoder branches, so
      // reading a present value threw instead of returning it. Every Config
      // with a defaultValue goes through a nullable read.
      expect(
        config.read<List<String>?>(ConfigPath('strList')),
        orderedEquals(['a', 'b', 'c']),
      );
    });

    test('reads nullable List<int>', () {
      expect(
        config.read<List<int>?>(ConfigPath('intList')),
        orderedEquals([1, 2, 3]),
      );
    });

    test('returns null for missing nullable list', () {
      expect(config.read<List<String>?>(ConfigPath('nonExistent')), isNull);
    });
  });

  group('Configuration - enums', () {
    late Configuration config;

    setUp(() {
      config = Configuration();
      config.addConfigMap({'environment': 'prod', 'bogus': 'nonsense'});
    });

    test('reads a valid enum value', () {
      expect(
        config.readEnum<Environment>(
          ConfigPath('environment'),
          Environment.values,
        ),
        Environment.prod,
      );
    });

    test('throws ConfigValueException for an unknown enum value', () {
      expect(
        () => config.readEnum<Environment>(
          ConfigPath('bogus'),
          Environment.values,
        ),
        throwsA(
          isA<ConfigValueException>()
              .having((e) => e.path, 'path', 'bogus')
              .having((e) => e.value, 'value', 'nonsense')
              .having(
                (e) => e.allowedValues,
                'allowedValues',
                orderedEquals(['dev', 'test', 'stg', 'prod']),
              ),
        ),
      );
    });

    test('environment defaults to dev when unset', () {
      expect(Configuration().environment, Environment.dev);
    });

    test('environment reflects the config value', () {
      expect(config.environment, Environment.prod);
    });

    test('cached environment is invalidated when the config changes', () {
      expect(config.environment, Environment.prod);
      config.addConfigDirective('environment=stg');
      expect(config.environment, Environment.stg);
    });

    test('invalid environment throws ConfigValueException', () {
      final invalid = Configuration();
      invalid.addConfigMap({'environment': 'production'});
      expect(() => invalid.environment, throwsA(isA<ConfigValueException>()));
    });
  });

  group('Configuration - reference syntax', () {
    test('resolves simple reference', () {
      final config = Configuration();
      config.addConfigMap({'original': 'hello', 'reference': r'$original'});
      expect(config.read<String>(ConfigPath('reference')), 'hello');
    });

    test('resolves int reference', () {
      final config = Configuration();
      config.addConfigMap({'port': 8080, 'servicePort': r'$port'});
      expect(config.read<int>(ConfigPath('servicePort')), 8080);
    });

    test('resolves reference to non-existent path as null', () {
      final config = Configuration();
      config.addConfigMap({'ref': r'$nonexistent'});
      expect(config.read<dynamic>(ConfigPath('ref')), isNull);
    });

    test('resolves reference inside list', () {
      final config = Configuration();
      config.addConfigMap({
        'host': 'db.example.com',
        'hosts': <dynamic>[r'$host', 'fallback.example.com'],
      });
      expect(
        config.read<List<dynamic>>(ConfigPath('hosts')),
        orderedEquals(['db.example.com', 'fallback.example.com']),
      );
    });

    test('resolves a forward reference (target defined after reference)', () {
      // References are resolved on read, so declaration order is irrelevant.
      final config = Configuration();
      config.addConfigMap({'reference': r'$original', 'original': 'hello'});
      expect(config.read<String>(ConfigPath('reference')), 'hello');
    });

    test('resolves a chain of references', () {
      final config = Configuration();
      config.addConfigMap({'a': r'$b', 'b': r'$c', 'c': 'end'});
      expect(config.read<String>(ConfigPath('a')), 'end');
    });

    test('reference reflects a value that was overridden later', () {
      // Regression: references used to be resolved at merge time, so a later
      // override of the target did not reach anything referencing it. This is
      // the `-f base.yaml -c host=other` case.
      final config = Configuration();
      config.addConfigMap({'host': 'first', 'db': r'$host'});
      config.addConfigDirective('host=second');
      expect(config.read<String>(ConfigPath('db')), 'second');
    });

    test('resolves a reference into the map that contains it', () {
      // Regression: while merging, the enclosing map was not yet part of the
      // reference root, so a sibling reference could never resolve.
      final config = Configuration();
      config.addConfigMap({
        'db': {'host': 'db.example.com', 'alias': r'$db.host'},
      });
      expect(config.read<String>(ConfigPath('db.alias')), 'db.example.com');
    });

    test('resolves references nested inside a referenced map', () {
      final config = Configuration();
      config.addConfigMap({
        'host': 'db.example.com',
        'db': {
          'host': r'$host',
          'replicas': <dynamic>[r'$host', 'replica.example.com'],
        },
        'copy': r'$db',
      });
      expect(config.read<Map<String, dynamic>>(ConfigPath('copy')), {
        'host': 'db.example.com',
        'replicas': ['db.example.com', 'replica.example.com'],
      });
    });

    test('two references to the same path are not a cycle', () {
      final config = Configuration();
      config.addConfigMap({
        'host': 'db.example.com',
        'db': {'primary': r'$host', 'replica': r'$host'},
      });
      expect(config.read<Map<String, dynamic>>(ConfigPath('db')), {
        'primary': 'db.example.com',
        'replica': 'db.example.com',
      });
    });

    test('a dangling reference behaves like a missing value', () {
      final config = Configuration();
      config.addConfigMap({'ref': r'$nonexistent'});
      expect(config.read<String?>(ConfigPath('ref')), isNull);
      expect(
        () => config.read<String>(ConfigPath('ref')),
        throwsA(isA<ConfigPathException>()),
      );
    });

    test('reading a referenced map does not alias the internal map', () {
      final config = Configuration();
      config.addConfigMap({
        'base': {'host': 'db.example.com'},
        'copy': r'$base',
      });
      (config.read<Map<String, dynamic>>(ConfigPath('copy')))['host'] = 'nope';
      expect(config.read<String>(ConfigPath('base.host')), 'db.example.com');
    });

    test('resolves reference inside nested map to root-level key', () {
      // Regression: recursive merge was not passing referenceRoot, so $-references
      // inside nested maps would try to resolve against the nested map (and fail).
      final config = Configuration();
      config.addConfigMap({
        'host': 'db.example.com',
        'db': {'host': r'$host'},
      });
      expect(config.read<String>(ConfigPath('db.host')), 'db.example.com');
    });

    test('resolves reference in nested map merged from second addConfigMap', () {
      // Regression: the merge(target[key], entry.value) recursive call was also
      // not forwarding referenceRoot when both sides had the same map key.
      final config = Configuration();
      config.addConfigMap({'host': 'primary.example.com', 'db': {}});
      config.addConfigMap({
        'db': {'host': r'$host'},
      });
      expect(config.read<String>(ConfigPath('db.host')), 'primary.example.com');
    });
  });

  group('Configuration - reference escaping', () {
    test(r'leading \$ becomes literal $', () {
      final config = Configuration();
      config.addConfigMap({'escaped': r'\$notAReference'});
      expect(config.read<String>(ConfigPath('escaped')), r'$notAReference');
    });

    test(r'escaped \$ does not resolve even when target key exists', () {
      final config = Configuration();
      config.addConfigMap({'target': 'resolved', 'escaped': r'\$target'});
      expect(config.read<String>(ConfigPath('escaped')), r'$target');
    });

    test(r'plain strings without $ are unaffected', () {
      final config = Configuration();
      config.addConfigMap({'value': 'just a string'});
      expect(config.read<String>(ConfigPath('value')), 'just a string');
    });

    test('escaping survives being merged again', () {
      // Regression: escaping used to be applied at merge time, so the stored
      // value was already unescaped. Merging it a second time re-read it as a
      // reference and resolved it, leaking the referenced value.
      final source = Configuration();
      source.addConfigMap({'secret': 'hunter2', 'literal': r'\$secret'});
      expect(source.read<String>(ConfigPath('literal')), r'$secret');

      final target = Configuration();
      target.addConfiguration(source);
      expect(target.read<String>(ConfigPath('literal')), r'$secret');

      // ... and stays stable no matter how often it is merged.
      target.addConfiguration(source);
      expect(target.read<String>(ConfigPath('literal')), r'$secret');
    });

    test('escaping applies to nested values and lists', () {
      final config = Configuration();
      config.addConfigMap({
        'target': 'resolved',
        'nested': {
          'escaped': r'\$target',
          'list': <dynamic>[r'\$target', r'$target'],
        },
      });
      expect(config.read<String>(ConfigPath('nested.escaped')), r'$target');
      expect(
        config.read<List<String>>(ConfigPath('nested.list')),
        orderedEquals([r'$target', 'resolved']),
      );
    });
  });

  group('Configuration - circular references', () {
    // Cycles used to silently resolve to null, because whichever reference was
    // merged first saw the other as not yet defined. Reading is now able to
    // report the actual cycle.
    test('direct circular reference throws', () {
      final config = Configuration();
      config.addConfigMap({'a': r'$b', 'b': r'$a'});
      expect(
        () => config.read<dynamic>(ConfigPath('a')),
        throwsA(
          isA<ConfigReferenceException>().having(
            (e) => e.references,
            'references',
            orderedEquals(['a', 'b', 'a']),
          ),
        ),
      );
    });

    test('self-reference throws', () {
      final config = Configuration();
      config.addConfigMap({'self': r'$self'});
      expect(
        () => config.read<dynamic>(ConfigPath('self')),
        throwsA(
          isA<ConfigReferenceException>().having(
            (e) => e.references,
            'references',
            orderedEquals(['self', 'self']),
          ),
        ),
      );
    });

    test('three-way circular reference throws', () {
      final config = Configuration();
      config.addConfigMap({'a': r'$b', 'b': r'$c', 'c': r'$a'});
      expect(
        () => config.read<dynamic>(ConfigPath('a')),
        throwsA(
          isA<ConfigReferenceException>().having(
            (e) => e.references,
            'references',
            orderedEquals(['a', 'b', 'c', 'a']),
          ),
        ),
      );
    });

    test('cycle through a nested map throws', () {
      final config = Configuration();
      config.addConfigMap({
        'db': {'host': r'$alias'},
        'alias': r'$db.host',
      });
      expect(
        () => config.read<dynamic>(ConfigPath('db.host')),
        throwsA(isA<ConfigReferenceException>()),
      );
    });
  });
}
