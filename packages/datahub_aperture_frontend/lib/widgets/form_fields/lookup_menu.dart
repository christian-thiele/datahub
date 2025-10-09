import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/blocs/resource/resource_cubit.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:datahub_aperture_frontend/widgets/resources/resource_list.dart';
import 'package:datahub_aperture_frontend/widgets/utils/listenable_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LookupMenu extends StatefulWidget {
  final TextEditingController controller;
  final Widget child;
  final FocusNode focusNode;
  final ResourceFieldLookup lookup;

  const LookupMenu({
    super.key,
    required this.child,
    required this.lookup,
    required this.focusNode,
    required this.controller,
  });

  @override
  State<LookupMenu> createState() => _LookupMenuState();
}

class _LookupMenuState extends State<LookupMenu> {
  final layerLink = LayerLink();
  FocusScopeNode? scopeNode;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: widget.focusNode,
      layerLink: layerLink,
      alignmentOffset: Offset(0, 8),
      menuChildren: [
        BlocProvider(
          create: (context) => ResourceCubit(
            context.read<ResourcesRepository>(),
            resourceId: widget.lookup.resourceId,
            initialSearch: widget.controller.text,
          ),
          child: BlocBuilder<ResourceCubit, ResourceState>(
            builder: (context, state) {
              scopeNode = FocusScope.of(context).nearestScope;
              return Builder(
                builder: (context) {
                  return SizedBox(
                    width: layerLink.leaderSize?.width ?? 256,
                    height: 256,
                    child: switch (state) {
                      ResourceLoading() => LoadingView(),
                      ResourceError(:final message) => ErrorView(
                        message: message,
                      ),
                      ResourceValue() => ListenableListener(
                        listenable: widget.controller,
                        onEvent: () => context
                            .read<ResourceCubit>()
                            .updateSearch(widget.controller.text),
                        child: ResourceList(
                          resource: state.resource,
                          entries: state.data,
                          paging: state.paging,
                          onFirstPressed: () =>
                              context.read<ResourceCubit>().lastPage(),
                          onPreviousPressed: () =>
                              context.read<ResourceCubit>().previousPage(),
                          onNextPressed: () =>
                              context.read<ResourceCubit>().nextPage(),
                          onLastPressed: () =>
                              context.read<ResourceCubit>().lastPage(),
                          shrinkWrap: false,
                          onResourceClicked: (item) {
                            widget.controller.text =
                                item.fieldData[widget.lookup.resourceFieldId]
                                    ?.toString() ??
                                '';
                            MenuController.maybeOf(context)?.close();
                          },
                        ),
                      ),
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
      builder: (context, controller, _) {
        return ListenableListener(
          listenable: widget.focusNode,
          onEvent: () {
            if (widget.focusNode.hasFocus) {
              controller.open();
            }
          },
          child: widget.child,
        );
      },
    );
  }
}
