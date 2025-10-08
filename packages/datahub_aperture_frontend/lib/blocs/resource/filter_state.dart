import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';

class FilterState {
  final List<ResourceField> fields;
  final List<FilterModel> filters;
  final String search;

  const FilterState({
    required this.fields,
    required this.filters,
    required this.search,
  });
}

class InitialFilterState extends FilterState {
  const InitialFilterState({
    super.fields = const [],
    super.filters = const [],
    super.search = '',
  });
}
