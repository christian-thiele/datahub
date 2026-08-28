import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/plugin_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseInstanceFindFixTest);
  });
}

@reflectiveTest
class UseInstanceFindFixTest extends PluginTestBase {
  static const _fixKind = 'datahub.fix.useInstanceFind';

  test_rewritesFieldReceiver() async {
    await assertFix(
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
      at: 'other.find()',
      fixKindId: _fixKind,
      expected: r'''
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
''',
    );
  }

  test_rewritesFindLiteralReceiver() async {
    await assertFix(
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
      at: 'Find<Db>().find()',
      fixKindId: _fixKind,
      expected: r'''
import 'package:datahub/datahub.dart';

class Db implements Service {
  const Db();
  @override
  ServiceInstance createInstance() => DbInstance();
}

class DbInstance extends ServiceInstance<Db> {
  void doWork() {
    find(Find<Db>());
  }
}
''',
    );
  }
}
