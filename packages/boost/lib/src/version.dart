import 'dart:math';

/// Represents a Version consisting of numeric parts, starting
/// with the most significant part.
///
/// Versions with different lengths can be compared, because
/// "missing" less significant parts are considered 0.
///
/// This statement is true:
/// ``Version('1.2') == Version('1.2.0.0')`
///
/// Version implements [Comparable] but compare operators
/// like ==, <, >, <= and >= can also be used.
class Version implements Comparable<Version> {
  final List<int> _parts;

  Version.fromParts(this._parts);

  Version(String versionString)
      : this.fromParts(_parseVersionString(versionString));

  int getPart(int index) => (_parts.length > index) ? _parts[index] : 0;

  int operator [](int index) => getPart(index);

  @override
  int compareTo(Version other) {
    final maxLength = max(_parts.length, other._parts.length);
    for (var i = 0; i < maxLength; i++) {
      final result = getPart(i).compareTo(other.getPart(i));
      if (result != 0) {
        return result;
      }
    }

    return 0;
  }

  @override
  String toString() {
    if (_parts.isNotEmpty) {
      return _parts.join('.');
    }

    return '0';
  }

  @override
  bool operator ==(Object other) => other is Version && compareTo(other) == 0;

  bool operator >(Version other) => compareTo(other) == 1;
  bool operator >=(Version other) => compareTo(other) > -1;

  bool operator <(Version other) => compareTo(other) == -1;
  bool operator <=(Version other) => compareTo(other) < 1;

  @override
  int get hashCode => _parts.fold(1, (c, e) => 31 * c + e.hashCode);

  static List<int> _parseVersionString(String versionString) {
    final stringParts = versionString.split('.');
    return stringParts.map((e) {
      return int.tryParse(e) ??
          (throw Exception(
              'Invalid version part: "$e" in version string: "$versionString".'));
    }).toList();
  }
}
