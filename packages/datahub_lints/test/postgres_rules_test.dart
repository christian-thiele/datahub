import 'package:datahub_lints/src/rules/postgres/repository_requires_super_initialize.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';
import 'util/stubs.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RepositoryRequiresSuperInitializeTest);
  });
}

@reflectiveTest
class RepositoryRequiresSuperInitializeTest extends DatahubRuleTest {
  @override
  Map<String, String> get extraStubs => {'datahub_postgres': postgresStub};

  @override
  void setUp() {
    rule = RepositoryRequiresSuperInitializeRule();
    super.setUp();
  }

  /// A repository instance mixing in [PostgresqlDataRepository].
  static String _repository(String body) =>
      '''
import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

class Repo implements Service {
  const Repo();
  @override
  ServiceInstance createInstance() => RepoInstance();
}

class RepoInstance extends ServiceInstance<Repo>
    with PostgresqlDataRepository<Repo, Object> {
$body
}
''';

  test_missingSuperCall_isReported() async {
    final content = _repository('''
  @override
  Future<void> initialize() async {
    print('ready');
  }''');
    await assertDiagnostics(content, [
      lintOn(content, 'initialize() async', length: 10),
    ]);
  }

  test_awaitedSuperCall_isNotReported() async {
    await assertNoDiagnostics(
      _repository('''
  @override
  Future<void> initialize() async {
    await super.initialize();
    print('ready');
  }'''),
    );
  }

  test_superCallInsideBranch_isNotReported() async {
    await assertNoDiagnostics(
      _repository('''
  @override
  Future<void> initialize() async {
    if (identical(0, 0)) {
      await super.initialize();
    }
  }'''),
    );
  }

  test_noOverride_isNotReported() async {
    await assertNoDiagnostics(_repository('  Object? extra;'));
  }

  test_withoutMixin_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

class Repo implements Service {
  const Repo();
  @override
  ServiceInstance createInstance() => RepoInstance();
}

class RepoInstance extends ServiceInstance<Repo> {
  @override
  Future<void> initialize() async {
    print('ready');
  }
}
''');
  }
}
