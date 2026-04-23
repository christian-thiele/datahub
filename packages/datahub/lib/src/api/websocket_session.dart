import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub/scaffold.dart';

import 'api_request.dart';
import 'websocket_frame.dart';

class WebsocketSession implements StreamSink<WebsocketFrame> {
  final ApiRequest initialRequest;
  final String acceptKey;
  final String protocol;
  final io.Socket socket;

  final _sinkController = StreamController<WebsocketFrame>();
  Timer? _heartbeatTimer;
  Timer? _timeoutTimer;

  final _tracer = Context.maybeOfZone()
      ?.find(Find<Telemetry>())
      .getDefaultTracer();

  late final LocalSpan? _span;

  WebsocketSession({
    required this.initialRequest,
    required this.acceptKey,
    required this.protocol,
    required this.socket,
    Duration? heartbeatInterval,
    Duration heartbeatTimeout = const Duration(seconds: 30),
  }) {
    _span = _tracer?.startSpan('WS', {
      'protocol': protocol,
    }, type: SpanType.internal);

    _inTraceZone(() async {
      _sinkController.stream
          .transform(const WebsocketFrameEncoder())
          .listen(
            socket.add,
            onDone: () async {
              await socket.close();
              _span?.stop();
            },
            onError: (_) {
              _inTraceZone(() async {
                await close(1006, 'internal error');
              });
            },
          );

      if (heartbeatInterval != null) {
        _heartbeatTimer = Timer.periodic(heartbeatInterval, (timer) {
          _sinkController.add(WebsocketFrame.ping());
          _timeoutTimer ??= Timer(heartbeatTimeout, () {
            _inTraceZone(() async {
              close(1006, 'ping timeout');
            });
          });
        });
      }
    });
  }

  Future<R> _inTraceZone<R>(Future<R> Function() delegate) async {
    if (_tracer != null && _span != null) {
      return await _tracer.runInSpanZone(_span, (_) => delegate());
    } else {
      return await delegate();
    }
  }

  Stream<WebsocketFrame> get stream => socket
      .map((data) => Uint8List.fromList(data))
      .transform(const WebsocketFrameDecoder())
      .map((frame) {
        if (frame.opcode == WebsocketOpcode.pong) {
          _timeoutTimer?.cancel();
          _timeoutTimer = null;
        }
        return frame;
      });

  StreamSink<WebsocketFrame> get sink => _sinkController.sink;

  @override
  Future<void> close([int? code, String? reason]) async {
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();
    sink.add(WebsocketFrame.close(code, reason));
    if (!_sinkController.isClosed) {
      _sinkController.close();
    }
  }

  @override
  void add(WebsocketFrame event) => _sinkController.sink.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _sinkController.addError(error, stackTrace);

  @override
  Future<dynamic> addStream(Stream<WebsocketFrame> stream) =>
      _sinkController.sink.addStream(stream);

  @override
  Future<dynamic> get done => _sinkController.done;
}
