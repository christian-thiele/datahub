import 'dart:async';

import 'package:boost/src/notifier.dart';

import 'canceled_exception.dart';

class CancellationToken {
  final Notifier _notifier = Notifier();
  bool _cancellationRequested = false;
  final Exception? _cancelException;

  CancellationToken([this._cancelException]);

  bool get cancellationRequested => _cancellationRequested;

  /// Throws the defined exception or [CanceledException] if no custom
  /// exception is defined in the default constructor, when cancellation
  /// has been requested earlier by calling cancel().
  void throwIfCanceled() {
    if (cancellationRequested) {
      throw _cancelException ?? CanceledException();
    }
  }

  /// Notifies listeners about the requested cancellation.
  void cancel() {
    _cancellationRequested = true;
    _notifier.notify();
  }

  /// Attaches a function that will be called when the [CancellationToken]
  /// is canceled.
  ///
  /// See [Notifier].attach().
  Object attach(Function listener) => _notifier.attach(listener);

  /// Detaches a function from the [CancellationToken] so it will not be called
  /// any more.
  ///
  /// See [Notifier].detach().
  void detach(Object key) => _notifier.detach(key);
}

extension CancelableFuture<T> on Future<T> {
  /// Returns a [Future] that either returns the result or error of this
  /// [Future] or contains an Exception when the [CancellationToken] is
  /// notified before this [Future] has completed.
  ///
  /// The [Exception] that is thrown on cancellation is either the
  /// [Exception] given to the [CancellationToken] in the default constructor
  /// or [CanceledException] when no custom [Exception] is defined for the
  /// [CancellationToken]. When null is passed as [CancellationToken], this
  /// [Future] is returned as-is.
  Future<T> cancelOn(CancellationToken? cancellationToken) {
    if (cancellationToken == null) {
      return this;
    }

    final comp = Completer<T>();
    final key = cancellationToken.attach(([e]) {
      if (!comp.isCompleted) {
        comp.completeError(e ?? CanceledException());
      }
    });

    then((value) {
      cancellationToken.detach(key);
      if (!comp.isCompleted) {
        comp.complete(value);
      }
    }).catchError((value) {
      cancellationToken.detach(key);
      if (!comp.isCompleted) {
        comp.completeError(value);
      }
    });

    return comp.future;
  }
}
