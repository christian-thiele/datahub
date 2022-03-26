import 'package:cl_datahub_common/common.dart';

part 'other_dto.g.dart';

@TransferObject()
class OtherDto extends _TransferObject {
  @TransferId()
  final int primaryKey;
  final String someStr;
  final int someInt;

  OtherDto(this.primaryKey, this.someStr, this.someInt);
}
