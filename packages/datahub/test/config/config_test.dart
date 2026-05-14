import 'dart:io';

import 'package:datahub/config.dart';
import 'package:datahub/data.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:test/expect.dart';

enum TestEnumConfig implements DataEnum {
  a('optionA'),
  b('optionB'),
  c('optionC');

  const TestEnumConfig(this.jsonValue);

  @override
  final String jsonValue;
}

void main() {
  declareTest(
    'Code based configuration values',
    [],
    testConfig,
    config: {
      'strList': <dynamic>['a', 'list', 'of', 'strings'],
      'intList': <dynamic>[1, 2, 3, 4, 5],
      'dynList': <dynamic>[1, 2, 'three', true],
      'isBool': true,
      'isNotBool': false,
      'intValue': 1,
      'doubleValue': 1.123,
      'enumValue': 'optionB',
    },
  );

  declareTest(
    'File based configuration values',
    [],
    testConfig,
    configFiles: [File('test/config/config_file.yaml')],
  );
}

void testConfig() {
  expect(
    Config<List<String>>('strList').read(),
    orderedEquals(['a', 'list', 'of', 'strings']),
  );
  expect(Config<List<int>>('intList').read(), orderedEquals([1, 2, 3, 4, 5]));
  expect(
    Config<List<dynamic>>('dynList').read(),
    orderedEquals([1, 2, 'three', true]),
  );
  expect(Config<bool>('isBool').read(), isTrue);
  expect(Config<bool>('isNotBool').read(), isFalse);
  expect(Config<int>('intValue').read(), 1);
  expect(Config<double>('doubleValue').read(), 1.123);
  expect(
    Config<TestEnumConfig>('enumValue', values: TestEnumConfig.values).read(),
    TestEnumConfig.b,
  );
}
