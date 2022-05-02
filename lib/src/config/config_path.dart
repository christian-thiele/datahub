import 'dart:collection';

/// Represents a config value path.
class ConfigPath {
  static final _regex = RegExp(r'^\w+$', multiLine: false);

  final List<String> parts;

  ConfigPath(List<String> parts)
      : parts = UnmodifiableListView(parts),
        assert(parts.every(_isValidPart));

  ConfigPath.parse(String path) : this(path.split('.'));

  /// Creates a [ConfigPath] selecting [path] in [this] path.
  ConfigPath join(ConfigPath path) => ConfigPath([...parts, ...path.parts]);

  /// Creates a [ConfigPath] selecting [value] in [this] path.
  ConfigPath operator [](String value) => ConfigPath([...parts, value]);

  @override
  bool operator ==(Object other) =>
      other is ConfigPath && toString() == other.toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => parts.join('.');

  static bool _isValidPart(String part) => _regex.hasMatch(part);
}
