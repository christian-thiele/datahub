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
  const Data();
}

/// Annotation for default values of optional parameters.
final class Default {
  final dynamic value;

  const Default(this.value);
}
