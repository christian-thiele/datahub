import 'package:datahub/utils.dart';

/// Annotation for data classes.
///
/// Data class declarations must be prefixed with "$".
///
/// Example:
/// ```dart
/// @Data()
/// class $Car {
///   ...
/// }
/// ```
final class Data {
  final NamingConvention defaultNamingConvention;

  const Data({this.defaultNamingConvention = NamingConvention.lowerCamelCase});
}

final class JsonKey {
  final String key;

  const JsonKey(this.key);
}
