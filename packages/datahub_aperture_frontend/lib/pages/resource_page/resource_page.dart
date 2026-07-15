import 'package:datahub_aperture_frontend/blocs/resource/resource_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/filter/filter_view.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/widgets/base_page.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:datahub_aperture_frontend/widgets/resources/resource_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResourcePage extends StatelessWidget {
  final GoRouterState routerState;

  const ResourcePage(this.routerState, {super.key});

  @override
  Widget build(BuildContext context) {
    final resourceId = routerState.pathParameters['resourceId']!;
    return BasePage(
      child: BlocProvider(
        key: ValueKey(resourceId),
        create: (context) => ResourceCubit(
          context.read<ResourcesRepository>(),
          resourceId: resourceId,
        ),
        child: BlocBuilder<ResourceCubit, ResourceState>(
          builder: (context, state) {
            return switch (state) {
              ResourceLoading() => LoadingView(),
              ResourceError(:final message) => ErrorView(
                message: message,
                onRetryPressed: () => context.read<ResourceCubit>().update(),
              ),
              ResourceValue(:final resource, :final data, :final filter) =>
                Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          resource.namePlural ?? resource.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Spacer(),
                        FilledButton.icon(
                          onPressed: () => context.go('./create'),
                          label: Text(S.of(context).newResource(resource.name)),
                          icon: Icon(Icons.add_outlined),
                        ),
                        SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () =>
                              context.read<ResourceCubit>().update(),
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          tooltip: S.of(context).refresh,
                        ),
                      ],
                    ),
                    FilterView(
                      fields: filter.fields,
                      filters: filter.filters,
                      search: filter.search,
                      onAdd: (model) =>
                          context.read<ResourceCubit>().addFilter(model),
                      onRemove: (idx) =>
                          context.read<ResourceCubit>().removeFilter(idx),
                      onSearchSubmit: (search) =>
                          context.read<ResourceCubit>().updateSearch(search),
                    ),
                    Expanded(
                      child: ResourceList(
                        resource: resource,
                        entries: data,
                        paging: state.paging,
                        onFirstPressed: () =>
                            context.read<ResourceCubit>().firstPage(),
                        onPreviousPressed: () =>
                            context.read<ResourceCubit>().previousPage(),
                        onNextPressed: () =>
                            context.read<ResourceCubit>().nextPage(),
                        onLastPressed: state.paging.total != null
                            ? () => context.read<ResourceCubit>().lastPage()
                            : null,
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
