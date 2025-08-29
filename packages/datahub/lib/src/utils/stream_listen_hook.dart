import 'dart:async';

class StreamListenHook<T> extends StreamTransformerBase<T, T> {
  late final StreamSubscription _subscription;
  late final Stream<T> _source;
  late final _controller = StreamController<T>(
    onCancel: () => _subscription.cancel(),
    onPause: () => _subscription.pause(),
    onResume: () => _subscription.resume(),
    onListen: _listen,
  );

  final void Function() onListen;

  StreamListenHook(this.onListen);

  @override
  Stream<T> bind(Stream<T> stream) {
    _source = stream;
    return _controller.stream;
  }

  void _listen() {
    onListen();
    _subscription = _source.listen(
      _controller.add,
      onError: _controller.addError,
      onDone: _controller.close,
    );
  }
}
