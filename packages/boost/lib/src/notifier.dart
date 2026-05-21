class Notifier {
  final _listeners = <Object, Function>{};
  final _oneShotKeys = <Object>[];

  /// Calls all attached listeners and detaches one-shot listeners
  /// after notifying.
  void notify() {
    _listeners.values.forEach((listener) => listener.call());
    _oneShotKeys.forEach(detach);
    _oneShotKeys.clear();
  }

  /// Attaches a function that will be executed when notify() is called.
  ///
  /// Returns a key object that can be used to detach the listener
  /// from the notifier to stop execution on notify() call and
  /// avoid memory leaks.
  Object attach(Function listener) {
    final key = Object();
    _listeners[key] = listener;
    return key;
  }

  /// Attaches a function that will be executed when notify() is called.
  /// The listener is detached automatically on notify(), which invalidates
  /// the listener key after first invocation.
  ///
  /// Returns a key object that can be used to detach the listener
  /// from the notifier to stop execution on notify() call and
  /// avoid memory leaks.
  Object attachOneShot(Function listener) {
    final key = attach(listener);
    _oneShotKeys.add(key);
    return key;
  }

  /// Detaches a listener function.
  ///
  /// The [key] param used to identify a listener is returned by the attach
  /// method.
  void detach(Object key) => _listeners.remove(key);
}
