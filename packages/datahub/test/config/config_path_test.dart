import 'package:datahub/config.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigPath - parsing', () {
    test('splits on dots', () {
      expect(ConfigPath('a.b.c').parts, orderedEquals(['a', 'b', 'c']));
    });

    test('a single segment is not root', () {
      expect(ConfigPath('a').parts, orderedEquals(['a']));
      expect(ConfigPath('a').isRoot, isFalse);
    });

    test('root has no parts', () {
      expect(ConfigPath.root().parts, isEmpty);
      expect(ConfigPath.root().isRoot, isTrue);
    });

    test('join concatenates segments', () {
      expect(ConfigPath('a').join(ConfigPath('b.c')).toString(), 'a.b.c');
    });

    test('joining root keeps the other path', () {
      expect(ConfigPath.root().join(ConfigPath('a.b')).toString(), 'a.b');
      expect(ConfigPath('a.b').join(ConfigPath.root()).toString(), 'a.b');
    });
  });

  group('ConfigPath - accepted segments', () {
    // Validation used to be an assert with a \w+ pattern, so these threw in
    // development while silently working in an AOT compiled build, where
    // asserts are stripped.
    test('accepts kebab-case keys', () {
      final config = Configuration();
      config.addConfigMap({
        'my-service': {'max-connections': 4},
      });
      expect(config.read<int>(ConfigPath('my-service.max-connections')), 4);
    });

    test('accepts snake_case, camelCase and digits', () {
      expect(
        ConfigPath('my_service.maxConnections.0').parts,
        orderedEquals(['my_service', 'maxConnections', '0']),
      );
    });

    test('accepts non-ascii keys', () {
      expect(ConfigPath('café.größe').parts, orderedEquals(['café', 'größe']));
    });
  });

  group('ConfigPath - rejected segments', () {
    test('throws for an empty path', () {
      expect(
        () => ConfigPath(''),
        throwsA(
          isA<InvalidConfigPathException>().having(
            (e) => e.segment,
            'segment',
            '',
          ),
        ),
      );
    });

    test('throws for an empty segment', () {
      expect(
        () => ConfigPath('a..b'),
        throwsA(isA<InvalidConfigPathException>()),
      );
      expect(
        () => ConfigPath('a.'),
        throwsA(isA<InvalidConfigPathException>()),
      );
      expect(
        () => ConfigPath('.a'),
        throwsA(isA<InvalidConfigPathException>()),
      );
    });

    test('throws for a segment containing the separator', () {
      expect(
        () => ConfigPath.fromParts(['a.b']),
        throwsA(isA<InvalidConfigPathException>()),
      );
    });

    test('is thrown, not asserted, so it also applies without asserts', () {
      // An AssertionError would not be an Exception.
      expect(() => ConfigPath(''), throwsA(isA<Exception>()));
    });
  });

  group('ConfigPath - lookup', () {
    late Configuration config;

    setUp(() {
      config = Configuration();
      config.addConfigMap({
        'a': {
          'b': {'c': 'value'},
        },
      });
    });

    test('resolves a nested path', () {
      expect(config.read<String>(ConfigPath('a.b.c')), 'value');
    });

    test('returns null when a segment is missing', () {
      expect(config.read<String?>(ConfigPath('a.x.c')), isNull);
    });

    test('returns null when descending into a scalar', () {
      expect(config.read<String?>(ConfigPath('a.b.c.d')), isNull);
    });
  });
}
