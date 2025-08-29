import 'package:datahub/datahub.dart';

part 'simple_dto.g.dart';

@TransferObject()
class SimpleDto extends _TransferObject {
  final String text;
  final int number;

  SimpleDto({
    required this.text,
    required this.number,
  });
}
