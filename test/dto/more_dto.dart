import 'package:cl_datahub_common/common.dart';

part 'more_dto.g.dart';

@TransferObject()
class MoreDto extends _TransferObject {
  final String? longDescription;
  final List<int>? someList;

  MoreDto(this.longDescription, this.someList);
}
