import 'package:datahub/datahub.dart';

part 'memo.g.dart';

@TransferObject()
class Memo extends _TransferObject {
  @TransferId()
  final int id;
  final String text;
  final DateTime timestamp;

  Memo(this.id, this.text, this.timestamp);
}
