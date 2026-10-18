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

  test_primaryConstructorWithoutBody() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class const Db() implements Service;
''',
      at: 'Db()',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class const Db() implements Service {
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

  test_primaryConstructor_opensNamedSection() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class const Db() implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db()',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class const Db({final dependency = const Find<Dependency>()}) implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
    );
  }

  test_primaryConstructor_appendsToNamedSection() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class const Db({
  final host = const Config<String>('host'),
}) implements Service {
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
      at: 'Db({',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class const Db({
  final host = const Config<String>('host'),
  final dependency = const Find<Dependency>(),
}) implements Service {
  @override
  ServiceInstance<Db> createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  late final Dependency dependency;
  @override
  Future<void> initialize() async {
    await super.initialize();
    dependency = find(service.dependency);
  }
}
''',
    );
  }

  test_noConstructor_declaresPrimaryConstructor() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db implements',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class const Db({final dependency = const Find<Dependency>()}) implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
    );
  }

  test_noConstructorBeforePrimaryConstructors_isNotOffered() async {
    await assertNoAssist(
      r'''
// @dart=3.9
import 'package:datahub/datahub.dart';

class Db implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''',
      at: 'Db implements',
      assistKindId: _kind,
    );
  }

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

  test_injectsIntoExistingInitialize() async {
    await assertAssist(
      r'''
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
      at: 'Db implements',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  final Find<Dependency> dependency;
  const Db({this.dependency = const Find()});
  @override
  ServiceInstance<Db> createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  late final Dependency dependency;
  @override
  Future<void> initialize() async {
    await super.initialize();
    dependency = find(service.dependency);
  }
}
''',
    );
  }

  test_addsInitializeWhenMissing() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance<Db> createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  final int x = 0;
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
  ServiceInstance<Db> createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  final int x = 0;
  late final Dependency dependency;

  @override
  Future<void> initialize() async {
    await super.initialize();
    dependency = find(service.dependency);
  }
}
''',
    );
  }
}

@reflectiveTest
class ConvertToDataClassTest extends PluginTestBase {
  static const _kind = 'datahub.assist.convertToDataClass';

  test_declaresFieldsInPrimaryConstructor() async {
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
class const Person({required final String name, final int? age}) extends $Person;
''',
    );
  }

  test_convertsExistingConstructor() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class Person {
  /// The id.
  @Id()
  final int id;
  final String name;

  Person({
    this.id = 0,
    required this.name,
  });

  String get greeting => 'Hi $name';
}
''',
      at: 'Person {',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class const Person({
  /// The id.
  @Id() final int id = 0,
  required final String name,
}) extends $Person {
  String get greeting => 'Hi $name';
}
''',
    );
  }

  test_completesExistingPrimaryConstructor() async {
    await assertAssist(
      r'''
import 'package:datahub/datahub.dart';

class Person(final String name);
''',
      at: 'Person(',
      assistKindId: _kind,
      expected: r'''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class const Person(final String name) extends $Person;
''',
    );
  }

  test_classicConstructorBeforePrimaryConstructors() async {
    await assertAssist(
      r'''
// @dart=3.9
import 'package:datahub/datahub.dart';

class Person {
  final String name;
  final int? age;
}
''',
      at: 'Person {',
      assistKindId: _kind,
      expected: r'''
// @dart=3.9
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
