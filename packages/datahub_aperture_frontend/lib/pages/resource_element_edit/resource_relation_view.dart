import 'package:datahub_aperture_frontend/blocs/auth_cubit.dart';
import 'package:datahub_aperture_frontend/blocs/resource/resource_cubit.dart';
import 'package:datahub_aperture_frontend/models/filtered_resource.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:datahub_aperture_frontend/widgets/resources/resource_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResourceRelationView extends StatelessWidget {
  final FilteredResource filteredResource;

  const ResourceRelationView({super.key, required this.filteredResource});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 128, maxHeight: 256),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            filteredResource.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Flexible(
            child: BlocProvider(
              create: (context) => ResourceCubit(
                context.read<ResourcesRepository>(),
                (context.read<AuthCubit>().state as AuthStateAuthorized).auth,
                resourceId: filteredResource.resourceId,
                defaultFilter: filteredResource.filter,
              ),
              child: BlocBuilder<ResourceCubit, ResourceState>(
                builder: (context, state) {
                  return switch (state) {
                    ResourceLoading() => LoadingView(),
                    ResourceError(:final message) => ErrorView(
                      message: message,
                    ),
                    ResourceValue(:final resource, :final data) => ResourceList(
                      resource: resource,
                      entries: data,
                      shrinkWrap: true,
                    ),
                  };
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
