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
