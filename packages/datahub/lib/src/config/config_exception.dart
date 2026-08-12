import 'package:datahub/utils.dart';

class ConfigException extends ApiException {
  final String path;

  ConfigException(this.path, super.message);
}

class ConfigPathException extends ConfigException {
  ConfigPathException(String path)
    : super(path, 'Configuration does not provide a value for "$path".');
}

class ConfigTypeException extends ConfigException {
  final Type expectedType;
  final Type actualType;

  ConfigTypeException(String path, this.expectedType, this.actualType)
    : super(
        path,
        'Config value at path "$path" is of type "$actualType" '
        'while "$expectedType" is expected.',
      );
}

/// Thrown when a config value is well typed but not one of the accepted
/// values, e.g. an unknown name for an enum typed config.
class ConfigValueException extends ConfigException {
  final String value;
  final List<String> allowedValues;

  ConfigValueException(String path, this.value, this.allowedValues)
    : super(
        path,
        'Config value at path "$path" is "$value" '
        'while one of ${allowedValues.map((v) => '"$v"').join(', ')} '
        'is expected.',
      );
}
