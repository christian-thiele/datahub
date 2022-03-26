import 'dart:typed_data';

import 'package:cl_datahub/cl_datahub.dart';

part 'simple_dao.g.dart';

@DaoType()
class Simple {
  @PrimaryKeyDaoField()
  final int id;

  final String text;
  final DateTime timestamp;
  final double number;
  final bool yesOrNo;
  final Uint8List someBytes;

  Simple(this.id, this.text, this.timestamp, this.number, this.yesOrNo,
      this.someBytes);
}
