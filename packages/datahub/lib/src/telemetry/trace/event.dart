import 'package:datahub/api.dart';

class Event {
  final String name;
  final Map<String, dynamic> attributes;
  final DateTime timestamp;

  Event({
    required this.name,
    required this.attributes,
    required this.timestamp,
  });
}

class ExceptionEvent extends Event {
  final dynamic error;

  ExceptionEvent({required this.error, required super.timestamp})
    : super(
        name: 'Exception: $error',
        attributes: {
          'exception.type': error.runtimeType.toString(),
          'exception.message': switch (error) {
            ApiRequestException() => error.message,
            _ => error.toString(),
          },
          if (error is ApiRequestException) 'exception.data': error.data,
        },
      );
}
