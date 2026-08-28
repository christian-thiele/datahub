import 'package:datahub_lints/src/rules/scaffold/lifecycle_super_position.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SuperInitializeFirstTest);
    defineReflectiveTests(SuperDisposeLastTest);
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
class SuperInitializeFirstTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = SuperInitializeFirstRule();
    super.setUp();
  }

  test_superCallNotFirst_isReported() async {
    final content = _instance('''
  @override
  Future<void> initialize() async {
    print('before');
    await super.initialize();
  }''');
    await assertDiagnostics(content, [
      lintOn(content, 'await super.initialize();'),
    ]);
  }

  test_superCallFirst_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> initialize() async {
    await super.initialize();
    print('after');
  }'''),
    );
  }

  test_onlyStatement_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> initialize() async {
    await super.initialize();
  }'''),
    );
  }

  test_expressionBody_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> initialize() => super.initialize();'''),
    );
  }

  test_nestedSuperCall_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> initialize() async {
    if (identical(0, 0)) {
      await super.initialize();
    }
  }'''),
    );
  }

  test_disposeIsNotAffected() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> dispose() async {
    print('before');
    await super.dispose();
  }'''),
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
    print('before');
    await super.initialize();
  }
}
''');
  }
}

@reflectiveTest
class SuperDisposeLastTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = SuperDisposeLastRule();
    super.setUp();
  }

  test_superCallNotLast_isReported() async {
    final content = _instance('''
  @override
  Future<void> dispose() async {
    await super.dispose();
    print('after');
  }''');
    await assertDiagnostics(content, [
      lintOn(content, 'await super.dispose();'),
    ]);
  }

  test_superCallLast_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> dispose() async {
    print('before');
    await super.dispose();
  }'''),
    );
  }

  test_onlyStatement_isNotReported() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> dispose() async {
    await super.dispose();
  }'''),
    );
  }

  test_initializeIsNotAffected() async {
    await assertNoDiagnostics(
      _instance('''
  @override
  Future<void> initialize() async {
    await super.initialize();
    print('after');
  }'''),
    );
  }
}
