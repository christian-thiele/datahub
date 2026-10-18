import 'package:datahub_lints/src/rules/prefer_primary_constructor.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferPrimaryConstructorTest);
  });
}

@reflectiveTest
class PreferPrimaryConstructorTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = PreferPrimaryConstructorRule();
    super.setUp();
    writeGeneratedPart(r'''
class $Person {
  const $Person();
}
''');
  }

  test_serviceWithClassicConstructor_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Find<Object> other;
  final Config<String> host;

  const Db({this.other = const Find(), this.host = const Config('host')});

  @override
  ServiceInstance createInstance() => throw '';
}
''';
    await assertDiagnostics(content, [lintOn(content, 'Db({', length: 2)]);
  }

  test_dataClassWithClassicConstructor_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends \$Person {
  final String name;

  const Person({required this.name});
}
''';
    await assertDiagnostics(content, [lintOn(content, 'Person({', length: 6)]);
  }

  test_primaryConstructor_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class const Person({required final String name}) extends \$Person;

class const Db({final other = const Find<Object>()}) implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''');
  }

  test_constructorWithBody_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Config<String> host;

  Db({this.host = const Config('host')}) {
    print(host);
  }

  @override
  ServiceInstance createInstance() => throw '';
}
''');
  }

  test_constructorWithInitializer_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Config<String> host;
  final int retries;

  const Db({this.host = const Config('host')}) : retries = 3;

  @override
  ServiceInstance createInstance() => throw '';
}
''');
  }

  test_partlyInitializedDeclaration_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Config<String> host, port;

  const Db(this.host) : port = const Config('port');

  @override
  ServiceInstance createInstance() => throw '';
}
''');
  }

  test_implicitConstructor_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

class Db implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''');
  }

  test_plainClass_isNotReported() async {
    await assertNoDiagnostics('''
class Plain {
  final int x;

  const Plain(this.x);
}
''');
  }

  test_beforePrimaryConstructors_isNotReported() async {
    await assertNoDiagnostics('''
// @dart=3.9
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Config<String> host;

  const Db({this.host = const Config('host')});

  @override
  ServiceInstance createInstance() => throw '';
}
''');
  }
}
