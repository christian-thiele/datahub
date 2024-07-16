import 'package:datahub/api.dart';

class Event {
  final String name;
  final Map<String, dynamic> arguments;
  final DateTime timestamp;

  Event({
    required this.name,
    required this.arguments,
    required this.timestamp,
  });
}

class ExceptionEvent extends Event {
  final dynamic error;

  ExceptionEvent({
    required this.error,
    required super.timestamp,
  }) : super(
          name: 'Exception: $error',
          arguments: {
            'exception': {
              'type': '${error.runtimeType}',
              'asString': error.toString(),
              if (error is ApiRequestException) 'data': error.data,
            },
          },
        );
}
