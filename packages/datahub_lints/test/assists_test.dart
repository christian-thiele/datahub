import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/plugin_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(GenerateServiceInstanceTest);
    defineReflectiveTests(AddFindInjectionTest);
    defineReflectiveTests(ConvertToDataClassTest);
  });
}

@reflectiveTest
class GenerateServiceInstanceTest extends PluginTestBase {
  static const _kind = 'datahub.assist.generateServiceInstance';

  test_generatesPair() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
}
''',
      at: 'Db implements',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();

  @override
  ServiceInstance<Db> createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
''',
    );
  }

  test_notOfferedWhenAlreadyPresent() async {
    await assertNoAssist(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db implements',
      assistKindId: _kind,
    );
  }

  test_notOfferedOnNonService() async {
    await assertNoAssist(
      r'''
class Plain {
  const Plain();
}
''',
      at: 'Plain {',
      assistKindId: _kind,
    );
  }
}

@reflectiveTest
class AddFindInjectionTest extends PluginTestBase {
  static const _kind = 'datahub.assist.addFindInjection';

  test_opensNamedSectionWhenEmpty() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db implements',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Find<Dependency> dependency;
  const Db({this.dependency = const Find()});
  @override
  ServiceInstance createInstance() => throw '';
}
''',
    );
  }

  test_appendsToExistingNamedSection() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Config<String> host;
  const Db({this.host = const Config('host')});
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db implements',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Config<String> host;
  final Find<Dependency> dependency;
  const Db({this.host = const Config('host'), this.dependency = const Find()});
  @override
  ServiceInstance createInstance() => throw '';
}
''',
    );
  }
}

@reflectiveTest
class ConvertToDataClassTest extends PluginTestBase {
  static const _kind = 'datahub.assist.convertToDataClass';

  test_addsAnnotationSuperclassPartAndConstructor() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class Person {
  final String name;
  final int? age;
}
''',
      at: 'Person {',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends $Person {
  const Person({
    required this.name,
    this.age,
  });

  final String name;
  final int? age;
}
''',
    );
  }

  test_notOfferedOnExistingDataClass() async {
    await assertNoAssist(
      r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends $Person {
  const Person();
}
''',
      at: 'Person extends',
      assistKindId: _kind,
    );
  }
}
