import 'package:boost/boost.dart';
import 'package:cl_datahub_common/common.dart';

part 'test_dto.g.dart';

enum EventCategory { sport, hangout, culture, party }

@TransferObject()
class TestDto extends _TransferObject {
  final EventCategory category;
  final String? shortDescription;
  final String? longDescription;
  final int privacyLevel;

  TestDto({
    required this.category,
    this.shortDescription,
    this.longDescription,
    required this.privacyLevel,
  });
}
