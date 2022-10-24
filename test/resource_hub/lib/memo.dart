import 'package:datahub/datahub.dart';

part 'memo.g.dart';

@TransferObject()
class Memo extends _TransferObject {
  final String text;
  final DateTime timestamp;

  Memo(this.text, this.timestamp);
}
