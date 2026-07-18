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

    test(
      'forward reference (target defined after reference) resolves to null',
      () {
        // Map iteration order is insertion order; forward references can't resolve.
        final config = Configuration();
        config.addConfigMap({
          'reference': r'$original', // processed before 'original' is in target
          'original': 'hello',
        });
        expect(config.read<String?>(ConfigPath('reference')), isNull);
      },
    );

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
  });

  group('Configuration - circular references', () {
    test('direct circular reference resolves to null', () {
      final config = Configuration();
      config.addConfigMap({'a': r'$b', 'b': r'$a'});
      // Whichever is processed first sees the other as unresolved.
      expect(config.read<dynamic>(ConfigPath('a')), isNull);
      expect(config.read<dynamic>(ConfigPath('b')), isNull);
    });

    test('self-reference resolves to null', () {
      final config = Configuration();
      config.addConfigMap({'self': r'$self'});
      expect(config.read<dynamic>(ConfigPath('self')), isNull);
    });

    test('three-way circular reference all resolve to null', () {
      final config = Configuration();
      config.addConfigMap({'a': r'$b', 'b': r'$c', 'c': r'$a'});
      expect(config.read<dynamic>(ConfigPath('a')), isNull);
      expect(config.read<dynamic>(ConfigPath('b')), isNull);
      expect(config.read<dynamic>(ConfigPath('c')), isNull);
    });
  });
}
