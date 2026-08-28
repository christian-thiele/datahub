import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:datahub_lints/src/rules/scaffold/prefer_instance_accessor.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/stubs.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferInstanceFindTest);
    defineReflectiveTests(PreferInstanceReadTest);
  });
}

@reflectiveTest
class PreferInstanceFindTest extends AnalysisRuleTest {
  @override
  void setUp() {
    addDatahubStub(this);
    rule = PreferInstanceFindRule();
    super.setUp();
  }

  test_findOnInjectedField_isReported() async {
    await assertDiagnostics(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  final Find<Db> other = const Find();

  void doWork() {
    other.find();
  }
}
''',
      [lint(260, 12)],
    );
  }

  test_findOnFindLiteral_isReported() async {
    await assertDiagnostics(
      r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  void doWork() {
    Find<Db>().find();
  }
}
''',
      [lint(220, 17)],
    );
  }

  test_findOutsideServiceInstance_isNotReported() async {
    await assertNoDiagnostics(r'''
import 'package:datahub/datahub.dart';

class Routes extends ApiNode {
  const Routes();

  @override
  List<Object> buildRoutes() => [Find<Object>().find()];
}
''');
  }

  test_instanceFind_isNotReported() async {
    await assertNoDiagnostics(r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  final Find<Db> other = const Find();

  void doWork() {
    find(other);
  }
}
''');
  }

  test_unrelatedFindMethod_isNotReported() async {
    await assertNoDiagnostics(r'''
import 'package:datahub/datahub.dart';

class Registry {
  Object find() => 0;
}

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  final Registry registry = Registry();

  void doWork() {
    registry.find();
  }
}
''');
  }
}

@reflectiveTest
class PreferInstanceReadTest extends AnalysisRuleTest {
  @override
  void setUp() {
    addDatahubStub(this);
    rule = PreferInstanceReadRule();
    super.setUp();
  }

  test_readOnConfigField_isReported() async {
    await assertDiagnostics(
      r"""
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  final Config<String> host = const Config('host');

  void doWork() {
    host.read();
  }
}
""",
      [lint(273, 11)],
    );
  }

  test_readOutsideServiceInstance_isNotReported() async {
    await assertNoDiagnostics(r"""
import 'package:datahub/datahub.dart';

class Routes extends ApiNode {
  const Routes();

  @override
  List<Object> buildRoutes() => [const Config<String>('base').read()];
}
""");
  }

  test_instanceRead_isNotReported() async {
    await assertNoDiagnostics(r"""
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  final Config<String> host = const Config('host');

  void doWork() {
    read(host);
  }
}
""");
  }
}
