import 'package:datahub/datahub.dart';
import 'package:datahub_aperture_frontend/blocs/workflow/resource_workflow_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/data/entity_list_view.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:datahub_aperture_frontend/widgets/page_header.dart';
import 'package:datahub_aperture_frontend/widgets/resources/resource_list.dart';
import 'package:datahub_aperture_frontend/widgets/workflow/workflow_event_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/workflow/workflow_event_tile.dart';
import 'package:datahub_aperture_frontend/widgets/workflow/workflow_steps_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The workflow of a resource: its steps and the events of all elements.
class ResourceWorkflowPage extends StatelessWidget {
  final GoRouterState routerState;

  const ResourceWorkflowPage(this.routerState, {super.key});

  @override
  Widget build(BuildContext context) {
    final resourceId = routerState.pathParameters['resourceId']!;
    return BasePage(
      child: BlocProvider(
        key: ValueKey(resourceId),
        create: (context) => ResourceWorkflowCubit(
          context.read<ResourcesRepository>(),
          context.read<WorkflowRepository>(),
          resourceId: resourceId,
        ),
        child: BlocBuilder<ResourceWorkflowCubit, ResourceWorkflowState>(
          builder: (context, state) {
            final cubit = context.read<ResourceWorkflowCubit>();
            return switch (state) {
              ResourceWorkflowLoading() => const LoadingView(),
              ResourceWorkflowError(:final message) => ErrorView(
                message: message,
              ),
              ResourceWorkflowValue(:final resource) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  PageHeader(
                    title: S
                        .of(context)
                        .workflowOf(resource.namePlural ?? resource.name),
                    leading: const IconTile(
                      Icons.account_tree_outlined,
                      size: 40,
                    ),
                    breadcrumbs: [
                      Breadcrumb(
                        resource.namePlural ?? resource.name,
                        '/resources/${Uri.encodeComponent(resourceId)}',
                      ),
                      Breadcrumb(S.of(context).workflow),
                    ],
                    actions: [
                      IconButton.outlined(
                        onPressed: cubit.reload,
                        icon: const Icon(Icons.refresh),
                        tooltip: S.of(context).refresh,
                      ),
                    ],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final steps = Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: WorkflowStepsView(workflow: state.workflow),
                          ),
                        );
                        final events = _EventsCard(
                          resourceId: resourceId,
                          state: state,
                        );

                        if (constraints.maxWidth < 900) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 20,
                            children: [
                              Expanded(child: events),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 240,
                                ),
                                child: SingleChildScrollView(child: steps),
                              ),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 20,
                          children: [
                            Expanded(child: events),
                            SizedBox(
                              width: 340,
                              child: SingleChildScrollView(child: steps),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            };
          },
        ),
      ),
    );
  }
}

class _EventsCard extends StatelessWidget {
  final String resourceId;
  final ResourceWorkflowValue state;

  const _EventsCard({required this.resourceId, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResourceWorkflowCubit>();
    final s = S.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<WorkflowEventStatus?>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: null, label: Text(s.all)),
                  ButtonSegment(
                    value: WorkflowEventStatus.pending,
                    label: Text(s.eventPending),
                  ),
                  ButtonSegment(
                    value: WorkflowEventStatus.failed,
                    label: Text(s.eventFailed),
                  ),
                  ButtonSegment(
                    value: WorkflowEventStatus.expired,
                    label: Text(s.eventExpired),
                  ),
                ],
                selected: {state.status},
                onSelectionChanged: (selection) =>
                    cubit.setStatus(selection.single),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: EntityListView(
              itemCount: state.events.length,
              empty: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    s.noEvents,
                    style: TextStyle(
                      color: ApertureColors.of(context).textMuted,
                    ),
                  ),
                ),
              ),
              entryBuilder: (context, index) {
                final event = state.events[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: WorkflowEventTile(
                    event: event,
                    showElement: true,
                    onPressed: () async {
                      await WorkflowEventDialog.show(
                        context,
                        resourceId: resourceId,
                        event: event,
                        showElement: true,
                      );
                      await cubit.reload();
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          PagingBar(
            paging: state.paging,
            onFirstPressed: cubit.firstPage,
            onPreviousPressed: cubit.previousPage,
            onNextPressed: cubit.nextPage,
          ),
        ],
      ),
    );
  }
}
