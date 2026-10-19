import 'package:datahub/utils.dart';

class ConfigException(final String path, super.message) extends ApiException;

class ConfigPathException(
  String path, {

  /// An existing config path that closely resembles [path], if the
  /// configuration holds one.
  final String? suggestion,
}) extends ConfigException {
  this
    : super(
        path,
        'Configuration does not provide a value for "$path".'
        '${suggestion == null ? '' : ' Did you mean "$suggestion"?'}',
      );
}

/// Thrown when a config path is not well formed, e.g. because one of its
/// segments is empty.
class InvalidConfigPathException(
  String path,

  /// The offending segment of [path].
  final String segment,
) extends ConfigException {
  this
    : super(
        path,
        'Config path "$path" is not well formed: "$segment" is not a valid '
        'segment. Segments are separated by "." and must not be empty.',
      );
}

/// Thrown when a config file cannot be read or does not contain a valid
/// configuration.
class ConfigFileException(
  /// The path of the offending file.
  final String file,
  String message,
) extends ConfigException {
  this : super('', 'Config file "$file" $message');
}

class ConfigTypeException(
  String path,
  final Type expectedType,
  final Type actualType,
) extends ConfigException {
  this
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
class ConfigDeclarationException(super.path, super.message)
    extends ConfigException;

/// Thrown when configuration references ($-syntax) form a cycle.
class ConfigReferenceException(
  String path,

  /// The chain of references that led back to [path], in the order they were
  /// followed.
  final List<String> references,
) extends ConfigException {
  this
    : super(
        path,
        'Circular configuration reference: ${references.join(' -> ')}.',
      );
}

/// Thrown when a config value is well typed but not one of the accepted
/// values, e.g. an unknown name for an enum typed config.
class ConfigValueException(
  String path,
  final String value,
  final List<String> allowedValues,
) extends ConfigException {
  this
    : super(
        path,
        'Config value at path "$path" is "$value" '
        'while one of ${allowedValues.map((v) => '"$v"').join(', ')} '
        'is expected.',
      );
}
