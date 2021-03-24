import 'package:cl_datahub_common/common.dart';

class TestDto extends TransferObject {
  static TestDto factory(data) => TestDto(data);

  TestDto(Map<String, dynamic> data) : super([], data);
}
