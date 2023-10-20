import 'dart:typed_data';

import 'package:datahub/datahub.dart';

part 'simple_dao.g.dart';

@DaoType()
class Simple extends _Dao {
  @PrimaryKeyDaoField(type: StringDataType)
  final int id;

  final String text;
  final DateTime timestamp;
  final double number;
  final bool yesOrNo;
  final Uint8List someBytes;

  Simple(this.id, this.text, this.timestamp, this.number, this.yesOrNo,
      this.someBytes);
}
