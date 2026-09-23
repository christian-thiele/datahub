import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart';
import 'package:datahub_lints/src/rules/postgres/revisable_repository_rules.dart';
import 'package:datahub_lints/src/util/naming.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';
import 'util/stubs.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RevisableBeanRequiresIdTest);
    defineReflectiveTests(RevisableReservedColumnTest);
  });

  test('lowerSnakeCase matches the column names of datahub', () {
    expect(lowerSnakeCase('id'), 'id');
    expect(lowerSnakeCase('sysFrom'), 'sys_from');
    expect(lowerSnakeCase('sysIsDeleted'), 'sys_is_deleted');
    expect(lowerSnakeCase('HTTPStatus'), 'http_status');
    expect(lowerSnakeCase('address2Line'), 'address2_line');
  });
}

/// A data class with [fields], stored by [registration].
String _source(String fields, {String registration = _service}) =>
    '''
import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

@Data()
class Person {
$fields
}

const personBean = DataBean<Person>();

$registration
''';

const _service =
    'const repository = PostgresqlRevisableRepositoryService(bean: personBean);';

const _mixin = '''
class PersonService implements Service {
  const PersonService();

  @override
  ServiceInstance createInstance() => PersonRepository();
}

class PersonRepository extends ServiceInstance<PersonService>
    with PostgresqlRevisableRepository<PersonService, Person> {}
''';

abstract class _RevisableRuleTest extends DatahubRuleTest {
  @override
  Map<String, String> get extraStubs => {'datahub_postgres': postgresStub};

  /// Expects a diagnostic at the bean argument of the service.
  ExpectedDiagnostic atBean(
    String content, {
    List<Pattern> message = const [],
  }) => lint(
    offsetOf(content, 'bean: personBean') + 'bean: '.length,
    'personBean'.length,
    messageContainsAll: message,
  );

  /// Expects a diagnostic at the mixin application.
  ExpectedDiagnostic atMixin(String content) =>
      lintOn(content, 'PostgresqlRevisableRepository<PersonService, Person>');
}

@reflectiveTest
class RevisableBeanRequiresIdTest extends _RevisableRuleTest {
  @override
  void setUp() {
    rule = RevisableBeanRequiresIdRule();
    super.setUp();
  }

  test_intId_isNotReported() async {
    await assertNoDiagnostics(_source('  @Id(auto: true) int id = 0;'));
  }

  test_stringId_isNotReported() async {
    await assertNoDiagnostics(_source("  @Id() String id = '';"));
  }

  test_missingId_isReported() async {
    final content = _source('  int id = 0;');
    await assertDiagnostics(content, [
      atBean(content, message: ["'Person'"]),
    ]);
  }

  test_unsupportedIdType_isReported() async {
    final content = _source('  @Id() double id = 0;');
    await assertDiagnostics(content, [atBean(content)]);
  }

  test_nullableId_isReported() async {
    final content = _source('  @Id() int? id;');
    await assertDiagnostics(content, [atBean(content)]);
  }

  test_mixin_isReported() async {
    final content = _source('  int id = 0;', registration: _mixin);
    await assertDiagnostics(content, [atMixin(content)]);
  }

  test_mixinWithId_isNotReported() async {
    await assertNoDiagnostics(
      _source('  @Id() int id = 0;', registration: _mixin),
    );
  }

  test_genericMixin_isNotReported() async {
    await assertNoDiagnostics(
      _source(
        '  int id = 0;',
        registration: '''
class PersonService implements Service {
  const PersonService();

  @override
  ServiceInstance createInstance() => throw '';
}

class GenericRepository<T> extends ServiceInstance<PersonService>
    with PostgresqlRevisableRepository<PersonService, T> {}
''',
      ),
    );
  }

  test_nonRevisableRepository_isNotReported() async {
    await assertNoDiagnostics(
      _source(
        '  int id = 0;',
        registration:
            'const repository = '
            'PostgresqlDataRepositoryService(bean: personBean);',
      ),
    );
  }
}

@reflectiveTest
class RevisableReservedColumnTest extends _RevisableRuleTest {
  @override
  void setUp() {
    rule = RevisableReservedColumnRule();
    super.setUp();
  }

  test_reservedColumn_isReported() async {
    final content = _source('''
  @Id() int id = 0;
  DateTime? sysFrom;
''');
    await assertDiagnostics(content, [
      atBean(content, message: ["'sysFrom'", "'Person'", "'sys_from'"]),
    ]);
  }

  test_everyReservedColumn_isReported() async {
    final content = _source('''
  @Id() int id = 0;
  int sysVersion = 0;
  bool sysIsDeleted = false;
''');
    await assertDiagnostics(content, [
      atBean(content, message: ["'sys_version'"]),
      atBean(content, message: ["'sys_is_deleted'"]),
    ]);
  }

  test_mixin_isReported() async {
    final content = _source('''
  @Id() int id = 0;
  String sysCreator = '';
''', registration: _mixin);
    await assertDiagnostics(content, [atMixin(content)]);
  }

  test_otherColumns_areNotReported() async {
    await assertNoDiagnostics(
      _source('''
  @Id() int id = 0;
  String system = '';
  bool isDeleted = false;
  DateTime? from;
  static const sysVersion = 1;
'''),
    );
  }

  test_nonRevisableRepository_isNotReported() async {
    await assertNoDiagnostics(
      _source(
        '''
  @Id() int id = 0;
  DateTime? sysFrom;
''',
        registration:
            'const repository = '
            'PostgresqlDataRepositoryService(bean: personBean);',
      ),
    );
  }
}
