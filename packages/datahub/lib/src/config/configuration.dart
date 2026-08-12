import 'dart:convert';
import 'dart:io';
import 'package:datahub/datahub.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class Configuration {
  static const _codec = JsonDataCodec();

  final _configMap = <String, dynamic>{};

  /// Paths that were already checked for a possible misspelling, so that a
  /// config value read on every request is only reported once.
  final _diagnosedPaths = <String>{};

  Environment? _environment;

  /// The environment this application runs in.
  ///
  /// Resolved once and cached, since it is read for every [Context] that is
  /// created. The cache is invalidated whenever the configuration changes.
  Environment get environment => _environment ??=
      readEnum<Environment?>(ConfigPath('environment'), Environment.values) ??
      Environment.dev;

  T read<T>(ConfigPath path) {
    final raw = _resolve(path.getFrom(_configMap), {path.toString()});
    if (raw == null) {
      if (null is T) {
        if (_diagnosedPaths.add(path.toString())) {
          if (_findSimilarPath(path) case final suggestion?) {
            log.warn(
              'Configuration does not provide a value for "$path", '
              'but does provide "$suggestion". Possible typo?',
            );
          }
        }
        return null as T;
      } else {
        throw ConfigPathException(
          path.toString(),
          suggestion: _findSimilarPath(path),
        );
      }
    }

    try {
      return _codec.decodeTyped<T>(raw);
    } on CodecException catch (_) {
      throw ConfigTypeException(path.toString(), T, raw.runtimeType);
    } on FormatException catch (_) {
      throw ConfigTypeException(path.toString(), T, raw.runtimeType);
    }
  }

  T readEnum<T>(ConfigPath path, List<T> values) {
    final String value;
    if (null is T) {
      final nullableValue = read<String?>(path);
      if (nullableValue == null) {
        return null as T;
      } else {
        value = nullableValue;
      }
    } else {
      value = read<String>(path);
    }

    final enumValues = values.whereType<Enum>().toList();

    try {
      return _codec.decodeEnum<Enum>(value, enumValues) as T;
    } on CodecException catch (_) {
      throw ConfigValueException(
        path.toString(),
        value,
        enumValues.map(_codec.encodeEnum).toList(),
      );
    }
  }

  /// Searches the configuration for a path that closely resembles [path].
  ///
  /// Walks [path] as far as the configuration actually goes and compares the
  /// first segment that is missing against the keys available at that point.
  /// Returns the full path of the best candidate, or null when nothing
  /// resembles the missing segment closely enough.
  String? _findSimilarPath(ConfigPath path) {
    final prefix = <String>[];
    dynamic current = _configMap;

    for (final segment in path.parts) {
      if (current is! Map<String, dynamic>) {
        // The path descends into a value, so there are no keys to compare.
        return null;
      }

      if (current.containsKey(segment)) {
        prefix.add(segment);
        current = current[segment];
        continue;
      }

      if (_closestKey(segment, current.keys) case final candidate?) {
        // Joined by hand: a config key is not necessarily a valid ConfigPath
        // segment, and a diagnostic must never throw.
        return [...prefix, candidate].join('.');
      }

      return null;
    }

    // Every segment exists, so the value itself is null. Not a typo.
    return null;
  }

  /// Returns the key out of [keys] that [segment] was most likely meant to be.
  static String? _closestKey(String segment, Iterable<String> keys) {
    final normalized = _normalizeKey(segment);

    // A key differing only in case or in "-" / "_" separators is a far more
    // common mistake than a misspelling, and is reported without a distance
    // budget.
    for (final key in keys) {
      if (_normalizeKey(key) == normalized) {
        return key;
      }
    }

    // Very short keys are close to everything, so guessing at them produces
    // more noise than signal.
    if (normalized.length < 3) {
      return null;
    }

    final maxDistance = normalized.length < 5 ? 1 : 2;

    String? best;
    var bestDistance = maxDistance + 1;
    for (final key in keys) {
      final distance = normalized.damerauLevenshteinDistance(
        _normalizeKey(key),
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        best = key;
      }
    }

    return best;
  }

  static final _separators = RegExp(r'[-_]');

  static String _normalizeKey(String key) =>
      key.toLowerCase().replaceAll(_separators, '');

  /// Adds a single value value to the configuration map.
  ///
  /// The value can be a primitive, [Map] or [List].
  /// Maps will be merged while Lists and primitives will be replaced.
  void addValue(ConfigPath path, dynamic value) {
    addConfigMap(createSubtree(path, value));
  }

  /// Add a single config value by using the command line syntax.
  /// This is usually used for command line argument parsing.
  ///
  /// Syntax:
  /// `path.to.value=value`
  ///
  /// Config values can be added via command line argument when using
  /// [ApplicationHost]:
  /// `dart service.dart --c path.to.value=value`
  ///
  /// Config values and files override each other in the order they are provided
  /// as arguments.
  ///
  /// The value is always taken literally. Unlike values coming from a config
  /// file it is not interpreted as a configuration reference ($-syntax), so a
  /// value such as `$ecret` is stored as it is instead of being substituted
  /// with the value at config path `ecret`.
  ///
  void addConfigDirective(String configArgument) {
    final splitPoint = configArgument.indexOf('=');
    if (splitPoint > 0) {
      final path = ConfigPath(configArgument.substring(0, splitPoint));
      final value = configArgument.substring(splitPoint + 1);
      addValue(path, _escapeReference(value));
    } else {
      log.error('Invalid config directive "$configArgument".');
    }
  }

  /// Escapes a leading `$` so that [value] survives reference resolution
  /// unchanged.
  static String _escapeReference(String value) =>
      value.startsWith(r'$') ? '\\$value' : value;

  /// Read and add config file into the config map.
  ///
  /// Config files can be added via command line argument when using
  /// [ApplicationHost]:
  /// `dart service.dart --f path/to/file.yaml`
  ///
  /// Supported file types are yaml and json.
  void addConfigFile(File configFile) {
    if (!configFile.existsSync()) {
      throw ConfigFileException(configFile.path, 'does not exist.');
    }

    final ext = p.extension(configFile.path).toLowerCase();
    if (ext != '.yaml' && ext != '.yml' && ext != '.json') {
      throw ConfigFileException(
        configFile.path,
        'is of an unknown file type. Supported file types are yaml and json.',
      );
    }

    final dynamic content;
    try {
      final stringContent = configFile.readAsStringSync();
      content = ext == '.json'
          ? jsonDecode(stringContent)
          : loadYaml(stringContent);
    } on FormatException catch (e) {
      throw ConfigFileException(configFile.path, 'could not be parsed: $e');
    } on FileSystemException catch (e) {
      throw ConfigFileException(configFile.path, 'could not be read: $e');
    }

    if (content == null) {
      // An empty (or comment only) file simply contributes nothing.
      return;
    }

    if (content is! Map) {
      throw ConfigFileException(
        configFile.path,
        'must hold a map at its root but holds a value of type '
        '"${content.runtimeType}".',
      );
    }

    addConfigMap(content);
  }

  /// Merges [map] into this configuration.
  void addConfigMap(Map map) {
    merge(_configMap, map);
    _environment = null;
    _diagnosedPaths.clear();
  }

  /// Merges values from [configuration] into this configuration.
  void addConfiguration(Configuration configuration) {
    addConfigMap(configuration._configMap);
  }

  /// Merges [source] into [target].
  ///
  /// Maps that already exist in [target] will be merged while lists and
  /// primitives will replace existing values.
  ///
  /// Keys in [source] that are not of type [String] will be ignored.
  ///
  /// Values are stored verbatim. Configuration references ($-syntax) are
  /// resolved when the value is read, not when it is merged.
  static void merge(Map<String, dynamic> target, Map source) {
    for (final entry in source.entries) {
      if (entry.key is! String) {
        log.warn(
          'Ignoring config key "${entry.key}" of type '
          '"${entry.key.runtimeType}". Config keys must be strings.',
        );
        continue;
      }

      if (target[entry.key] is Map<String, dynamic> && entry.value is Map) {
        merge(target[entry.key], entry.value);
      } else {
        target[entry.key] = _normalize(entry.value);
      }
    }
  }

  /// Converts [value] into modifiable, [String] keyed collections.
  ///
  /// Config sources such as yaml provide unmodifiable maps and lists with
  /// non-[String] key types, which cannot be merged into.
  static dynamic _normalize(dynamic value) {
    if (value is Map) {
      final map = <String, dynamic>{};
      merge(map, value);
      return map;
    } else if (value is Iterable) {
      return value.map(_normalize).toList();
    } else {
      return value;
    }
  }

  /// Resolves configuration references ($-syntax) inside [value].
  ///
  /// Maps and lists are resolved element-wise and are always rebuilt, so that
  /// readers never receive a reference to the internal config map.
  ///
  /// [visited] holds the reference paths that were followed to arrive at
  /// [value] and is used to detect circular references. Every reference that
  /// is followed descends with its own copy of the set, so that two references
  /// to the same path in sibling values are not mistaken for a cycle.
  dynamic _resolve(dynamic value, Set<String> visited) {
    switch (value) {
      case final Map<String, dynamic> map:
        return map.map((key, v) => MapEntry(key, _resolve(v, visited)));

      case final List<dynamic> list:
        return list.map((v) => _resolve(v, visited)).toList();

      case final String str when str.startsWith(r'\$'):
        // escaping leading $ (reference syntax) with \$
        return str.substring(1);

      case final String str when str.startsWith(r'$'):
        final reference = ConfigPath(str.substring(1));
        final referencePath = reference.toString();

        if (visited.contains(referencePath)) {
          throw ConfigReferenceException(referencePath, [
            ...visited,
            referencePath,
          ]);
        }

        return _resolve(reference.getFrom(_configMap), {
          ...visited,
          referencePath,
        });

      default:
        return value;
    }
  }

  static Map<String, dynamic> createSubtree(ConfigPath path, dynamic value) {
    if (path.isRoot) {
      if (value is Map<String, dynamic>) {
        return value;
      } else {
        throw ConfigException(
          path.toString(),
          'Cannot set single value as config root.',
        );
      }
    }

    return path.parts.reversed.fold<dynamic>(
      value,
      (v, k) => <String, dynamic>{k: v},
    );
  }
}
