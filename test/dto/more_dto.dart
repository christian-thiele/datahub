import 'package:cl_datahub_common/common.dart';

import 'other_dto.dart';

part 'more_dto.g.dart';

@TransferObject()
class MoreDto extends _TransferObject {
  final String? longDescription;
  final List<OtherDto>? someList;

  MoreDto(this.longDescription, this.someList);
}
