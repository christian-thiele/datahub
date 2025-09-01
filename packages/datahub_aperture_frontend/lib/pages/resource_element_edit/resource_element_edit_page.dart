import 'package:datahub_aperture_frontend/blocs/auth_cubit.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element_edit_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_overlay.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:datahub_aperture_frontend/pages/resource_element_edit/resource_element_edit_view.dart';
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
    final revisionId = routerState.uri.queryParameters['revisionId'];
    return BasePage(
      child: BlocProvider(
        create: (context) => ResourceElementEditCubit(
          context.read<ResourcesRepository>(),
          (context.read<AuthCubit>().state as AuthStateAuthorized).auth,
          resourceId: resourceId,
          elementId: elementId,
          revisionId: revisionId,
        ),
        child: BlocConsumer<ResourceElementEditCubit, ResourceElementEditState>(
          listener: (context, state) {
            if (state is ResourceElementEditSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).resourceSaved)),
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              ResourceElementEditLoading() => LoadingView(),
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
                  child: ResourceElementEditView(
                    title: title,
                    fields: resource.fields,
                    relations: relations,
                    data: data,
                    changes: changes,
                    validations: validations,
                    onFieldValueChanged: (field, value) => context
                        .read<ResourceElementEditCubit>()
                        .setFieldValue(field.id, value),
                    onSavePressed: changes.isNotEmpty
                        ? (revisionLive) => context
                              .read<ResourceElementEditCubit>()
                              .saveChanges(revisionLive: revisionLive)
                        : null,
                    actions: [],
                    onActionPressed: (id) => context
                        .read<ResourceElementEditCubit>()
                        .startAction(id),
                    onDeletePressed: () =>
                        context.read<ResourceElementEditCubit>().delete(),
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}
