import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'util/plugin_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SimplifyQueryGroupFixTest);
    defineReflectiveTests(ConvertToFilterGroupAssistTest);
  });
}

String _filters(String expression) =>
    '''
import 'package:datahub/datahub.dart';

Filter f(Filter a, Filter b, Filter c, bool x) => $expression;
''';

String _sorts(String expression) =>
    '''
import 'package:datahub/datahub.dart';

Sort f(Sort a, Sort b, Sort c) => $expression;
''';

@reflectiveTest
class SimplifyQueryGroupFixTest extends PluginTestBase {
  static const _kind = 'datahub.fix.simplifyQueryGroup';

  @override
  List<String> get enabledLintRules => const [
    'reducible_filter_group',
    'reducible_sort_group',
  ];

  Future<void> _filter(String before, String after) => assertFix(
    _filters(before),
    at: before,
    fixKindId: _kind,
    expected: _filters(after),
  );

  test_emptyGroup() => _filter('Filter.andGroup([])', 'Filter.empty');

  test_emptyConstructorGroup() =>
      _filter('FilterGroup([], false)', 'Filter.empty');

  test_singleElement() => _filter('Filter.orGroup([a])', 'a');

  test_singleElement_parenthesizedAsTarget() =>
      _filter('Filter.andGroup([x ? a : b]).or(c)', '(x ? a : b).or(c)');

  test_removesEmptyInAnd() => _filter(
    'Filter.andGroup([a, Filter.empty, b])',
    'Filter.andGroup([a, b])',
  );

  test_removesNothingInOr() => _filter(
    'Filter.orGroup([a, const NothingFilter(), b])',
    'Filter.orGroup([a, b])',
  );

  test_removesNeutralLeavingSingle() =>
      _filter('Filter.andGroup([a, Filter.empty])', 'a');

  test_onlyNeutralOperands() => _filter(
    'Filter.orGroup([Filter.nothing, Filter.nothing])',
    'Filter.nothing',
  );

  test_binaryWithNeutral() => _filter('a.and(Filter.empty)', 'a');

  test_flattensNestedGroup() => _filter(
    'Filter.andGroup([a, Filter.andGroup([b, c])])',
    'Filter.andGroup([a, b, c])',
  );

  test_flattensNestedChain() => _filter(
    'Filter.orGroup([a.or(b).or(c), x ? a : b])',
    'Filter.orGroup([a, b, c, x ? a : b])',
  );

  test_flattensNestedConstructor() => _filter(
    'FilterGroup([a, FilterGroup([b, c], true)], true)',
    'FilterGroup([a, b, c], true)',
  );

  test_keepsOppositeKind() => _filter(
    'Filter.andGroup([Filter.empty, a, Filter.orGroup([b, c])])',
    'Filter.andGroup([a, Filter.orGroup([b, c])])',
  );

  test_sortEmptyGroup() => assertFix(
    _sorts('Sort.followedBy([])'),
    at: 'Sort.followedBy',
    fixKindId: _kind,
    expected: _sorts('Sort.empty'),
  );

  test_sortFlattensAndRemovesEmpty() => assertFix(
    _sorts('SortGroup([a, Sort.empty, SortGroup([b, c])])'),
    at: 'SortGroup([a',
    fixKindId: _kind,
    expected: _sorts('SortGroup([a, b, c])'),
  );

  test_emptyGroup_keepsImportPrefix() => assertFix(
    '''
import 'package:datahub/datahub.dart' as dh;

dh.Filter f() => dh.Filter.andGroup([]);
''',
    at: 'dh.Filter.andGroup',
    fixKindId: _kind,
    expected: '''
import 'package:datahub/datahub.dart' as dh;

dh.Filter f() => dh.Filter.empty;
''',
  );

  test_noFixForConstantGroup() => assertNoFix(
    _filters('Filter.orGroup([a, Filter.empty])'),
    at: 'Filter.empty',
    fixKindId: _kind,
  );
}

@reflectiveTest
class ConvertToFilterGroupAssistTest extends PluginTestBase {
  static const _kind = 'datahub.assist.convertToFilterGroup';

  test_convertsChain() => assertAssist(
    _filters('a.and(b).and(c)'),
    at: 'and(b)',
    assistKindId: _kind,
    expected: _filters('Filter.andGroup([a, b, c])'),
  );

  test_convertsNestedArgument() => assertAssist(
    _filters('a.or(b.or(c))'),
    at: 'a.or',
    assistKindId: _kind,
    expected: _filters('Filter.orGroup([a, b, c])'),
  );

  test_keepsOppositeKind() => assertAssist(
    _filters('a.and(b.or(c))'),
    at: 'a.and',
    assistKindId: _kind,
    expected: _filters('Filter.andGroup([a, b.or(c)])'),
  );

  test_notOfferedOnGroup() => assertNoAssist(
    _filters('Filter.andGroup([a, b])'),
    at: 'andGroup',
    assistKindId: _kind,
  );
}
