import 'package:datahub_lints/src/rules/aperture/relation_requires_relation_id.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';
import 'util/stubs.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RelationRequiresRelationIdTest);
  });
}

@reflectiveTest
class RelationRequiresRelationIdTest extends DatahubRuleTest {
  @override
  Map<String, String> get extraStubs => {'datahub_aperture': apertureStub};

  @override
  void setUp() {
    rule = RelationRequiresRelationIdRule();
    super.setUp();
  }

  test_missingRelationId_isReported() async {
    const content = '''
import 'package:datahub_aperture/datahub_aperture.dart';

class Todo {
  final int ownerId;
  const Todo(this.ownerId);
}

@ApertureRelation<Todo>()
class Person {
  const Person();
}
''';
    await assertDiagnostics(content, [
      lintOn(content, '@ApertureRelation<Todo>()'),
    ]);
  }

  test_relationIdToOtherClass_isReported() async {
    const content = '''
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

class Other {
  const Other();
}

class Todo {
  @RelationId<Other>()
  final int otherId;
  const Todo(this.otherId);
}

@ApertureRelation<Todo>()
class Person {
  const Person();
}
''';
    await assertDiagnostics(content, [
      lintOn(content, '@ApertureRelation<Todo>()'),
    ]);
  }

  test_withRelationId_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

class Todo {
  @RelationId<Person>()
  final int ownerId;
  const Todo(this.ownerId);
}

@ApertureRelation<Todo>()
class Person {
  const Person();
}
''');
  }

  test_withoutRelation_isNotReported() async {
    await assertNoDiagnostics('''
import 'package:datahub_aperture/datahub_aperture.dart';

const relation = ApertureRelation<Object>();

class Person {
  const Person();
}
''');
  }
}
