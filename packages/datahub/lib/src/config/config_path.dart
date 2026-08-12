import 'dart:collection';

import 'config_exception.dart';

/// Represents a config value path.
class ConfigPath {
  final List<String> parts;

  ConfigPath(String path) : this.fromParts(path.split('.'));

  ConfigPath.fromParts(List<String> parts)
    : parts = UnmodifiableListView(parts) {
    for (final part in parts) {
      if (!_isValidPart(part)) {
        throw InvalidConfigPathException(parts.join('.'), part);
      }
    }
  }

  ConfigPath.root() : this.fromParts(const []);

  /// Checks if the path points to the config root.
  bool get isRoot => parts.isEmpty;

  /// Creates a [ConfigPath] selecting [path] in [this] path.
  ConfigPath join(ConfigPath path) =>
      ConfigPath.fromParts([...parts, ...path.parts]);

  dynamic getFrom(dynamic values) => _getFrom(parts, values);

  /// Creates a [ConfigPath] selecting [value] in [this] path.
  ConfigPath operator [](String value) =>
      ConfigPath.fromParts([...parts, ...value.split('.')]);

  @override
  bool operator ==(Object other) =>
      other is ConfigPath && toString() == other.toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => parts.join('.');

  /// A segment may hold any key a config source can provide, as long as the
  /// path stays unambiguous: it must be non-empty and must not contain the
  /// "." separator.
  static bool _isValidPart(String part) =>
      part.isNotEmpty && !part.contains('.');

  static dynamic _getFrom(Iterable<String> path, dynamic values) {
    if (path.isEmpty) {
      return values;
    }

    if (values is! Map<String, dynamic> || !values.containsKey(path.first)) {
      return null;
    }

    final next = values[path.first];
    return _getFrom(path.skip(1), next);
  }
}
