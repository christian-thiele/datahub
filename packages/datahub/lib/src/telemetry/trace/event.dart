import 'dart:convert';

import 'package:datahub/api.dart';

class Event({
  required final String name,
  required final Map<String, Object?> attributes,
  required final DateTime timestamp,
});

/// An exception recorded on a span, according to the semantic conventions
/// for exceptions (event name `exception`).
class ExceptionEvent({
  required final Object error,
  final StackTrace? stack,
  required super.timestamp,
}) extends Event {
  this
    : super(
        name: 'exception',
        attributes: {
          'exception.type': error.runtimeType.toString(),
          'exception.message': messageOf(error),
          if (stack != null) 'exception.stacktrace': stack.toString(),
          if (error is ApiRequestException)
            'datahub.exception.data': _encode(error.data),
        },
      );

  /// The message of [error], without the type name where possible.
  static String messageOf(Object error) => switch (error) {
    ApiRequestException(:final message) => message,
    _ => error.toString(),
  };

  static String _encode(Object? data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }
}
