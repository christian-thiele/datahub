import 'package:datahub_aperture_frontend/widgets/utils/immutable_list_utils.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/authentication.dart';
import 'package:datahub_aperture_frontend/models/view_models/filter_model.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'filter_state.dart';

part 'resource_state.dart';

class ResourceCubit extends Cubit<ResourceState> {
  final ResourcesRepository _resourceRepository;
  final Authentication _authentication;
  final String resourceId;
  final ResourceFilter? defaultFilter;

  ResourceCubit(
    this._resourceRepository,
    this._authentication, {
    required this.resourceId,
    this.defaultFilter,
  }) : super(
         ResourceLoading(
           initial: true,
           offset: 0,
           pageSize: 25,
           total: null,
           filter: null,
         ),
       ) {
    update();
  }

  ResourceFilter? _buildFilter(FilterState? userFilter) {
    if (userFilter == null && defaultFilter == null) {
      return null;
    }

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
      ],
    );
  }

  Future<void> update({FilterState? filter}) async {
    if (state case ResourceLoading(_initial: false)) {
      return;
    }

    try {
      final resource = await _resourceRepository.getDescription(
        _authentication,
        resourceId,
      );

      final effectiveFilter =
          filter ??
          state.filter ??
          FilterState(
            fields: [
              ...resource.fields.where(
                (e) => [
                  ResourceFieldType.text,
                  ResourceFieldType.int,
                  ResourceFieldType.double,
                  ResourceFieldType.bool,
                ].contains(e.type),
              ),
            ],
            filters: [],
          );

      final response = await _resourceRepository.getResourceElements(
        _authentication,
        resourceId,
        filter: _buildFilter(effectiveFilter),
        offset: state.offset,
        limit: state.pageSize,
      );

      if (!isClosed) {
        emit(
          ResourceValue(
            resource: resource,
            hasNextPage: response.hasNextPage,
            data: response.data,
            total: response.total,
            offset: state.offset,
            pageSize: state.pageSize,
            filter: effectiveFilter,
          ),
        );
      }
    } catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  void addFilter(FilterModel model) {
    if (state case ResourceValue(:final filter?)) {
      update(
        filter: FilterState(
          fields: filter.fields,
          filters: [...filter.filters, model],
        ),
      );
    }
  }

  void removeFilter(int index) {
    if (state case ResourceValue(:final filter?)) {
      update(
        filter: FilterState(
          fields: filter.fields,
          filters: filter.filters.copyWithRemoved(index),
        ),
      );
    }
  }
}
