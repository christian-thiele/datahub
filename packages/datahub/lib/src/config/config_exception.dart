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

/// Thrown when a [Config] itself is declared incorrectly, e.g. an enum typed
/// config that does not provide the list of possible values.
///
/// This indicates a mistake in the application code rather than in the
/// configuration that was supplied at runtime.
class ConfigDeclarationException extends ConfigException {
  ConfigDeclarationException(super.path, super.message);
}

/// Thrown when configuration references ($-syntax) form a cycle.
class ConfigReferenceException extends ConfigException {
  /// The chain of references that led back to [path], in the order they were
  /// followed.
  final List<String> references;

  ConfigReferenceException(String path, this.references)
    : super(
        path,
        'Circular configuration reference: ${references.join(' -> ')}.',
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
