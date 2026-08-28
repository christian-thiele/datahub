import 'package:datahub_lints/src/rules/scaffold/avoid_injection_in_initializer.dart';
import 'package:datahub_lints/src/rules/scaffold/avoid_zone_context_in_service.dart';
import 'package:datahub_lints/src/rules/scaffold/await_lifecycle_super.dart';
import 'package:datahub_lints/src/rules/scaffold/const_service_constructor.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidZoneContextInServiceTest);
    defineReflectiveTests(AwaitLifecycleSuperTest);
    defineReflectiveTests(AvoidInjectionInInitializerTest);
    defineReflectiveTests(ConstServiceConstructorTest);
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
class AvoidZoneContextInServiceTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = AvoidZoneContextInServiceRule();
    super.setUp();
  }

  test_zoneFind_isReported() async {
    final content = _instance('''
  void doWork() {
    Context.zoneFind(const Find<Db>());
  }''');
    await assertDiagnostics(content, [
      lintOn(content, 'Context.zoneFind(const Find<Db>())'),
    ]);
  }

  test_ofZoneFind_reportsWholeChain() async {
    final content = _instance('''
  void doWork() {
    Context.ofZone().find(const Find<Db>());
  }''');
    await assertDiagnostics(content, [
      lintOn(content, 'Context.ofZone().find(const Find<Db>())'),
    ]);
  }

  test_bareOfZone_isReported() async {
    final content = _instance('''
  void doWork() {
    Context.ofZone();
  }''');
    await assertDiagnostics(content, [lintOn(content, 'Context.ofZone()')]);
  }

  test_outsideServiceInstance_isNotReported() async {
    await assertNoDiagnostics(r'''
import 'package:datahub/datahub.dart';

class Routes extends ApiNode {
  const Routes();

  @override
  List<Object> buildRoutes() => [Context.ofZone()];
}
''');
  }
}

@reflectiveTest
class AwaitLifecycleSuperTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = AwaitLifecycleSuperRule();
    super.setUp();
  }

  test_unawaitedInitialize_isReported() async {
    final content = _instance('''
  @override
  Future<void> initialize() async {
    super.initialize();
  }''');
    await assertDiagnostics(content, [lintOn(content, 'super.initialize()')]);
  }

  test_unawaitedDispose_isReported() async {
    final content = _instance('''
  @override
  Future<void> dispose() async {
    super.dispose();
  }''');
    await assertDiagnostics(content, [lintOn(content, 'super.dispose()')]);
  }

  test_awaited_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> initialize() async {
    await super.initialize();
  }'''),
    );
  }

  test_returned_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> initialize() => super.initialize();'''),
    );
  }

  test_outsideServiceInstance_isNotReported() async {
    await assertNoDiagnostics(r'''
class Base {
  Future<void> initialize() async {}
}

class Child extends Base {
  @override
  Future<void> initialize() async {
    super.initialize();
  }
}
''');
  }
}

@reflectiveTest
class AvoidInjectionInInitializerTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = AvoidInjectionInInitializerRule();
    super.setUp();
  }

  test_findInConstructorBody_isReported() async {
    final content = _instance('''
  Object? other;

  DbInstance() {
    other = find(const Find<Db>());
  }''');
    await assertDiagnostics(content, [
      lintOn(content, 'find(const Find<Db>())'),
    ]);
  }

  test_contextInConstructorBody_isReported() async {
    final content = _instance('''
  DbInstance() {
    print(context);
  }''');
    await assertDiagnostics(content, [lintOn(content, 'context')]);
  }

  test_lateFieldInitializer_isNotReported() async {
    await assertNoDiagnostics(
      _instance('  late final Object other = find(const Find<Db>());'),
    );
  }

  test_closureInConstructor_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  Object Function()? later;

  DbInstance() {
    later = () => find(const Find<Db>());
  }'''),
    );
  }

  test_inMethod_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  Object doWork() => find(const Find<Db>());'''),
    );
  }
}

@reflectiveTest
class ConstServiceConstructorTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ConstServiceConstructorRule();
    super.setUp();
  }

  test_nonConstConstructor_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

class Db implements Service {
  Db();
  @override
  ServiceInstance createInstance() => throw '';
}
''';
    await assertDiagnostics(content, [lintOn(content, 'Db();', length: 2)]);
  }

  test_implicitConstructor_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

class Db implements Service {
  @override
  ServiceInstance createInstance() => throw '';
}
''';
    await assertDiagnostics(content, [lintOn(content, 'Db')]);
  }

  test_constConstructor_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => throw '';
}
''');
  }

  test_nonService_isNotReported() async {
    await assertNoDiagnostics('''
class Plain {
  Plain();
}
''');
  }
}
