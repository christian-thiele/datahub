import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/plugin_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseInstanceReadFixTest);
    defineReflectiveTests(UseInstanceContextFixTest);
    defineReflectiveTests(AddAwaitFixTest);
    defineReflectiveTests(AddConstKeywordFixTest);
    defineReflectiveTests(AddEnumValuesFixTest);
    defineReflectiveTests(DataClassFixTest);
    defineReflectiveTests(ConvertToPrimaryConstructorFixTest);
    defineReflectiveTests(MoveSuperInitializeFirstFixTest);
    defineReflectiveTests(MoveSuperDisposeLastFixTest);
  });
}

/// A `Service` / `ServiceInstance` pair with [body] as the instance body.
String _instance(String body) =>
    '''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
$body
}
''';

@reflectiveTest
class UseInstanceReadFixTest extends PluginTestBase {
  test_rewritesConfigRead() async {
    await assertFix(
      _instance('''  final Config<String> host = const Config('host');

  String work() => host.read();'''),
      at: 'host.read()',
      fixKindId: 'datahub.fix.useInstanceRead',
      expected: _instance('''  final Config<String> host = const Config('host');

  String work() => read(host);'''),
    );
  }
}

@reflectiveTest
class UseInstanceContextFixTest extends PluginTestBase {
  static const _kind = 'datahub.fix.useInstanceFind';

  test_rewritesZoneFind() async {
    await assertFix(
      _instance(
        '''  Object work() => Context.zoneFind(const Find<Object>());''',
      ),
      at: 'Context.zoneFind',
      fixKindId: _kind,
      expected: _instance('''  Object work() => find(const Find<Object>());'''),
    );
  }

  test_rewritesOfZoneRead() async {
    await assertFix(
      _instance(
        '''  String work() => Context.ofZone().read(const Config<String>('a'));''',
      ),
      at: 'Context.ofZone()',
      fixKindId: _kind,
      expected: _instance(
        '''  String work() => read(const Config<String>('a'));''',
      ),
    );
  }
}

@reflectiveTest
class AddAwaitFixTest extends PluginTestBase {
  test_insertsAwait() async {
    await assertFix(
      _instance('''  @override
  Future<void> initialize() async {
    super.initialize();
  }'''),
      at: 'super.initialize()',
      fixKindId: 'datahub.fix.addAwait',
      expected: _instance('''  @override
  Future<void> initialize() async {
    await super.initialize();
  }'''),
    );
  }
}

@reflectiveTest
class AddConstKeywordFixTest extends PluginTestBase {
  @override
  List<String> get enabledLintRules => const ['const_service_constructor'];

  test_addsConstToExistingConstructor() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  Db();
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db();',
      fixKindId: 'datahub.fix.addConstKeyword',
      expected: r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => throw '';
}
''',
    );
  }

  test_addsConstToPrimaryConstructor() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

class Db({final host = const Config<String>('host')}) implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db({',
      fixKindId: 'datahub.fix.addConstKeyword',
      expected: r'''
import 'package:datahub/datahub.dart';

class const Db({final host = const Config<String>('host')}) implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
    );
  }

  test_declaresPrimaryConstructorForImplicitOne() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db implements',
      fixKindId: 'datahub.fix.addConstKeyword',
      expected: r'''
import 'package:datahub/datahub.dart';

class const Db() implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
    );
  }

  test_writesClassicConstructorBeforePrimaryConstructors() async {
    await assertFix(
      r'''
// @dart=3.9
import 'package:datahub/datahub.dart';

class Db implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db implements',
      fixKindId: 'datahub.fix.addConstKeyword',
      expected: r'''
// @dart=3.9
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();

  @override
  ServiceInstance createInstance() => throw '';
}
''',
    );
  }
}

@reflectiveTest
class AddEnumValuesFixTest extends PluginTestBase {
  static const _kind = 'datahub.fix.addEnumValues';

  test_appendsValuesArgument() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode>('mode');
''',
      at: "Config<Mode>('mode')",
      fixKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode>('mode', values: Mode.values);
''',
    );
  }

  test_replacesEmptyValues() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode>('mode', values: []);
''',
      at: "Config<Mode>('mode'",
      fixKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode>('mode', values: Mode.values);
''',
    );
  }
}

@reflectiveTest
class DataClassFixTest extends PluginTestBase {
  test_addsPartDirective() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

@Data()
class Person {
  const Person();
}
''',
      at: 'class Person',
      fixKindId: 'datahub.fix.addPartDirective',
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person {
  const Person();
}
''',
    );
  }

  test_addsGeneratedSuperclass() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person {
  const Person();
}
''',
      at: 'class Person',
      fixKindId: 'datahub.fix.extendGeneratedClass',
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends $Person {
  const Person();
}
''',
    );
  }

  test_addsConstToPrimaryConstructor() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person(final String name) extends $Person;
''',
      at: 'Person(',
      fixKindId: 'datahub.fix.addConstKeyword',
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class const Person(final String name) extends $Person;
''',
    );
  }

  test_declaresFieldsInPrimaryConstructor() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends $Person {
  final String name;
  final int? age;
}
''',
      at: 'Person extends',
      fixKindId: 'datahub.fix.addConstKeyword',
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class const Person({required final String name, final int? age}) extends $Person;
''',
    );
  }
}

@reflectiveTest
class ConvertToPrimaryConstructorFixTest extends PluginTestBase {
  static const _kind = 'datahub.fix.convertToPrimaryConstructor';

  @override
  List<String> get enabledLintRules => const ['prefer_primary_constructor'];

  test_service_injectionTypesFollowFromDefaults() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Find<Object> other;
  final Config<String> host;
  final Config<int> port;
  final String name;

  const Db({
    this.other = const Find(),
    this.host = const Config('host'),
    this.port = const Config<int>('port', defaultValue: 5432),
    required this.name,
  });

  @override
  ServiceInstance<Db> createInstance() => throw '';
}
''',
      at: 'Db({',
      fixKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class const Db({
  final other = const Find<Object>(),
  final host = const Config<String>('host'),
  final port = const Config<int>('port', defaultValue: 5432),
  required final String name,
}) implements Service {
  @override
  ServiceInstance<Db> createInstance() => throw '';
}
''',
    );
  }

  test_service_keepsSuperParametersAndOtherMembers() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

abstract class Base implements Service {
  final int retries;
  const Base({this.retries = 3});
}

class Db extends Base {
  static const defaultHost = 'localhost';

  final Config<String> host;
  final timeout = const Duration(seconds: 1);

  Db({super.retries, this.host = const Config('host')});

  @override
  ServiceInstance<Db> createInstance() => throw '';
}
''',
      at: 'Db({',
      fixKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

abstract class Base implements Service {
  final int retries;
  const Base({this.retries = 3});
}

class Db({super.retries, final host = const Config<String>('host')}) extends Base {
  static const defaultHost = 'localhost';

  final timeout = const Duration(seconds: 1);

  @override
  ServiceInstance<Db> createInstance() => throw '';
}
''',
    );
  }

  test_dataClass_dropsBody() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends $Person {
  @Id()
  final int id;
  final String name;
  final List<String> tags;

  const Person({this.id = 0, required this.name, this.tags = const []});
}
''',
      at: 'Person({',
      fixKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class const Person({@Id() final int id = 0, required final String name, final List<String> tags = const []}) extends $Person;
''',
    );
  }

  test_dataClass_positionalParameters() async {
    await assertFix(
      r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Point extends $Point {
  final int x;
  final int y;
  final int? z;

  const Point(this.x, this.y, [this.z]);

  int get sum => x + y + (z ?? 0);
}
''',
      at: 'Point(this',
      fixKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class const Point(final int x, final int y, [final int? z]) extends $Point {
  int get sum => x + y + (z ?? 0);
}
''',
    );
  }
}

@reflectiveTest
class MoveSuperInitializeFirstFixTest extends PluginTestBase {
  test_movesSuperCallToTop() async {
    await assertFix(
      _instance('''  @override
  Future<void> initialize() async {
    print('before');
    await super.initialize();
  }'''),
      at: 'await super.initialize();',
      fixKindId: 'datahub.fix.moveSuperInitializeFirst',
      expected: _instance('''  @override
  Future<void> initialize() async {
    await super.initialize();
    print('before');
  }'''),
    );
  }

  test_movesPastSeveralStatements() async {
    await assertFix(
      _instance('''  @override
  Future<void> initialize() async {
    print('one');
    print('two');
    await super.initialize();
    print('three');
  }'''),
      at: 'await super.initialize();',
      fixKindId: 'datahub.fix.moveSuperInitializeFirst',
      expected: _instance('''  @override
  Future<void> initialize() async {
    await super.initialize();
    print('one');
    print('two');
    print('three');
  }'''),
    );
  }
}

@reflectiveTest
class MoveSuperDisposeLastFixTest extends PluginTestBase {
  test_movesSuperCallToBottom() async {
    await assertFix(
      _instance('''  @override
  Future<void> dispose() async {
    await super.dispose();
    print('after');
  }'''),
      at: 'await super.dispose();',
      fixKindId: 'datahub.fix.moveSuperDisposeLast',
      expected: _instance('''  @override
  Future<void> dispose() async {
    print('after');
    await super.dispose();
  }'''),
    );
  }
}
