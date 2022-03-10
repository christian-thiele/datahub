import 'package:cl_datahub_common/common.dart';

part 'other_dto.g.dart';

@TransferObject()
class OtherDto extends _TransferObject {
  final String someStr;
  final int someInt;

  OtherDto(this.someStr, this.someInt);
}
