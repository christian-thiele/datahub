import 'dart:async';
import 'dart:collection';

class StreamBatchListener<T> {
  final Stream<T> stream;
  final _queue = Queue<_Event<T>>();
  final _completerQueue = Queue<Completer<_Event<T>>>();
  late final StreamSubscription _subscription;

  StreamBatchListener(this.stream) {
    _subscription = stream.listen(
      (e) {
        _add(_DataEvent(e));
      },
      onError: (e, stack) => _add(_ErrorEvent(e, stack)),
      onDone: () => _add(_DoneEvent()),
    );
  }

  void _add(_Event<T> event) {
    if (_completerQueue.isNotEmpty) {
      _completerQueue.removeFirst().complete(event);
    } else {
      _queue.add(event);
    }
  }

  Future<_Event<T>> get _nextEvent async {
    if (_queue.isNotEmpty) {
      return _queue.removeFirst();
    } else {
      final comp = Completer<_Event<T>>();
      _completerQueue.add(comp);
      return comp.future;
    }
  }

  Future<T> get next async {
    final event = await _nextEvent;
    if (event is _DataEvent) {
      return (event as _DataEvent).data;
    } else if (event is _ErrorEvent) {
      throw (event as _ErrorEvent).error;
    } else {
      throw Exception('Done.');
    }
  }

  bool get hasNext => _queue.isNotEmpty;

  void cancel() => _subscription.cancel();
}

abstract class _Event<T> {}

class _DataEvent<T> extends _Event<T> {
  final T data;

  _DataEvent(this.data);
}

class _ErrorEvent<T> extends _Event<T> {
  final dynamic error;
  final StackTrace stack;

  _ErrorEvent(this.error, this.stack);
}

class _DoneEvent<T> extends _Event<T> {}
