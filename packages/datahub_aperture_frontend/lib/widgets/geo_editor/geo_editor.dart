import 'package:datahub/data.dart' as data;
import 'package:datahub_aperture_frontend/blocs/geo_editor/geo_editor_cubit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import 'geo_camera.dart';
import 'geo_editor_controls.dart';
import 'geo_hit_test.dart';
import 'layers/geo_feature_layer.dart';
import 'layers/geo_handle_layer.dart';
import 'model/geo_feature.dart';
import 'model/geo_type_restriction.dart';

/// An editor for a single geometry value.
///
/// Points, lines, polygons (including holes) and any combination of those are
/// supported. Which of them can be drawn and how they are stored is decided by
/// [restriction]: a value restricted to `Polygon` only offers the polygon tool
/// and only until one polygon exists, while a value that allows
/// `GeometryCollection` can hold a mix of everything.
///
/// The editor is read-only when [onChanged] is `null`.
class GeoEditor extends StatefulWidget {
  final data.Geometry? value;
  final GeoTypeRestriction restriction;
  final ValueChanged<data.Geometry?>? onChanged;
  final String tileUrlTemplate;
  final String userAgentPackageName;

  const GeoEditor({
    super.key,
    this.value,
    this.restriction = const GeoTypeRestriction.any(),
    this.onChanged,
    this.tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.userAgentPackageName = 'net.datahubproject.aperture',
  });

  @override
  State<GeoEditor> createState() => _GeoEditorState();
}

class _GeoEditorState extends State<GeoEditor> {
  late GeoEditorCubit _cubit = _createCubit();

  /// The last value handed to [GeoEditor.onChanged], to tell an echo of our
  /// own change apart from a value replaced from the outside.
  data.Geometry? _emitted;

  GeoEditorCubit _createCubit() => GeoEditorCubit(
    restriction: widget.restriction,
    value: _emitted = widget.value,
  );

  @override
  void didUpdateWidget(covariant GeoEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.restriction != oldWidget.restriction) {
      _cubit.close();
      setState(() => _cubit = _createCubit());
    } else if (widget.value != oldWidget.value && widget.value != _emitted) {
      _cubit.setValue(_emitted = widget.value);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _cubit,
    child: BlocListener<GeoEditorCubit, GeoEditorState>(
      listenWhen: (previous, current) =>
          !current.isDragging &&
          (previous.document != current.document || previous.isDragging),
      listener: (context, state) {
        final geometry = state.document.toGeometry(widget.restriction);
        if (geometry == _emitted) {
          return;
        }

        _emitted = geometry;
        widget.onChanged?.call(geometry);
      },
      child: _GeoEditorMap(
        restriction: widget.restriction,
        readOnly: widget.onChanged == null,
        tileUrlTemplate: widget.tileUrlTemplate,
        userAgentPackageName: widget.userAgentPackageName,
      ),
    ),
  );
}

class _GeoEditorMap extends StatefulWidget {
  final GeoTypeRestriction restriction;
  final bool readOnly;
  final String tileUrlTemplate;
  final String userAgentPackageName;

  const _GeoEditorMap({
    required this.restriction,
    required this.readOnly,
    required this.tileUrlTemplate,
    required this.userAgentPackageName,
  });

  @override
  State<_GeoEditorMap> createState() => _GeoEditorMapState();
}

class _GeoEditorMapState extends State<_GeoEditorMap> {
  final _mapKey = GlobalKey();
  final _focusNode = FocusNode(debugLabel: 'GeoEditor');
  final _controller = MapControllerImpl();

  /// What the pointer is over, drawn highlighted and used for the cursor.
  GeoTarget? _hovered;

  /// The target a pointer went down on, resolved before the drag is claimed.
  GeoTarget? _pendingDrag;

  /// The vertex the ongoing drag moves.
  GeoVertexRef? _dragging;

  /// Distance between the pointer and the dragged handle when it was grabbed,
  /// so that the handle does not jump under the pointer.
  Offset _dragGrab = Offset.zero;

  /// The camera fit applied when the map is first laid out.
  CameraFit? _initialFit;

  GeoEditorCubit get _cubit => context.read<GeoEditorCubit>();

  GeoEditorState get _state => _cubit.state;

  MapCamera get _camera => _controller.camera;

  GeoHitTester get _tester => GeoHitTester(camera: _camera, state: _state);

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Offset? _localOf(Offset global) {
    final box = _mapKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.globalToLocal(global);
  }

  GeoTarget? _targetAt(Offset? local) =>
      local == null ? null : _tester.hitTest(local, handles: !widget.readOnly);

  LatLng? _positionOf(GeoVertexRef ref) {
    final feature = _state.document.featureAt(ref.feature);
    if (feature == null || ref.part >= feature.parts.length) {
      return null;
    }

    final part = feature.parts[ref.part];
    return ref.index < part.length ? part[ref.index].position : null;
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    _focusNode.requestFocus();
    final target = _targetAt(
      tapPosition.relative ?? _localOf(tapPosition.global),
    );

    if (_state.draft case final draft?) {
      final closes =
          target is GeoDraftVertexTarget &&
          draft.canComplete &&
          (target.index == 0 || target.index == draft.vertices.length - 1);

      return closes ? _cubit.completeDraft() : _cubit.addAt(point);
    }

    if (_state.tool.isDrawing) {
      return _cubit.addAt(point);
    }

    switch (target) {
      case GeoVertexTarget(:final ref):
        _cubit.selectVertex(ref);
      case GeoMidpointTarget(:final ref, :final position):
        _cubit.insertVertex(ref, position);
      case GeoFeatureTarget(:final index):
        _cubit.selectFeature(index);
      case GeoDraftVertexTarget():
      case null:
        _cubit.selectFeature(null);
    }
  }

  void _onSecondaryTap(TapPosition tapPosition, LatLng point) {
    if (widget.readOnly) {
      return;
    }

    if (_state.draft != null) {
      return _cubit.completeDraft();
    }

    final target = _targetAt(
      tapPosition.relative ?? _localOf(tapPosition.global),
    );

    if (target case GeoVertexTarget(:final ref)) {
      _cubit.removeVertex(ref);
    }
  }

  void _onLongPress(TapPosition tapPosition, LatLng point) {
    if (_state.draft != null) {
      _cubit.completeDraft();
    }
  }

  void _onHover(PointerHoverEvent event) {
    if (_state.draft != null) {
      _cubit.moveCursor(_camera.screenOffsetToLatLng(event.localPosition));
    }

    final target = _targetAt(event.localPosition);
    if (target != _hovered) {
      setState(() => _hovered = target);
    }
  }

  void _onExit(PointerExitEvent event) {
    _cubit.moveCursor(null);
    if (_hovered != null) {
      setState(() => _hovered = null);
    }
  }

  /// Decides whether a pointer going down starts a handle drag instead of a
  /// map pan.
  bool _canDrag(Offset global) {
    if (widget.readOnly || _state.draft != null) {
      return false;
    }

    final target = _targetAt(_localOf(global));
    _pendingDrag = switch (target) {
      GeoVertexTarget() || GeoMidpointTarget() => target,
      GeoFeatureTarget(:final index)
          when _state.document.featureAt(index) is GeoPointFeature =>
        target,
      _ => null,
    };

    return _pendingDrag != null;
  }

  void _onDragStart(DragStartDetails details) {
    final target = _pendingDrag;
    _cubit.setDragging(true);
    final local = _localOf(details.globalPosition);
    _pendingDrag = null;
    if (target == null || local == null) {
      return;
    }

    final GeoVertexRef ref;
    final LatLng? anchor;
    switch (target) {
      case GeoVertexTarget(ref: final vertex):
        ref = vertex;
        anchor = _positionOf(vertex);
      case GeoMidpointTarget(ref: final vertex, position: final midpoint):
        _cubit.insertVertex(vertex, midpoint);
        ref = vertex;
        anchor = midpoint;
      case GeoFeatureTarget(:final index):
        ref = GeoVertexRef(index, 0, 0);
        anchor = _positionOf(ref);
      case GeoDraftVertexTarget():
        return;
    }

    if (anchor == null) {
      return;
    }

    _cubit.selectVertex(ref);
    setState(() {
      _dragging = ref;
      _dragGrab = _camera.latLngToScreenOffset(anchor!) - local;
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final ref = _dragging;
    final local = _localOf(details.globalPosition);
    if (ref == null || local == null) {
      return;
    }

    _cubit.moveVertex(
      ref,
      _tester.draggedPosition(local, _dragGrab, _camera.nonRotatedSize),
    );
  }

  void _onDragEnd([DragEndDetails? details]) {
    _cubit.setDragging(false);
    if (_dragging != null) {
      setState(() => _dragging = null);
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.readOnly || event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        if (_state.draft != null || _state.tool.isDrawing) {
          _cubit.cancelDraft();
        } else {
          _cubit.selectFeature(null);
        }
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.numpadEnter:
        if (_state.draft == null) {
          return KeyEventResult.ignored;
        }
        _cubit.completeDraft();
      case LogicalKeyboardKey.backspace:
        if (_state.draft != null) {
          _cubit.removeLastDraftVertex();
        } else if (_state.hasSelection) {
          _cubit.removeSelection();
        } else {
          return KeyEventResult.ignored;
        }
      case LogicalKeyboardKey.delete:
        if (!_state.hasSelection) {
          return KeyEventResult.ignored;
        }
        _cubit.removeSelection();
      default:
        return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  void _onToolPressed(GeoEditorTool tool) {
    _focusNode.requestFocus();
    _cubit.selectTool(tool);
  }

  void _fit() {
    final selection = _state.selection;
    _controller.fitPositions(selection?.positions ?? _state.document.positions);
  }

  MouseCursor _cursorOf(GeoEditorState state) {
    if (widget.readOnly) {
      return MouseCursor.defer;
    }

    if (_dragging != null) {
      return SystemMouseCursors.grabbing;
    }

    if (state.tool.isDrawing) {
      return SystemMouseCursors.precise;
    }

    return switch (_hovered) {
      GeoVertexTarget() || GeoMidpointTarget() => SystemMouseCursors.grab,
      GeoFeatureTarget() => SystemMouseCursors.click,
      _ => MouseCursor.defer,
    };
  }

  int? _highlightedFeature() => switch (_hovered) {
    GeoFeatureTarget(:final index) => index,
    _ => null,
  };

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<GeoEditorCubit, GeoEditorState>(
        builder: (context, state) {
          // Only the fit of the first build is used by the map, but computing
          // it once also keeps [MapOptions] stable across rebuilds.
          _initialFit ??= cameraFitOf(state.document.positions);
          return _buildMap(state);
        },
      );

  Widget _buildMap(GeoEditorState state) => Focus(
    focusNode: _focusNode,
    onKeyEvent: _onKeyEvent,
    child: MouseRegion(
      cursor: _cursorOf(state),
      onHover: _onHover,
      onExit: _onExit,
      child: FlutterMap(
        key: _mapKey,
        mapController: _controller,
        options: MapOptions(
          initialCameraFit: _initialFit,
          // Double tap zoom holds every tap back for the length of the double
          // tap window, which is too long when a tap places a vertex. Scroll,
          // pinch and double tap drag still zoom.
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.doubleTapZoom,
          ),
          onTap: _onTap,
          onSecondaryTap: _onSecondaryTap,
          onLongPress: _onLongPress,
        ),
        children: [
          TileLayer(
            urlTemplate: widget.tileUrlTemplate,
            userAgentPackageName: widget.userAgentPackageName,
          ),
          Positioned.fill(
            child: GeoFeatureLayer(
              state: state,
              highlighted: _highlightedFeature(),
            ),
          ),
          if (!widget.readOnly) ...[
            Positioned.fill(
              child: GeoHandleLayer(state: state, highlighted: _hovered),
            ),
            Positioned.fill(child: _dragDetector()),
          ],
          Positioned.fill(
            child: GeoEditorControls(
              state: state,
              restriction: widget.restriction,
              readOnly: widget.readOnly,
              onFitPressed: _fit,
              onToolPressed: _onToolPressed,
              onFinishPressed: _cubit.completeDraft,
              onUndoPressed: _cubit.removeLastDraftVertex,
              onCancelPressed: _cubit.cancelDraft,
              onDeletePressed: _cubit.removeSelection,
            ),
          ),
          Positioned.fill(
            child: GeoEditorHint(
              state: state,
              restriction: widget.restriction,
              readOnly: widget.readOnly,
            ),
          ),
        ],
      ),
    ),
  );

  /// Claims the drag gesture only when it starts on a handle, so that dragging
  /// anywhere else still pans the map.
  Widget _dragDetector() => RawGestureDetector(
    behavior: HitTestBehavior.translucent,
    gestures: {
      _HandleDragRecognizer:
          GestureRecognizerFactoryWithHandlers<_HandleDragRecognizer>(
            () => _HandleDragRecognizer(canStart: _canDrag, debugOwner: this),
            (instance) => instance
              ..onStart = _onDragStart
              ..onUpdate = _onDragUpdate
              ..onEnd = _onDragEnd
              ..onCancel = _onDragEnd,
          ),
    },
  );
}

/// A pan recognizer that only enters the gesture arena when the pointer went
/// down on something draggable, leaving map panning untouched otherwise.
class _HandleDragRecognizer extends PanGestureRecognizer {
  final bool Function(Offset globalPosition) canStart;

  _HandleDragRecognizer({required this.canStart, super.debugOwner});

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) && canStart(event.position);

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);

    // A pointer that went down on a handle belongs to the editor, however it
    // continues. Competing for it would lose: the map claims drags at a lower
    // threshold than a pan recognizer reaches, and its long press claims the
    // pointer outright after half a second of holding still.
    resolve(GestureDisposition.accepted);
  }
}
