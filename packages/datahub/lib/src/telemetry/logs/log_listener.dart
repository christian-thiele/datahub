import 'dart:async';

import 'package:datahub/datahub.dart';

class LogListener {
  static const _symbol = #datahub.logListener;

  static LogListener? get current => Zone.current[_symbol];

  /// Callback for when a log message is published from within the LogListeners
  /// Zone.
  final void Function(LogMessage) onPublish;

  late final LogListener? parent;

  LogListener({required this.onPublish}) {
    parent = Zone.current[_symbol];
  }

  R run<R>(R Function() body) {
    return runZoned<R>(body, zoneValues: {_symbol: this});
  }

  void publishLog(LogMessage message) {
    onPublish(message);
    parent?.publishLog(message);
  }
}
