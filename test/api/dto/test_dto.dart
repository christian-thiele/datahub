import 'package:cl_datahub_common/common.dart';

enum EventCategory { sport, hangout, culture, party }

class TestDto extends TransferObject {
  static const fields = <Field>[
    categoryField,
    shortDescriptionField,
    longDescriptionField,
    privacyLevelField,
  ];

  static TestDto factory(data) => TestDto(data);

  TestDto(Map<String, dynamic> data) : super(fields, data);
  TestDto.create(Map<Field, dynamic> data) : super.create(fields, data);

  static const categoryField =
      EnumField<EventCategory>('category', EventCategory.values);

  EventCategory? get category => get(categoryField);

  static const shortDescriptionField = StrField('shortDescription');

  String? get shortDescription => get(shortDescriptionField);

  static const longDescriptionField = StrField('longDescription');

  String? get longDescription => get(longDescriptionField);

  static const privacyLevelField = IntField('privacyLevel');

  int? get privacyLevel => get(privacyLevelField);
}
