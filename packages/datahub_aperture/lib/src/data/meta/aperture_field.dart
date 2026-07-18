import 'package:datahub/data.dart';

final class ApertureField extends MetaData {
  final bool isDisplayField;
  final bool readOnly;
  final bool allowFilter;
  final bool allowSort;

  const ApertureField({
    this.isDisplayField = false,
    this.readOnly = false,
    this.allowFilter = true,
    this.allowSort = true,
  });
}
