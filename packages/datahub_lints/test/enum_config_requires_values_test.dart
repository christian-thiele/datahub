import 'package:datahub_lints/src/rules/config/enum_config_requires_values.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(EnumConfigRequiresValuesTest);
  });
}

@reflectiveTest
class EnumConfigRequiresValuesTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = EnumConfigRequiresValuesRule();
    super.setUp();
  }

  test_enumConfigWithoutValues_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode>('mode');
''';
    await assertDiagnostics(content, [lintOn(content, "Config<Mode>('mode')")]);
  }

  test_nullableEnumConfigWithoutValues_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode?>('mode');
''';
    await assertDiagnostics(content, [
      lintOn(content, "Config<Mode?>('mode')"),
    ]);
  }

  test_emptyValues_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode>('mode', values: []);
''';
    await assertDiagnostics(content, [
      lintOn(content, "Config<Mode>('mode', values: [])"),
    ]);
  }

  test_withValues_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode>('mode', values: Mode.values);
''');
  }

  test_configValueFactory_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

enum Mode { fast, slow }

const config = Config<Mode>.value(Mode.fast);
''');
  }

  test_nonEnumConfig_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const config = Config<String>('host');
''');
  }
}
