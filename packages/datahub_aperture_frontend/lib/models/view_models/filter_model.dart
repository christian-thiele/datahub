import 'package:datahub_aperture/datahub_aperture.dart';

class FilterModel {
  final ResourceField field;
  final ResourceFilterType type;
  final dynamic value;

  FilterModel(this.field, this.type, this.value);
}
