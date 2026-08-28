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
