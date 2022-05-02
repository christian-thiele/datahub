class ConfigException implements Exception {
  final String path;
  final String message;

  ConfigException(this.path, this.message);

  @override
  String toString() => message;
}

class ConfigPathException extends ConfigException {
  final String element;

  ConfigPathException(String path, this.element)
      : super(
          path,
          'ConfigPathException: Path "$path" could not be resolved. '
          'Missing element: "$element".',
        );
}

class ConfigTypeException extends ConfigException {
  final Type expectedType;
  final Type actualType;

  ConfigTypeException(String path, this.expectedType, this.actualType)
      : super(
          path,
          'ConfigTypeException: Config value at path "$path" '
          'is of type "$actualType" while "$expectedType" is expected.',
        );
}
