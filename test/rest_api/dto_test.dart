import 'package:test/test.dart';

import '../dto/test_dto.dart';

void main() {
  test('Test dto parsing', _testDtoParse);
}

void _testDtoParse() {
  final dto = TestDtoTransferBean.staticToObject({
    'category': EventCategory.hangout,
    'shortDescription': 'some description',
    'longDescription': 'some description2',
    'privacyLevel': 5,
  });

  expect(dto.category, equals(EventCategory.hangout));
  expect(dto.shortDescription, equals('some description'));
  expect(dto.longDescription, equals('some description2'));
  expect(dto.privacyLevel, equals(5));

  final dto2 = TestDtoTransferBean.staticToObject({
    'category': 'party',
    'longDescription': 'some description2',
    'privacyLevel': '5',
  });

  expect(dto2.category, equals(EventCategory.party));
  expect(dto2.shortDescription, equals(null));
  expect(dto2.longDescription, equals('some description2'));
  expect(dto2.privacyLevel, equals(5));
}
