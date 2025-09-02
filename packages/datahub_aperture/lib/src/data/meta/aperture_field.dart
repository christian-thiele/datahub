import 'package:datahub/data.dart';

final class ApertureField extends MetaData {
  final bool readOnly;
  final List<Enum>? enumValues;

  const ApertureField({
    this.readOnly = false,
    this.enumValues,
  });
}
