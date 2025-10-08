import 'package:datahub_aperture_frontend/blocs/auth_cubit.dart';
import 'package:datahub_aperture_frontend/blocs/resource_element_create_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_overlay.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'resource_element_create_view.dart';

class ResourceElementCreatePage extends StatelessWidget {
  final GoRouterState routerState;

  const ResourceElementCreatePage(this.routerState, {super.key});

  @override
  Widget build(BuildContext context) {
    final resourceId = routerState.pathParameters['resourceId']!;
    return BasePage(
      child: BlocProvider(
        create: (context) => ResourceElementCreateCubit(
          context.read<ResourcesRepository>(),
          resourceId: resourceId,
        ),
        child: BlocConsumer<ResourceElementCreateCubit, ResourceElementCreateState>(
          listener: (context, state) {
            switch (state) {
              case ResourceElementCreateSaved(:final id, :final revisionId):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).resourceSaved)),
                );
                context.go(
                  Uri(
                    path:
                        '/resources/${Uri.encodeComponent(resourceId)}/view/${Uri.encodeComponent(id)}',
                    queryParameters: {
                      if (revisionId != null) 'revisionId': revisionId,
                    },
                  ).toString(),
                );
              default:
                break;
            }
          },
          builder: (context, state) {
            return switch (state) {
              ResourceElementCreateLoading() => LoadingView(),
              ResourceElementCreateError(:final message) => ErrorView(
                message: message,
              ),
              ResourceElementCreateValue(:final fields, :final changes) =>
                LoadingOverlay(
                  loading: state is ResourceElementCreateSaving,
                  child: SingleChildScrollView(
                    child: ResourceElementCreateView(
                      fields: fields,
                      data: ResourceData(id: '', fieldData: {}),
                      changes: changes,
                      validations: switch (state) {
                        ResourceElementCreateEditing(:final validation) =>
                          validation,
                        _ => {},
                      },
                      onFieldValueChanged: (field, value) => context
                          .read<ResourceElementCreateCubit>()
                          .setFieldValue(field.id, value),
                      onSavePressed: (live) => context
                          .read<ResourceElementCreateCubit>()
                          .saveChanges(revisionLive: live),
                    ),
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}
