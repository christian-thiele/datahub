import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element/resource_action_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/widgets/invocation_list_item.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/aperture_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_form_field.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ElementActionDialog extends StatelessWidget {
  final String resourceId;
  final String elementId;
  final ResourceAction action;

  const ElementActionDialog({
    super.key,
    required this.resourceId,
    required this.elementId,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResourceActionCubit>(
      create: (context) => ResourceActionCubit(
        context.read(),
        resourceId: resourceId,
        action: action,
        elementId: elementId,
      ),
      child: BlocBuilder<ResourceActionCubit, ResourceActionState>(
        builder: (context, state) {
          return ApertureDialog(
            title: action.displayName,
            icon: getIcon(action.icon),
            width: action.parameterFields.isEmpty ? 420 : 520,
            actions: [
              if (state is ResourceActionEditing) ...[
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).cancel),
                ),
                FilledButton(
                  onPressed: context.read<ResourceActionCubit>().start,
                  child: IconText(
                    Icons.play_arrow_rounded,
                    S.of(context).runAction,
                  ),
                ),
              ],
              if (state is ResourceActionDone || state is ResourceActionError)
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).ok),
                ),
            ],
            child: switch (state) {
              ResourceActionEditing(:final values, :final validation) =>
                _ParameterForm(
                  fields: action.parameterFields,
                  values: values,
                  validation: validation,
                  onChanged: context
                      .read<ResourceActionCubit>()
                      .setParameterValue,
                ),
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

class _ParameterForm extends StatelessWidget {
  final List<ResourceField> fields;
  final Map<String, dynamic> values;
  final Map<String, String> validation;
  final void Function(ResourceField field, dynamic value) onChanged;

  const _ParameterForm({
    required this.fields,
    required this.values,
    required this.validation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          for (final field in fields)
            ResourceFormField(
              field: field,
              path: field.id,
              errors: validation,
              value: values[field.id],
              onChanged: field.readOnly
                  ? null
                  : (value) => onChanged(field, value),
            ),
        ],
      ),
    );
  }
}
