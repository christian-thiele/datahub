import 'dart:async';

import 'package:boost/boost.dart';

/// A [Lazy] can be used to only initialize a value if it is required.
///
/// The [_initialize] function is only called to initialize the value.
/// After the first initialization [_initialize] is only called again if
/// one of the following cases applies:
/// - [reinitializeOnValue] returns true
/// - the last invocation of [_initialize] has thrown an error and
///   [reinitializeOnError] is true
/// - [invalidate] was called after the last but before the current call to [get]
///
/// If the first [get] call is still in progress, any subsequent call to [get]
/// will wait for the result of the first invocation and return the same result.
///
/// If [_initialize] throws an exception every call to [get] will re-throw this
/// exception.
class Lazy<T> {
  final _semaphore = Semaphore();
  final FutureOr<T> Function() _initialize;
  final FutureOr<bool> Function(T value) _reinitialize;
  bool _initialized = false;
  final bool reinitializeOnError;
  dynamic _error;
  late T _value;

  /// [_initialize] is used to initialize the value.
  /// [reinitialize] controls if a value is reused or initialized again.
  /// If [reinitialize] returns true, [_initialize] is called again to recreate
  /// the value.
  Lazy(
    this._initialize, {
    FutureOr<bool> Function(T value)? reinitializeOnValue,
    this.reinitializeOnError = false,
  }) : _reinitialize = reinitializeOnValue ?? ((_) => false);

  /// Returns true if the this [Lazy] already has a result.
  bool get isInitialized => _initialized;

  /// Receives the value returned by [initialize].
  ///
  /// This method only invokes [initialize] if it has not been called before.
  Future<T> get() async {
    return await _semaphore.runLocked(() async {
      if (_initialized) {
        if (_error != null) {
          if (reinitializeOnError) {
            invalidate();
          }
        } else if (await _reinitialize(_value)) {
          invalidate();
        }
      }

      if (_initialized) {
        if (_error != null) {
          throw _error;
        } else {
          return _value;
        }
      } else {
        try {
          _value = await _initialize();
        } catch (e) {
          _error = e;
        } finally {
          _initialized = true;
        }
      }

      if (_error != null) {
        throw _error;
      }

      return _value;
    });
  }

  void invalidate() {
    _initialized = false;
    _error = null;
  }
}
