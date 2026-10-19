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
final class const Data({
  final NamingConvention defaultNamingConvention =
      NamingConvention.lowerCamelCase,
});

final class const JsonKey(final String key);
