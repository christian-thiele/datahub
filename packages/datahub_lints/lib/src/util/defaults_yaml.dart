import 'package:analyzer/file_system/file_system.dart';
import 'package:yaml/yaml.dart';

/// The per-package file declaring default values for configuration paths.
const defaultsFilePath = ['resources', 'defaults.yaml'];

/// The parsed `resources/defaults.yaml` of one package.
class DefaultsFile {
  /// The decoded top level mapping, or `null` when the file is empty or holds
  /// something other than a mapping, in which case it declares nothing.
  final Map<Object?, Object?>? _values;

  /// The modification stamp the parse was made from, used to notice edits.
  final int modificationStamp;

  DefaultsFile._(this._values, this.modificationStamp);

  /// Whether [path] resolves to an entry, with `.` separating segments.
  ///
  /// A segment resolves against a nested mapping, so `aperture.title` needs
  /// `aperture:` to hold a mapping with a `title:` key.
  bool declares(String path) {
    Object? current = _values;

    for (final segment in path.split('.')) {
      if (current is! Map) {
        return false;
      }

      if (!current.containsKey(segment)) {
        return false;
      }

      current = current[segment];
    }

    return true;
  }
}

/// Caches parsed defaults files, keyed by their path.
///
/// A rule runs for every library on every edit, so the file is parsed once and
/// then only re-read when its modification stamp moves.
final _cache = <String, DefaultsFile>{};

/// The package root containing [file], identified by its `pubspec.yaml`.
Folder? packageRootOf(File file) {
  var folder = file.parent;

  while (true) {
    if (folder.getFile('pubspec.yaml').exists) {
      return folder;
    }

    final parent = folder.parent;
    if (parent.path == folder.path) {
      return null;
    }

    folder = parent;
  }
}

/// Loads the defaults file governing [dartFile], or `null` when the package
/// has none.
///
/// A package without the file opts out entirely: the rule has nothing to check
/// against and stays silent rather than flagging every declaration.
DefaultsFile? defaultsFileFor(File dartFile) {
  final root = packageRootOf(dartFile);
  if (root == null) {
    return null;
  }

  final file = root.provider.getFile(
    root.provider.pathContext.joinAll([root.path, ...defaultsFilePath]),
  );

  if (!file.exists) {
    _cache.remove(file.path);
    return null;
  }

  final stamp = file.modificationStamp;
  if (_cache[file.path] case final cached?
      when cached.modificationStamp == stamp) {
    return cached;
  }

  final parsed = _parse(file, stamp);
  if (parsed == null) {
    _cache.remove(file.path);
    return null;
  }

  return _cache[file.path] = parsed;
}

/// Parses [file], or returns `null` when it cannot be read as YAML.
///
/// A malformed or unreadable file is the YAML tooling's problem to report.
/// Treating it as empty here would flag every declaration in the package on
/// the strength of a typo somewhere in the file, so the rule stays silent
/// instead.
DefaultsFile? _parse(File file, int stamp) {
  try {
    final content = loadYaml(file.readAsStringSync());
    return DefaultsFile._(content is Map ? content : null, stamp);
  } on YamlException {
    return null;
  } on FileSystemException {
    return null;
  }
}
