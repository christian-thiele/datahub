import 'package:cl_datahub/api.dart';

class TestDto extends TransferObject {
  static TestDto factory(data) => TestDto(data);

  TestDto(Map<String, dynamic> data) : super(data);


}