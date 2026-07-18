import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';

class FilterState {
  final List<ResourceField> filterFields;
  final List<ResourceField> sortFields;
  final List<FilterModel> filters;
  final ResourceField? sortField;
  final bool sortAscending;
  final String search;

  const FilterState({
    required this.filterFields,
    required this.sortFields,
    required this.filters,
    required this.sortField,
    required this.sortAscending,
    required this.search,
  });
}

class InitialFilterState extends FilterState {
  const InitialFilterState({
    super.filterFields = const [],
    super.sortFields = const [],
    super.filters = const [],
    super.sortField,
    super.sortAscending = true,
    super.search = '',
  });
}
