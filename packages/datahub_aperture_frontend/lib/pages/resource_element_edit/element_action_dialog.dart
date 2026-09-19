import 'package:datahub_aperture_frontend/blocs/resource_element/resource_action_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/widgets/invocation_list_item.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/aperture_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ElementActionDialog extends StatelessWidget {
  final String title;
  final String resourceId;
  final String elementId;
  final String actionId;

  const ElementActionDialog({
    super.key,
    required this.title,
    required this.resourceId,
    required this.elementId,
    required this.actionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResourceActionCubit>(
      create: (context) => ResourceActionCubit(
        context.read(),
        resourceId: resourceId,
        actionId: actionId,
        elementId: elementId,
      ),
      child: BlocBuilder<ResourceActionCubit, ResourceActionState>(
        builder: (context, state) {
          return ApertureDialog(
            title: title,
            icon: Icons.play_arrow_rounded,
            width: 420,
            actions: [
              if (state is ResourceActionDone || state is ResourceActionError)
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).ok),
                ),
            ],
            child: switch (state) {
              ResourceActionLoading() => Center(child: ApertureSpinner()),
              ResourceActionError(:final message) => ErrorView(
                message: message,
              ),
              ResourceActionDone() => Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 22,
                    color: ApertureColors.of(context).success,
                  ),
                  Text('Task started.'),
                ],
              ),
              ResourceActionProgress(:final task) => InvocationListItem(
                task: task,
              ),
            },
          );
        },
      ),
    );
  }
}
