import 'package:datahub/datahub.dart';

part 'simple_dto.g.dart';

@Data()
class SimpleDto extends _SimpleDto {
  final String text;
  final int number;

  const SimpleDto({
    required this.text,
    required this.number,
  });

  static DataBean<SimpleDto> get bean => _SimpleDto.bean;
}
