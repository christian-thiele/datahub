import 'dart:collection';

import 'config_exception.dart';

/// Represents a config value path.
class ConfigPath {
  static final _regex = RegExp(r'^\w+$', multiLine: false);

  final List<String> parts;

  ConfigPath(String path) : this.fromParts(path.split('.'));

  ConfigPath.fromParts(List<String> parts)
      : parts = UnmodifiableListView(parts),
        assert(parts.every(_isValidPart));

  /// Checks if the path points to the config root.
  bool get isRoot => parts.isEmpty;

  /// Creates a [ConfigPath] selecting [path] in [this] path.
  ConfigPath join(ConfigPath path) =>
      ConfigPath.fromParts([...parts, ...path.parts]);

  /// Looks up the selected path in [values].
  ///
  /// The path can resolve to any config value, including null.
  ///
  /// If the target element cannot be resolved, a [ConfigException] is thrown.
  dynamic getFrom(Map<String, dynamic> values) => _getFrom(parts, values);

  static dynamic _getFrom(List<String> path, dynamic values) {
    if (path.isEmpty) {
      return values;
    }

    if (values is! Map<String, dynamic>) {
      throw ConfigPathException(path.join('.'), path.first);
    }

    final next = values[path.first];
    try {
      return _getFrom(path.skip(1).toList(), next);
    } on ConfigPathException catch (e) {
      throw ConfigPathException(path.join('.'), e.element);
    }
  }

  /// Creates a [ConfigPath] selecting [value] in [this] path.
  ConfigPath operator [](String value) =>
      ConfigPath.fromParts([...parts, value]);

  @override
  bool operator ==(Object other) =>
      other is ConfigPath && toString() == other.toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => parts.join('.');

  static bool _isValidPart(String part) => _regex.hasMatch(part);
}
