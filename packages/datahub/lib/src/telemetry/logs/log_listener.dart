import 'dart:async';

import 'package:datahub/datahub.dart';

class LogListener({
  /// Callback for when a log message is published from within the LogListeners
  /// Zone.
  required final void Function(LogMessage) onPublish,
}) {
  static const _symbol = #datahub.logListener;

  static LogListener? get current => Zone.current[_symbol];

  late final LogListener? parent;

  this {
    parent = Zone.current[_symbol];
  }

  R run<R>(R Function() body) {
    return runZoned<R>(body, zoneValues: {_symbol: this});
  }

  /// Calls [onPublish] of this listener and all of its parents.
  void publishLog(LogMessage message) {
    try {
      onPublish(message);
    } finally {
      parent?.publishLog(message);
    }
  }
}
