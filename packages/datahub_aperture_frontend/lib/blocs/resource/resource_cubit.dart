import 'dart:math';

import 'package:datahub_aperture_frontend/models/view_models/paging.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:bloc/bloc.dart';

import '../error_state.dart';
import 'filter_state.dart';

part 'resource_state.dart';

class ResourceCubit extends Cubit<ResourceState> {
  final ResourcesRepository _resourceRepository;
  final String resourceId;
  final ResourceFilter? defaultFilter;

  ResourceCubit(
    this._resourceRepository, {
    required this.resourceId,
    this.defaultFilter,
    String initialSearch = '',
  }) : super(
         ResourceLoading(
           initial: true,
           paging: Paging(
             offset: 0,
             length: 0,
             pageSize: 25,
             total: null,
             hasMore: false,
           ),
           filter: InitialFilterState(search: initialSearch),
         ),
       ) {
    update();
  }

  ResourceFilter? _buildFilter(
    ResourceDescription resource,
    FilterState? userFilter,
  ) {
    if (userFilter == null && defaultFilter == null) {
      return null;
    }

    final searchFilter = (userFilter?.search.isNotEmpty ?? false)
        ? ResourceFilter(
            and: [
              for (final word in userFilter!.search.split(RegExp('\\W+')))
                ResourceFilter(
                  or: [
                    for (final field in _getFilterFields(resource))
                      ResourceFilter(
                        fieldId: field.id,
                        type: ResourceFilterType.contains,
                        value: word,
                      ),
                  ],
                ),
            ],
          )
        : null;

    return ResourceFilter(
      and: [
        ?defaultFilter,
        ...?userFilter?.filters.map(
          (e) => ResourceFilter(
            fieldId: e.field.id,
            type: e.type,
            value: e.value?.toString(),
          ),
        ),
        ?searchFilter,
      ],
    );
  }

  Future<void> update({FilterState? filter, Paging? paging}) async {
    if (state case ResourceLoading(_initial: false)) {
      return;
    }

    try {
      final resource = await _resourceRepository.getDescription(resourceId);

      final effectiveFilter =
          filter ??
          switch (state.filter) {
            InitialFilterState(:final search) => FilterState(
              filterFields: _getFilterFields(resource),
              sortFields: _getSortFields(resource),
              filters: [],
              search: search,
              sortField: _getSortFields(resource).firstOrNull,
              sortAscending: true,
            ),
            _ => state.filter,
          };

      final effectivePaging = paging ?? state.paging;

      final response = await _resourceRepository.getResourceElements(
        resourceId,
        filter: _buildFilter(resource, effectiveFilter),
        sortFieldId: effectiveFilter.sortField?.id,
        sortAscending: effectiveFilter.sortAscending,
        offset: effectivePaging.offset,
        limit: effectivePaging.pageSize,
      );

      for (final d in response.data) {
        decodeFieldData(resource, d);
      }

      if (!isClosed) {
        emit(
          ResourceValue(
            resource: resource,
            paging: Paging(
              offset: effectivePaging.offset,
              length: response.data.length,
              pageSize: effectivePaging.pageSize,
              total: response.total,
              hasMore: response.hasNextPage,
            ),
            data: response.data,
            filter: effectiveFilter,
          ),
        );
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addFilter(FilterModel model) {
    if (state case ResourceValue(
      :final filter,
      paging: Paging(:final pageSize),
    )) {
      update(
        filter: FilterState(
          filterFields: filter.filterFields,
          sortFields: filter.sortFields,
          filters: [...filter.filters, model],
          search: filter.search,
          sortField: filter.sortField,
          sortAscending: filter.sortAscending,
        ),
        paging: Paging.empty(0, pageSize),
      );
    }
  }

  void setSort(ResourceField? field, bool ascending) {
    if (state case ResourceValue(
      :final filter,
      paging: Paging(:final pageSize),
    )) {
      update(
        filter: FilterState(
          filterFields: filter.filterFields,
          sortFields: filter.sortFields,
          filters: filter.filters,
          search: filter.search,
          sortField: field,
          sortAscending: ascending,
        ),
        paging: Paging.empty(0, pageSize),
      );
    }
  }

  void removeFilter(int index) {
    if (state case ResourceValue(
      :final filter,
      paging: Paging(:final pageSize),
    )) {
      update(
        filter: FilterState(
          filterFields: filter.filterFields,
          sortFields: filter.sortFields,
          filters: filter.filters.copyWithRemoved(index),
          search: filter.search,
          sortField: filter.sortField,
          sortAscending: filter.sortAscending,
        ),
        paging: Paging.empty(0, pageSize),
      );
    }
  }

  void updateSearch(String text) {
    if (state case ResourceValue(
      :final filter,
      paging: Paging(:final pageSize),
    )) {
      update(
        filter: FilterState(
          filterFields: filter.filterFields,
          sortFields: filter.sortFields,
          filters: filter.filters,
          search: text,
          sortField: filter.sortField,
          sortAscending: filter.sortAscending,
        ),
        paging: Paging.empty(0, pageSize),
      );
    }
  }

  void _pageTo(int offset, int pageSize) {
    update(
      paging: Paging(
        offset: max(0, offset),
        length: pageSize,
        pageSize: pageSize,
        hasMore: false,
        total: null,
      ),
    );
  }

  void firstPage() {
    if (state case ResourceValue(:final paging) when paging.offset > 0) {
      _pageTo(0, paging.pageSize);
    }
  }

  void previousPage() {
    if (state case ResourceValue(
      paging: Paging(:final offset, :final pageSize),
    ) when offset > 0) {
      _pageTo(offset - pageSize, pageSize);
    }
  }

  void nextPage() {
    if (state case ResourceValue(
      paging: Paging(:final offset, :final length, hasMore: true),
    )) {
      _pageTo(offset + length, length);
    }
  }

  void lastPage() {
    if (state case ResourceValue(
      paging: Paging(:final length, :final total?),
    )) {
      _pageTo(total - length, length);
    }
  }

  List<ResourceField> _getFilterFields(ResourceDescription resource) {
    return [
      ...resource.fields.where((field) {
        if (!field.allowFilter) {
          return false;
        }

        return [
              ResourceFieldType.string,
              ResourceFieldType.stringEnum,
              ResourceFieldType.int,
              ResourceFieldType.double,
              ResourceFieldType.bool,
              ResourceFieldType.timestamp,
            ].contains(field.type) ||
            (field.type == ResourceFieldType.list &&
                field.objectDescription?.firstOrNull?.type ==
                    ResourceFieldType.string);
      }),
    ];
  }

  List<ResourceField> _getSortFields(ResourceDescription resource) {
    return [
      ...resource.fields.where((field) {
        if (!field.allowSort) {
          return false;
        }

        return [
          ResourceFieldType.string,
          ResourceFieldType.stringEnum,
          ResourceFieldType.int,
          ResourceFieldType.double,
          ResourceFieldType.bool,
          ResourceFieldType.timestamp,
        ].contains(field.type);
      }),
    ];
  }
}
