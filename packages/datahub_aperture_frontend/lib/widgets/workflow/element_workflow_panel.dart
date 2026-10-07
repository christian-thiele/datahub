import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/workflow/element_workflow_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/pages/resource_element_edit/element_action_dialog.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/helper.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/confirmation_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/info_badge.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:datahub_aperture_frontend/widgets/options_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'workflow_event_dialog.dart';
import 'workflow_event_tile.dart';
import 'workflow_history.dart';

/// The workflow of an element: its state, its open events and its history,
/// with signals to send. For the side panel of the element page.
class ElementWorkflowPanel extends StatefulWidget {
  final ResourceDescription resource;

  /// The element. When it changes (it was saved or reloaded), the workflow is
  /// reloaded as well.
  final ResourceData data;

  /// Called when the workflow may have changed the element.
  final VoidCallback? onElementChanged;

  const ElementWorkflowPanel({
    super.key,
    required this.resource,
    required this.data,
    this.onElementChanged,
  });

  @override
  State<ElementWorkflowPanel> createState() => _ElementWorkflowPanelState();
}

class _ElementWorkflowPanelState extends State<ElementWorkflowPanel> {
  late final ElementWorkflowCubit _cubit;

  ResourceWorkflow get _workflow => widget.resource.workflow!;

  @override
  void initState() {
    super.initState();
    _cubit = ElementWorkflowCubit(
      context.read<WorkflowRepository>(),
      resourceId: widget.resource.id,
      elementId: widget.data.id,
      writesHistory: _workflow.writesHistory,
      onElementChanged: () => widget.onElementChanged?.call(),
    );
  }

  @override
  void didUpdateWidget(covariant ElementWorkflowPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) {
      _cubit.reload();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _sendSignal(ResourceWorkflowSignal signal) async {
    // The element the signal is meant for is this one, most likely.
    final initialValues = {
      for (final field in signal.action.parameterFields)
        if (field.lookup?.resourceId == widget.resource.id)
          field.id: widget.data.fieldData[widget.resource.idField],
    };
    await showDialog(
      context: context,
      builder: (context) => ElementActionDialog.signal(
        resourceId: widget.resource.id,
        elementId: widget.data.id,
        action: signal.action,
        initialValues: initialValues,
      ),
    );
    await _cubit.reload();
  }

  void _resume(String? state) {
    ConfirmationDialog.show(
      context,
      title: S.of(context).resumeWorkflow,
      child: Text(S.of(context).reallyResumeWorkflow(state ?? '')),
      confirmText: S.of(context).resume,
      onConfirmPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final failed = S.of(context).errorOccurred;
        try {
          await _cubit.resume();
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text(apiErrorMessage(e) ?? failed)),
          );
        }
      },
    );
  }

  Future<void> _openEvent(ResourceWorkflowEvent event) async {
    await WorkflowEventDialog.show(
      context,
      resourceId: widget.resource.id,
      event: event,
    );
    await _cubit.reload();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.data.fieldData[_workflow.stateField]?.toString();
    final colors = ApertureColors.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: state != null
                      ? StatusPill(
                          label: state,
                          icon: Icons.account_tree_outlined,
                          color: colors.link,
                          background: colors.accentSubtle,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              if (_workflow.signals.isNotEmpty)
                OptionsButton(
                  variant: OptionsButtonVariant.secondary,
                  menuChildren: [
                    for (final signal in _workflow.signals)
                      MenuItemButton(
                        leadingIcon: Icon(getIcon(signal.action.icon)),
                        onPressed: () => _sendSignal(signal),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(signal.action.displayName),
                            if (!signal.accept.contains(state))
                              Text(
                                S
                                    .of(context)
                                    .waitsFor(signal.accept.join(', ')),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: colors.textMuted),
                              ),
                          ],
                        ),
                      ),
                  ],
                  child: IconText(Icons.bolt, S.of(context).sendSignalMenu),
                ),
              MenuAnchor(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.refresh),
                    onPressed: _cubit.reload,
                    child: Text(S.of(context).refresh),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.replay),
                    onPressed: () => _resume(state),
                    child: Text(S.of(context).resumeWorkflow),
                  ),
                ],
                builder: (context, controller, _) => IconButton(
                  onPressed: () => controller.isOpen
                      ? controller.close()
                      : controller.open(),
                  icon: const Icon(Icons.more_vert),
                ),
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<ElementWorkflowCubit, ElementWorkflowState>(
              builder: (context, cubitState) => switch (cubitState) {
                ElementWorkflowLoading() => const LoadingView(),
                ElementWorkflowError(:final message) => ErrorView(
                  message: message,
                  onRetryPressed: _cubit.reload,
                ),
                ElementWorkflowValue(
                  :final events,
                  :final history,
                  :final hasMoreHistory,
                ) =>
                  ListView(
                    children: [
                      _SectionTitle(
                        S.of(context).openEvents,
                        count: events.length,
                      ),
                      if (events.isEmpty)
                        _Hint(S.of(context).noOpenEvents)
                      else
                        for (final event in events)
                          WorkflowEventTile(
                            event: event,
                            onPressed: () => _openEvent(event),
                          ),
                      const SizedBox(height: 16),
                      _SectionTitle(S.of(context).history),
                      if (!_workflow.writesHistory)
                        _Hint(S.of(context).historyNotWritten)
                      else if (history.isEmpty)
                        _Hint(S.of(context).noHistory)
                      else ...[
                        for (final entry in history)
                          WorkflowHistoryTile(
                            entry: entry,
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => WorkflowHistoryDialog(
                                entry: entry,
                                fields: widget.resource.fields,
                              ),
                            ),
                          ),
                        if (hasMoreHistory)
                          TextButton(
                            onPressed: _cubit.loadMoreHistory,
                            child: Text(S.of(context).loadMore),
                          ),
                      ],
                    ],
                  ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final int? count;

  const _SectionTitle(this.title, {this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        spacing: 8,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          if (count case final count?)
            Text('$count', style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  final String text;

  const _Hint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: ApertureColors.of(context).textMuted,
        ),
      ),
    );
  }
}
