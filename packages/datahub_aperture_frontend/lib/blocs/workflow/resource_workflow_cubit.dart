import 'dart:async';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/error_state.dart';
import 'package:datahub_aperture_frontend/models/view_models/paging.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:flutter/foundation.dart';

import 'workflow_polling.dart';

part 'resource_workflow_state.dart';

/// The workflow of a resource and the events of all its elements, a page at a
/// time and optionally of one status.
///
/// While events are pending, it reloads by itself (see [workflowPollDelay]).
class ResourceWorkflowCubit extends Cubit<ResourceWorkflowState> {
  static const pageSize = 25;

  final ResourcesRepository _resources;
  final WorkflowRepository _workflows;
  final String resourceId;

  final DateTime Function() _now;
  Timer? _poll;

  ResourceWorkflowCubit(
    this._resources,
    this._workflows, {
    required this.resourceId,
    @visibleForTesting DateTime Function()? now,
  }) : _now = now ?? DateTime.timestamp,
       super(const ResourceWorkflowLoading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final resource = await _resources.getDescription(resourceId);
      if (resource.workflow == null) {
        throw ApiRequestException.notFound('The resource has no workflow.');
      }
      await _load(resource, status: null, offset: 0);
    } catch (e) {
      if (!isClosed) {
        emit(ResourceWorkflowError(message: apiErrorMessage(e)));
      }
    }
  }

  Future<void> _load(
    ResourceDescription resource, {
    required WorkflowEventStatus? status,
    required int offset,
  }) async {
    _poll?.cancel();
    final events = await _workflows.getEvents(
      resourceId,
      status: status,
      offset: offset,
      limit: pageSize,
    );
    if (isClosed) {
      return;
    }

    emit(
      ResourceWorkflowValue(
        resource: resource,
        status: status,
        events: events.data,
        paging: Paging(
          offset: offset,
          length: events.data.length,
          pageSize: pageSize,
          total: null,
          hasMore: events.hasNextPage,
        ),
      ),
    );
    if (workflowPollDelay(events.data, _now()) case final delay?) {
      _poll = Timer(delay, reload);
    }
  }

  Future<void> _reloadWith({
    WorkflowEventStatus? Function()? status,
    int? offset,
  }) async {
    if (state case final ResourceWorkflowValue state) {
      try {
        await _load(
          state.resource,
          status: status != null ? status() : state.status,
          offset: offset ?? state.paging.offset,
        );
      } catch (e) {
        // What was loaded before is still shown.
      }
    }
  }

  Future<void> reload() => _reloadWith();

  /// Shows the events with [status], or all events.
  Future<void> setStatus(WorkflowEventStatus? status) =>
      _reloadWith(status: () => status, offset: 0);

  Future<void> firstPage() => _reloadWith(offset: 0);

  Future<void> previousPage() async {
    if (state case ResourceWorkflowValue(:final paging)) {
      await _reloadWith(offset: math.max(0, paging.offset - pageSize));
    }
  }

  Future<void> nextPage() async {
    if (state case ResourceWorkflowValue(:final paging) when paging.hasMore) {
      await _reloadWith(offset: paging.offset + pageSize);
    }
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}
