import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';

class FilterState {
  final List<ResourceField> fields;
  final List<FilterModel> filters;

  FilterState({required this.fields, required this.filters});
}
