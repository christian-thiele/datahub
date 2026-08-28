import 'package:datahub_lints/src/rules/config/config_requires_default.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConfigRequiresDefaultTest);
    defineReflectiveTests(ConfigRequiresDefaultWithoutFileTest);
  });
}

@reflectiveTest
class ConfigRequiresDefaultTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ConfigRequiresDefaultRule();
    super.setUp();
    writeDefaults('''
host: localhost
aperture:
  title: Aperture
nested:
  deeply:
    value: 1
''');
  }

  test_undeclaredPath_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

const config = Config<String>('port');
''';
    await assertDiagnostics(content, [
      lintOn(content, "Config<String>('port')"),
    ]);
  }

  test_declaredPath_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const config = Config<String>('host');
''');
  }

  test_declaredNestedPath_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const config = Config<String>('aperture.title');
''');
  }

  test_deeplyNestedPath_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const config = Config<int>('nested.deeply.value');
''');
  }

  test_partialNestedPath_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

const config = Config<String>('aperture.basePath');
''';
    await assertDiagnostics(content, [
      lintOn(content, "Config<String>('aperture.basePath')"),
    ]);
  }

  test_withDefaultValue_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const config = Config<String>('port', defaultValue: '5432');
''');
  }

  test_configValueFactory_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const config = Config<String>.value('literal');
''');
  }

  test_inTestDirectory_isNotReported() async {
    // Tests supply configuration programmatically, so defaults.yaml has no
    // say over the paths they declare.
    newFile('$testPackageRootPath/test/some_test.dart', '''
import 'package:datahub/datahub.dart';

const config = Config<String>('nowhere.at.all');
''');
    await assertNoDiagnosticsInFile('$testPackageRootPath/test/some_test.dart');
  }

  test_computedPath_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const prefix = 'db';
const config = Config<String>('\$prefix.port');
''');
  }
}

@reflectiveTest
class ConfigRequiresDefaultWithoutFileTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ConfigRequiresDefaultRule();
    super.setUp();
  }

  test_packageWithoutDefaultsFile_reportsNothing() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const config = Config<String>('anything.at.all');
''');
  }
}
