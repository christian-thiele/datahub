import 'package:datahub_lints/src/rules/data/data_class_rules.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DataClassRequiresPartTest);
    defineReflectiveTests(DataClassExtendsGeneratedTest);
    defineReflectiveTests(DataClassConstConstructorTest);
  });
}

@reflectiveTest
class DataClassRequiresPartTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = DataClassRequiresPartRule();
    super.setUp();
    writeGeneratedPart(r'''
class $Person {
  const $Person();
}
''');
  }

  test_missingPart_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

@Data()
class Person {
  const Person();
}
''';
    await assertDiagnostics(content, [lintOn(content, 'Person {', length: 6)]);
  }

  test_withPart_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends \$Person {
  const Person();
}
''');
  }

  test_withoutAnnotation_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

const finder = Find<Object>();

class Person {
  const Person();
}
''');
  }
}

@reflectiveTest
class DataClassExtendsGeneratedTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = DataClassExtendsGeneratedRule();
    super.setUp();
    writeGeneratedPart(r'''
class $Person {
  const $Person();
}
''');
  }

  test_missingSuperclass_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person {
  const Person();
}
''';
    await assertDiagnostics(content, [lintOn(content, 'Person {', length: 6)]);
  }

  test_wrongSuperclass_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

class Other {
  const Other();
}

@Data()
class Person extends Other {
  const Person();
}
''';
    await assertDiagnostics(content, [
      lintOn(content, 'Person extends', length: 6),
    ]);
  }

  test_correctSuperclass_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends \$Person {
  const Person();
}
''');
  }
}

@reflectiveTest
class DataClassConstConstructorTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = DataClassConstConstructorRule();
    super.setUp();
    writeGeneratedPart(r'''
class $Person {
  const $Person();
}
''');
  }

  test_noConstructor_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends \$Person {
  final String name = '';
}
''';
    await assertDiagnostics(content, [
      lintOn(content, 'Person extends', length: 6),
    ]);
  }

  test_nonConstConstructor_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends \$Person {
  final String name;
  Person({required this.name});
}
''';
    await assertDiagnostics(content, [
      lintOn(content, 'Person extends', length: 6),
    ]);
  }

  test_positionalParameter_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends \$Person {
  final String name;
  const Person(this.name);
}
''';
    await assertDiagnostics(content, [lintOn(content, 'this.name')]);
  }

  test_namedConstConstructor_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';

part 'test.g.dart';

@Data()
class Person extends \$Person {
  final String name;
  const Person({required this.name});
}
''');
  }
}
