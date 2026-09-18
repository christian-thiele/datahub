import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture_frontend/blocs/resource/resource_cubit.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/repositories/resources_repository/resources_repository.dart';
import 'package:datahub_aperture_frontend/widgets/error_view.dart';
import 'package:datahub_aperture_frontend/widgets/loading_view.dart';
import 'package:datahub_aperture_frontend/widgets/resources/resource_list.dart';
import 'package:datahub_aperture_frontend/widgets/utils/listenable_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LookupMenu extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ResourceFieldLookup lookup;
  final Object? value;
  final InputDecoration decoration;
  final Widget Function(InputDecoration decoration, TextStyle? style)
  fieldBuilder;

  const LookupMenu({
    super.key,
    required this.lookup,
    required this.focusNode,
    required this.controller,
    required this.value,
    required this.decoration,
    required this.fieldBuilder,
  });

  @override
  State<LookupMenu> createState() => _LookupMenuState();
}

class _LookupMenuState extends State<LookupMenu> {
  final layerLink = LayerLink();
  FocusScopeNode? scopeNode;
  String? _linkedValue;
  String? _linkedId;
  bool? _found;
  String? _title;

  /// Whether the unfocus after a pick (see [_pick]) is still to arrive.
  ///
  /// [widget.value] takes a moment to catch up with a pick, arriving through
  /// [widget.controller] and the field's `onChanged`. Until it does, this
  /// tells the blur that follows the pick not to reload the link, which
  /// would otherwise find [_linkedValue] "outdated" against the old
  /// [widget.value] and momentarily undo what the pick just showed.
  bool _pickPending = false;

  bool get _isLinkOutdated =>
      !widget.focusNode.hasFocus && widget.value?.toString() != _linkedValue;

  @override
  void initState() {
    super.initState();
    _loadLink();
  }

  @override
  void didUpdateWidget(covariant LookupMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isLinkOutdated) {
      _loadLink();
    }
  }

  void _onFocusChanged() {
    setState(() {
      if (_pickPending) {
        _pickPending = false;
      } else if (_isLinkOutdated) {
        _loadLink();
      }
    });
  }

  void _pick(ResourceData element, ResourceDescription resource) {
    final value =
        element.fieldData[widget.lookup.resourceFieldId]?.toString() ?? '';
    setState(() {
      _pickPending = true;
      _linkedValue = value;
      _found = true;
      _title = element.fieldData[resource.displayField]?.toString();
      _linkedId = element.id;
    });
    widget.controller.text = value;
  }

  Future<void> _loadLink() async {
    final value = _linkedValue = widget.value?.toString();
    _found = null;
    _title = null;
    _linkedId = null;
    if (value == null || value.isEmpty) {
      _found = false;
      return;
    }

    final repository = context.read<ResourcesRepository>();
    final lookup = widget.lookup;
    try {
      final (resource, elements) = await (
        repository.getDescription(lookup.resourceId),
        repository.getResourceElements(
          lookup.resourceId,
          filter: ResourceFilter(
            fieldId: lookup.resourceFieldId,
            type: ResourceFilterType.equals,
            value: value,
          ),
          limit: 1,
        ),
      ).wait;

      // The backend ignores filters for values it can not convert.
      final element = elements.data
          .where(
            (e) => e.fieldData[lookup.resourceFieldId]?.toString() == value,
          )
          .firstOrNull;
      if (mounted && value == _linkedValue) {
        setState(() {
          _found = element != null;
          _title = element?.fieldData[resource.displayField]?.toString();
          _linkedId = element?.id;
        });
      }
    } catch (_) {
      // Whether the element exists stays unknown.
    }
  }

  Widget _buildField(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLinkKnown = widget.value?.toString() == _linkedValue;
    final title = isLinkKnown && !widget.focusNode.hasFocus ? _title : null;

    return widget.fieldBuilder(
      widget.decoration.copyWith(
        prefix: title != null
            ? Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.primary),
              )
            : null,
        suffixIcon: switch (isLinkKnown ? _found : null) {
          true => InkWell(
            onTap: _linkedId != null
                ? () => context.push(
                    Uri(
                      path:
                          '/resources/${Uri.encodeComponent(widget.lookup.resourceId)}/view/${Uri.encodeComponent(_linkedId!)}',
                    ).toString(),
                  )
                : null,
            child: Icon(Icons.link, color: colors.primary),
          ),
          false => Tooltip(
            message: S.of(context).linkedElementNotFound,
            child: Icon(Icons.link_off, color: colors.outline),
          ),
          null => Icon(Icons.link, color: colors.outlineVariant),
        },
      ),
      // Hides the value, which stays in the field for editing.
      title != null ? const TextStyle(color: Colors.transparent) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      childFocusNode: widget.focusNode,
      layerLink: layerLink,
      alignmentOffset: Offset(0, 8),
      menuChildren: [
        TextFieldTapRegion(
          child: BlocProvider(
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
                                context.read<ResourceCubit>().firstPage(),
                            onPreviousPressed: () =>
                                context.read<ResourceCubit>().previousPage(),
                            onNextPressed: () =>
                                context.read<ResourceCubit>().nextPage(),
                            onLastPressed: () =>
                                context.read<ResourceCubit>().lastPage(),
                            shrinkWrap: false,
                            onResourceClicked: (item) {
                              _pick(item, state.resource);
                              MenuController.maybeOf(context)?.close();
                              widget.focusNode.unfocus();
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
        ),
      ],
      builder: (context, controller, _) {
        return ListenableListener(
          listenable: widget.focusNode,
          onEvent: () {
            if (widget.focusNode.hasFocus) {
              controller.open();
            }
            _onFocusChanged();
          },
          child: _buildField(context),
        );
      },
    );
  }
}
