import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element/resource_action_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/repositories/workflow_repository/workflow_repository.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/aperture_animation.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/aperture_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_form_field.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/json_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Asks for the parameters of an action and runs it: an action of an element,
/// a global action (without element) or a workflow signal.
class ElementActionDialog extends StatelessWidget {
  final String? resourceId;
  final String? elementId;
  final ResourceAction action;
  final bool _signal;

  /// Parameters that are filled in already.
  final Map<String, dynamic> initialValues;

  const ElementActionDialog({
    super.key,
    this.resourceId,
    this.elementId,
    required this.action,
  }) : _signal = false,
       initialValues = const {};

  /// Sends the signal [action] (see `ResourceWorkflowSignal.action`) to an
  /// element.
  const ElementActionDialog.signal({
    super.key,
    required String this.resourceId,
    required String this.elementId,
    required this.action,
    this.initialValues = const {},
  }) : _signal = true;

  ActionRunner _runner(BuildContext context) {
    if (_signal) {
      final repository = context.read<WorkflowRepository>();
      return (parameters) async {
        await repository.sendSignal(
          resourceId!,
          elementId!,
          action.id,
          parameters,
        );
        return null;
      };
    }

    final repository = context.read<ResourcesRepository>();
    return switch ((resourceId, elementId)) {
      (final resourceId?, final elementId?) =>
        (parameters) => repository.startElementAction(
          resourceId,
          elementId,
          action.id,
          parameters,
        ),
      _ => (parameters) => repository.startAction(action.id, parameters),
    };
  }

  /// Closes the dialog and opens the element the action redirects to.
  void _redirect(BuildContext context, ResourceActionRedirect redirect) {
    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.go(
      '/resources/${Uri.encodeComponent(redirect.resourceId)}/view/${Uri.encodeComponent(redirect.elementId)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResourceActionCubit>(
      create: (context) => ResourceActionCubit(
        action: action,
        run: _runner(context),
        initialValues: initialValues,
      ),
      child: BlocConsumer<ResourceActionCubit, ResourceActionState>(
        listener: (context, state) {
          if (state case ResourceActionDone(
            result: ResourceActionResult(:final redirect?),
          )) {
            _redirect(context, redirect);
          }
        },
        builder: (context, state) {
          return ApertureDialog(
            title: action.displayName,
            icon: getIcon(action.icon),
            width: switch (state) {
              _ when action.parameterFields.isNotEmpty => 520,
              ResourceActionDone(result: ResourceActionResult(data: _?)) => 520,
              _ => 420,
            },
            actions: [
              if (state is ResourceActionEditing) ...[
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(S.of(context).cancel),
                ),
                FilledButton(
                  onPressed: context.read<ResourceActionCubit>().start,
                  child: _signal
                      ? IconText(Icons.send_outlined, S.of(context).sendSignal)
                      : IconText(
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
              ResourceActionLoading() => IntrinsicHeight(
                child: Center(child: ApertureSpinner()),
              ),
              ResourceActionError(:final message) => IntrinsicHeight(
                child: ErrorView(message: message),
              ),
              // Redirects close the dialog, the spinner shows until then.
              ResourceActionDone(result: ResourceActionResult(redirect: _?)) =>
                IntrinsicHeight(child: Center(child: ApertureSpinner())),
              ResourceActionDone(:final result) => _ResultView(
                success: result?.success ?? true,
                message:
                    result?.message ??
                    (_signal
                        ? S.of(context).signalSent
                        : S.of(context).actionCompleted),
                data: result?.data,
              ),
            },
          );
        },
      ),
    );
  }
}

/// The message an action responded with, and its data.
class _ResultView extends StatelessWidget {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const _ResultView({required this.success, required this.message, this.data});

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                size: 22,
                color: success ? colors.success : colors.danger,
              ),
              Flexible(child: SelectableText(message)),
            ],
          ),
          if (data case final data?)
            for (final MapEntry(:key, :value) in data.entries)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 6,
                children: [
                  Text(key, style: Theme.of(context).textTheme.labelMedium),
                  _DataValue(value),
                ],
              ),
        ],
      ),
    );
  }
}

/// A value of the data of an action result: plain values as text, anything
/// nested as JSON.
class _DataValue extends StatelessWidget {
  final dynamic value;

  const _DataValue(this.value);

  static bool _isPlain(dynamic value) => value is! Map && value is! List;

  @override
  Widget build(BuildContext context) {
    return switch (value) {
      null => Text(
        '–',
        style: TextStyle(color: ApertureColors.of(context).textMuted),
      ),
      List(isEmpty: true) => Text(
        '–',
        style: TextStyle(color: ApertureColors.of(context).textMuted),
      ),
      final List list when list.every(_isPlain) => SelectableText(
        list.join(', '),
      ),
      Map() || List() => JsonText(value),
      _ => SelectableText('$value'),
    };
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
