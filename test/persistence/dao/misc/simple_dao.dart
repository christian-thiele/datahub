import 'package:cl_datahub/cl_datahub.dart';

class Simple {
  @PrimaryKeyDaoField()
  final int id;

  final String text;
  final DateTime timestamp;
  final double number;
  final bool yesOrNo;

  Simple(this.id, this.text, this.timestamp, this.number, this.yesOrNo);
}
