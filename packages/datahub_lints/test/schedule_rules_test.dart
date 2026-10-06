import 'package:datahub_lints/src/rules/scheduler/schedule_rules.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';
import 'util/stubs.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ScheduleRequiresNameTest);
    defineReflectiveTests(ScheduleRequiresPositiveIntervalTest);
    defineReflectiveTests(ScheduleTimeOutOfRangeTest);
    defineReflectiveTests(DuplicateScheduleNameTest);
  });
}

/// A library declaring [components].
String _source(String components) =>
    '''
import 'package:datahub/datahub.dart';

Future<void> run(Object context) async {}

int minutes() => 1;

const empty = '';

final components = [
$components
];
''';

@reflectiveTest
class ScheduleRequiresNameTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ScheduleRequiresNameRule();
    super.setUp();
  }

  test_named_isNotReported() async {
    await assertNoDiagnostics(_source("  Schedule.daily('cleanup', run),"));
  }

  test_emptyName_isReported() async {
    final content = _source("  Schedule.daily('', run),");
    await assertDiagnostics(content, [lint(content.lastIndexOf("''"), 2)]);
  }

  test_emptyConstantName_isReported() async {
    final content = _source(
      '  Schedule.every(empty, run, interval: Duration(minutes: 1)),',
    );
    await assertDiagnostics(content, [
      lintOn(content, 'empty, run', length: 'empty'.length),
    ]);
  }
}

@reflectiveTest
class ScheduleRequiresPositiveIntervalTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ScheduleRequiresPositiveIntervalRule();
    super.setUp();
  }

  test_positive_isNotReported() async {
    await assertNoDiagnostics(
      _source("  Schedule.every('a', run, interval: Duration(minutes: 10)),"),
    );
  }

  test_computed_isNotReported() async {
    await assertNoDiagnostics(
      _source(
        "  Schedule.every('a', run, "
        'interval: Duration(minutes: minutes())),',
      ),
    );
  }

  test_zero_isReported() async {
    final content = _source(
      "  Schedule.every('a', run, interval: Duration(seconds: 0)),",
    );
    await assertDiagnostics(content, [lintOn(content, 'Duration(seconds: 0)')]);
  }

  test_negative_isReported() async {
    final content = _source(
      "  Schedule.every('a', run, interval: Duration(seconds: -5)),",
    );
    await assertDiagnostics(content, [
      lintOn(content, 'Duration(seconds: -5)'),
    ]);
  }

  test_constZero_isReported() async {
    final content = _source(
      "  Schedule.every('a', run, interval: const Duration(hours: 1, minutes: -60)),",
    );
    await assertDiagnostics(content, [
      lintOn(content, 'const Duration(hours: 1, minutes: -60)'),
    ]);
  }
}

@reflectiveTest
class ScheduleTimeOutOfRangeTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ScheduleTimeOutOfRangeRule();
    super.setUp();
  }

  test_validTimes_areNotReported() async {
    await assertNoDiagnostics(
      _source('''
  Schedule.daily('a', run, hour: 23, minute: 59),
  Schedule.monthly('b', run, day: 31, hour: 0, minute: 0),
  Schedule.monthly('c', run),'''),
    );
  }

  test_hour_isReported() async {
    final content = _source("  Schedule.daily('a', run, hour: 24),");
    await assertDiagnostics(content, [
      lint(
        offsetOf(content, '24'),
        2,
        messageContainsAll: ["'hour' must be between 0 and 23, but is 24"],
      ),
    ]);
  }

  test_minute_isReported() async {
    final content = _source("  Schedule.daily('a', run, minute: -1),");
    await assertDiagnostics(content, [lintOn(content, '-1')]);
  }

  test_day_isReported() async {
    final content = _source("  Schedule.monthly('a', run, day: 0, hour: 99),");
    await assertDiagnostics(content, [
      lint(offsetOf(content, 'day: 0') + 'day: '.length, 1),
      lintOn(content, '99'),
    ]);
  }
}

@reflectiveTest
class DuplicateScheduleNameTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = DuplicateScheduleNameRule();
    super.setUp();
  }

  test_uniqueNames_areNotReported() async {
    await assertNoDiagnostics(
      _source('''
  Schedule.daily('a', run),
  Schedule.daily('b', run),'''),
    );
  }

  test_duplicateName_isReported() async {
    final content = _source('''
  Schedule.daily('a', run),
  Schedule.every('a', run, interval: Duration(minutes: 1)),''');
    await assertDiagnostics(content, [
      lint(
        content.lastIndexOf("'a'"),
        3,
        messageContainsAll: ["schedule named 'a'"],
      ),
    ]);
  }
}
