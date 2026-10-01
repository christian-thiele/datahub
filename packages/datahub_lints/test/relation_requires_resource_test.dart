import 'package:datahub_lints/src/rules/aperture/relation_requires_resource.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';
import 'util/stubs.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RelationRequiresResourceTest);
  });
}

@reflectiveTest
class RelationRequiresResourceTest extends DatahubRuleTest {
  @override
  Map<String, String> get extraStubs => {'datahub_aperture': apertureStub};

  @override
  void setUp() {
    rule = RelationRequiresResourceRule();
    super.setUp();
  }

  static const _classes = '''
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

class DeviceUser {
  const DeviceUser();
}

@ApertureRelation<DeviceUser>()
class Tenant {
  const Tenant();
}
''';

  test_missingResource_isReported() async {
    const content =
        '''
$_classes
const api = ApertureApi(
  resources: [
    ApertureResource(repository: Find<DataRepository<Tenant>>()),
  ],
);
''';
    await assertDiagnostics(content, [
      lintOn(
        content,
        'ApertureResource(repository: Find<DataRepository<Tenant>>())',
      ),
    ]);
  }

  test_registeredResource_isNotReported() async {
    await assertNoDiagnostics('''
$_classes
const api = ApertureApi(
  resources: [
    ApertureResource(repository: Find<DataRepository<Tenant>>()),
    ApertureResource(repository: Find<DataRepository<DeviceUser>>()),
  ],
);
''');
  }

  test_unresolvableResources_areNotReported() async {
    await assertNoDiagnostics('''
$_classes
const others = <ApertureResource>[];

const api = ApertureApi(
  resources: [
    ApertureResource(repository: Find<DataRepository<Tenant>>()),
    ...others,
  ],
);
''');
  }
}
