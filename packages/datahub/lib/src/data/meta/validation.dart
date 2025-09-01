import 'package:datahub/data.dart';

final class Validation extends MetaData {
  final String? expression;
  final int? length;

  const Validation(this.expression, this.length);
}
