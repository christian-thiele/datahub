import 'package:datahub_lints/src/rules/data/reducible_filter_group.dart';
import 'package:datahub_lints/src/rules/data/reducible_sort_group.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/rule_test_base.dart';
import 'util/stubs.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ReducibleFilterGroupTest);
    defineReflectiveTests(ReducibleSortGroupTest);
    defineReflectiveTests(ConstantFilterGroupTest);
  });
}

@reflectiveTest
class ReducibleFilterGroupTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ReducibleFilterGroupRule();
    super.setUp();
  }

  static const _header = "import 'package:datahub/datahub.dart';\n\n";

  Future<void> _reported(String expression, {String? snippet}) async {
    final content =
        '${_header}void f(Filter a, Filter b, Filter c) {\n'
        '  $expression;\n}\n';
    await assertDiagnostics(content, [lintOn(content, snippet ?? expression)]);
  }

  Future<void> _clean(String expression) => assertNoDiagnostics(
    '${_header}void f(Filter a, Filter b, Filter c) {\n  $expression;\n}\n',
  );

  test_emptyGroup() => _reported('Filter.andGroup([])');

  test_singleElement() => _reported('Filter.orGroup([a])');

  test_singleElementConstructor() => _reported('FilterGroup([a], true)');

  test_emptyInAnd() => _reported('Filter.andGroup([a, Filter.empty])');

  test_emptyConstructorInAnd() =>
      _reported('Filter.andGroup([a, const EmptyFilter()])');

  test_nothingInOr() => _reported('Filter.orGroup([a, Filter.nothing])');

  test_nestedSamePolarity() =>
      _reported('Filter.andGroup([a, Filter.andGroup([b, c])])');

  test_nestedAndMethodSamePolarity() =>
      _reported('Filter.andGroup([a, b.and(c)])');

  test_nestedConstructorSamePolarity() =>
      _reported('FilterGroup([a, FilterGroup([b, c], true)], true)');

  test_binaryWithEmpty() => _reported('a.and(Filter.empty)');

  test_binaryOrWithNothing() => _reported('a.or(Filter.nothing)');

  test_nestedOppositePolarity_isNotReported() =>
      _clean('Filter.andGroup([a, Filter.orGroup([b, c])])');

  test_chainedAnd_isNotReported() => _clean('a.and(b).and(c)');

  test_absorbingOperand_isLeftToConstantRule() =>
      _clean('Filter.orGroup([a, Filter.empty])');

  test_singleAbsorbingOperand() => _reported('Filter.orGroup([Filter.empty])');

  test_plainGroup_isNotReported() => _clean('Filter.andGroup([a, b])');

  test_collectionElements_areNotReported() =>
      _clean('Filter.andGroup([if (true) a])');

  test_spread_isNotReported() => _clean('Filter.andGroup([...[a]])');

  test_nonLiteralList_isNotReported() => assertNoDiagnostics(
    "${_header}void f(List<Filter> filters) {\n  Filter.andGroup(filters);\n}\n",
  );
}

@reflectiveTest
class ReducibleSortGroupTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ReducibleSortGroupRule();
    super.setUp();
  }

  static const _header = "import 'package:datahub/datahub.dart';\n\n";

  Future<void> _reported(String expression) async {
    final content =
        '${_header}void f(Sort a, Sort b, Sort c) {\n'
        '  $expression;\n}\n';
    await assertDiagnostics(content, [lintOn(content, expression)]);
  }

  Future<void> _clean(String expression) => assertNoDiagnostics(
    '${_header}void f(Sort a, Sort b, Sort c) {\n  $expression;\n}\n',
  );

  test_emptyGroup() => _reported('Sort.followedBy([])');

  test_singleElement() => _reported('SortGroup([a])');

  test_emptyElement() => _reported('Sort.followedBy([a, Sort.empty])');

  test_emptyConstructorElement() =>
      _reported('SortGroup([a, const EmptySort()])');

  test_nestedGroup() => _reported('Sort.followedBy([a, SortGroup([b, c])])');

  test_plainGroup_isNotReported() => _clean('Sort.followedBy([a, b, c])');

  test_spread_isNotReported() => _clean('SortGroup([...[a]])');
}

@reflectiveTest
class ConstantFilterGroupTest extends DatahubRuleTest {
  @override
  void setUp() {
    rule = ConstantFilterGroupRule();
    super.setUp();
  }

  static const _header = "import 'package:datahub/datahub.dart';\n\n";

  Future<void> _reported(String expression, String operand) async {
    final content =
        '${_header}void f(Filter a, Filter b) {\n  $expression;\n}\n';
    await assertDiagnostics(content, [
      lint(
        offsetOf(content, expression) + expression.indexOf(operand),
        operand.length,
      ),
    ]);
  }

  Future<void> _clean(String expression) => assertNoDiagnostics(
    '${_header}void f(Filter a, Filter b) {\n  $expression;\n}\n',
  );

  test_emptyInOr() =>
      _reported('Filter.orGroup([a, Filter.empty])', 'Filter.empty');

  test_nothingInAnd() =>
      _reported('Filter.andGroup([a, Filter.nothing])', 'Filter.nothing');

  test_nothingConstructorInAnd() => _reported(
    'FilterGroup([a, const NothingFilter()], true)',
    'const NothingFilter()',
  );

  test_binaryOrWithEmpty() => _reported('a.or(Filter.empty)', 'Filter.empty');

  test_binaryAndWithNothing() =>
      _reported('a.and(Filter.nothing)', 'Filter.nothing');

  test_neutralOperand_isNotReported() =>
      _clean('Filter.andGroup([a, Filter.empty])');

  test_singleOperand_isNotReported() =>
      _clean('Filter.orGroup([Filter.empty])');
}
