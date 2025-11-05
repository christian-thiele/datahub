import 'package:datahub_aperture_frontend/blocs/resource_element/resource_action_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/widgets/invocation_list_item.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';

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
          return Dialog(
            child: SizedBox(
              width: 256,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    switch (state) {
                      ResourceActionLoading() => Center(child: ApertureSpinner()),
                      ResourceActionError(:final message) => ErrorView(
                        message: message,
                      ),
                      ResourceActionDone() => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 8,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 16,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 24,
                                  color: Colors.green,
                                ),
                                Text(
                                  'Task started.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: FilledButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(S.of(context).ok),
                              ),
                            ),
                          ],
                        ),
                      ),

                      ResourceActionProgress(:final task) => InvocationListItem(
                        task: task,
                      ),
                    },
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
