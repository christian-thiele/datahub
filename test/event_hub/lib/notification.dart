import 'package:datahub/datahub.dart';

part 'notification.g.dart';

@TransferObject()
class Notification extends _TransferObject {
  final String title;
  final String text;
  final bool receive;

  Notification(this.title, this.text, this.receive);
}
