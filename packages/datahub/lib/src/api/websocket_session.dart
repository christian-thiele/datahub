import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:datahub/datahub.dart';

/// Server side of an established websocket connection.
///
/// Control frames are handled internally: incoming pings are answered
/// with pongs, pongs feed the heartbeat timeout and an incoming close
/// frame is echoed before the connection is shut down. Only close and
/// data frames (text, binary, continuation) are forwarded to [stream],
/// which ends when the connection is closed.
///
/// Outgoing frames are sent through [add] / [addStream] or [sink].
/// [close] performs the closing handshake: it flushes pending outgoing
/// frames, sends a close frame and awaits the peer's acknowledgement
/// (up to a grace period) before dropping the TCP connection.
class WebsocketSession implements StreamSink<WebsocketFrame> {
  static const _closeGracePeriod = Duration(seconds: 5);
  static const _encoder = WebsocketFrameEncoder();

  final ApiRequest initialRequest;
  final String acceptKey;
  final String? protocol;
  final io.Socket socket;

  final _sinkController = StreamController<WebsocketFrame>();
  final _streamController = StreamController<WebsocketFrame>();
  final _outgoingFlushed = Completer<void>();
  final _doneCompleter = Completer<void>();

  Timer? _heartbeatTimer;
  Timer? _timeoutTimer;
  bool _closeSent = false;
  bool _socketClosed = false;
  bool _spanStopped = false;
  Future<void>? _closeFuture;

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
    int maxFrameSize = WebsocketFrameDecoder.defaultMaxFrameSize,
  }) {
    _span = _tracer?.startSpan('WS', {
      if (protocol case final protocol?) 'protocol': protocol,
    }, type: SpanType.internal);

    _inTraceZone(() async {
      // write errors surface on socket.done, not on the outgoing stream
      unawaited(
        socket.done.then(
          (_) {},
          onError: (e, stack) => _inTraceZone(() async {
            log.debug('Websocket connection error.', error: e);
          }),
        ),
      );

      _sinkController.stream
          .map((frame) {
            if (frame.opcode == WebsocketOpcode.close) {
              _closeSent = true;
            }
            return frame;
          })
          .transform(_encoder)
          .listen(
            _write,
            onDone: () {
              _outgoingFlushed.complete();
              // closing the sink initiates the closing handshake
              unawaited(close());
            },
            onError: (e, stack) {
              _inTraceZone(() async {
                log.warn('Error in websocket sink.', error: e, stack: stack);
                _failConnection(1011, 'internal error');
              });
            },
          );

      socket
          .transform(WebsocketFrameDecoder(maxFrameSize: maxFrameSize))
          .listen(
            _onFrame,
            onError: _onStreamError,
            onDone: _onSocketDone,
            cancelOnError: false,
          );

      if (heartbeatInterval != null) {
        _heartbeatTimer = Timer.periodic(heartbeatInterval, (timer) {
          if (_socketClosed || _closeSent) {
            return;
          }
          _sendControl(WebsocketFrame.ping());
          _timeoutTimer ??= Timer(heartbeatTimeout, () {
            _inTraceZone(() async {
              log.debug('Websocket heartbeat timed out, closing connection.');
              socket.destroy();
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

  /// Incoming close and data frames.
  ///
  /// This is a single-subscription stream. Control frames (ping, pong)
  /// are handled internally and not forwarded here.
  Stream<WebsocketFrame> get stream => _streamController.stream;

  StreamSink<WebsocketFrame> get sink => this;

  void _write(Uint8List data) {
    if (_socketClosed) {
      return;
    }
    try {
      socket.add(data);
    } catch (_) {
      // socket already closed, teardown follows via _onSocketDone
    }
  }

  void _sendControl(WebsocketFrame frame) =>
      _write(_encoder.encodeFrame(frame));

  void _onFrame(WebsocketFrame frame) {
    switch (frame.opcode) {
      case WebsocketOpcode.ping:
        _sendControl(WebsocketFrame.pong(frame.payload));
      case WebsocketOpcode.pong:
        _timeoutTimer?.cancel();
        _timeoutTimer = null;
      case WebsocketOpcode.close:
        if (!_streamController.isClosed) {
          _streamController.add(frame);
          _streamController.close();
        }
        if (!_closeSent) {
          _closeSent = true;
          // echo the close code (if any) back to the peer
          _sendControl(
            WebsocketFrame(
              WebsocketOpcode.close,
              frame.payload.length >= 2
                  ? Uint8List.sublistView(frame.payload, 0, 2)
                  : Uint8List(0),
            ),
          );
        }
        _flushAndDestroy();
      default:
        if (!_streamController.isClosed) {
          _streamController.add(frame);
        }
    }
  }

  void _onStreamError(Object e, StackTrace stack) {
    if (!_streamController.isClosed) {
      _streamController.addError(e, stack);
    }
    if (e is WebsocketProtocolException) {
      _failConnection(e.closeCode, e.message);
    } else {
      _failConnection(1002, 'protocol error');
    }
  }

  void _failConnection(int code, String reason) {
    if (!_closeSent && !_socketClosed) {
      _closeSent = true;
      _sendControl(WebsocketFrame.close(code, reason));
    }
    _flushAndDestroy();
  }

  void _flushAndDestroy() {
    unawaited(() async {
      try {
        await socket.flush();
      } catch (_) {}
      socket.destroy();
    }());
  }

  void _onSocketDone() {
    _socketClosed = true;
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();
    socket.destroy();
    if (!_sinkController.isClosed) {
      _sinkController.close();
    }
    if (!_streamController.isClosed) {
      _streamController.close();
    }
    if (!_spanStopped) {
      _spanStopped = true;
      _span?.stop();
    }
    if (!_doneCompleter.isCompleted) {
      _doneCompleter.complete();
    }
  }

  /// Performs the closing handshake and shuts down the connection.
  ///
  /// Pending outgoing frames are flushed before the close frame is sent.
  /// Completes when the connection is fully closed, or after a grace
  /// period if the peer does not complete the handshake in time.
  @override
  Future<void> close([int? code, String? reason]) =>
      _closeFuture ??= _doClose(code, reason);

  Future<void> _doClose(int? code, String? reason) async {
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();

    if (!_sinkController.isClosed) {
      await _sinkController.close();
    }
    await _outgoingFlushed.future;

    if (!_closeSent && !_socketClosed) {
      _closeSent = true;
      _sendControl(WebsocketFrame.close(code, reason));
    }

    try {
      await socket.flush();
    } catch (_) {}

    // wait for the peer to acknowledge the close handshake
    await _doneCompleter.future.timeout(
      _closeGracePeriod,
      onTimeout: socket.destroy,
    );
  }

  @override
  void add(WebsocketFrame event) {
    if (_closeSent || _sinkController.isClosed) {
      throw StateError('WebsocketSession is already closed.');
    }
    _sinkController.add(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _sinkController.addError(error, stackTrace);

  @override
  Future<void> addStream(Stream<WebsocketFrame> stream) => stream.forEach(add);

  /// Completes when the connection is fully closed.
  @override
  Future<void> get done => _doneCompleter.future;
}
