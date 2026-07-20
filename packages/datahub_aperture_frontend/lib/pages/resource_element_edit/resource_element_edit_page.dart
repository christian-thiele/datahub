import 'package:boost/boost.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element/resource_element_edit_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/models/view_models/action_model.dart';
import 'package:datahub_aperture_frontend/pages/resource_element_edit/element_action_dialog.dart';
import 'package:datahub_aperture_frontend/pages/resource_element_edit/resource_element_edit_view.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/confirmation_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_overlay.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResourceElementEditPage extends StatelessWidget {
  final GoRouterState routerState;

  const ResourceElementEditPage(this.routerState, {super.key});

  @override
  Widget build(BuildContext context) {
    final resourceId = routerState.pathParameters['resourceId']!;
    final elementId = routerState.pathParameters['elementId']!;
    final version = routerState.uri.queryParameters['version']?.apply(
      int.tryParse,
    );
    final revertFromVersion = routerState.uri.queryParameters['revertFrom']
        ?.apply(int.tryParse);
    return BasePage(
      child: BlocProvider(
        key: ValueKey(
          '${resourceId}_${elementId}_${version}_$revertFromVersion',
        ),
        create: (context) => ResourceElementEditCubit(
          context.read<ResourcesRepository>(),
          resourceId: resourceId,
          elementId: elementId,
          version: version,
          revertFromVersion: revertFromVersion,
        ),
        child: BlocConsumer<ResourceElementEditCubit, ResourceElementEditState>(
          listener: (context, state) {
            if (state is ResourceElementEditSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).resourceSaved)),
              );
            } else if (state is ResourceElementEditDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).resourceDeleted)),
              );
              context.pop();
            }
          },
          builder: (context, state) {
            return switch (state) {
              ResourceElementEditError(:final message) => ErrorView(
                message: message,
              ),
              ResourceElementEditValue(
                :final title,
                :final resource,
                :final data,
                :final changes,
                :final relations,
                :final validations,
              ) =>
                LoadingOverlay(
                  loading: state is ResourceElementEditSaving,
                  message: 'Saving...',
                  child: ResourceElementEditView(
                    title: title,
                    fields: resource.fields,
                    relations: relations,
                    data: data,
                    changes: changes,
                    validations: validations,
                    revisable: resource.revisable,
                    onFieldValueChanged: (field, value) => context
                        .read<ResourceElementEditCubit>()
                        .setFieldValue(field.id, value),
                    onSavePressed: changes.isNotEmpty
                        ? (from) => context
                              .read<ResourceElementEditCubit>()
                              .saveChanges(from: from)
                        : null,
                    actions: [
                      for (final action in resource.actions)
                        ActionModel(
                          id: action.id,
                          name: action.displayName,
                          icon: action.icon,
                        ),
                    ],
                    onActionPressed: (actionId) {
                      showDialog(
                        context: context,
                        builder: (context) => ElementActionDialog(
                          title: resource.actions
                              .firstWhere((a) => a.id == actionId)
                              .displayName,
                          resourceId: resourceId,
                          elementId: elementId,
                          actionId: actionId,
                        ),
                      );
                    },
                    onDeletePressed: (from) {
                      final cubit = context.read<ResourceElementEditCubit>();
                      ConfirmationDialog.show(
                        context,
                        title: S.of(context).caution,
                        child: Text(S.of(context).reallyDeleteElement(title)),
                        confirmText: S.of(context).delete,
                        onConfirmPressed: () => cubit.delete(from: from),
                      );
                    },
                  ),
                ),
              _ => LoadingView(),
            };
          },
        ),
      ),
    );
  }
}
