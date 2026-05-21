import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:datahub/data.dart';
import 'package:datahub/telemetry.dart';

import 'config_path.dart';
import 'config_exception.dart';

import 'environment.dart';

class Configuration {
  final _configMap = <String, dynamic>{};

  Environment get environment =>
      readEnum<Environment?>(ConfigPath('environment'), Environment.values) ??
          Environment.dev;

  T read<T>(ConfigPath path) {
    final raw = path.getFrom(_configMap);
    if (raw == null) {
      if (null is T) {
        return null as T;
      } else {
        throw ConfigPathException(path.toString());
      }
    }

    try {
      final codec = const JsonDataCodec();
      return codec.decodeTyped<T>(raw);
    } on CodecException catch (_) {
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

    return JsonDataCodec().decodeEnum<Enum>(
      value,
      values.whereType<Enum>().toList(),
    )
    as T;
  }

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
  /// TODO escape sequences
  void addConfigDirective(String configArgument) {
    final splitPoint = configArgument.indexOf('=');
    if (splitPoint > 0) {
      final path = ConfigPath(configArgument.substring(0, splitPoint));
      final value = configArgument.substring(splitPoint + 1);
      addValue(path, value);
    } else {
      log.error('Invalid config directive "$configArgument".');
    }
  }

  /// Read and add config file into the config map.
  ///
  /// Config files can be added via command line argument when using
  /// [ApplicationHost]:
  /// `dart service.dart --f path/to/file.yaml`
  ///
  /// Supported file types are yaml and json.
  void addConfigFile(File configFile) {
    final stringContent = configFile.readAsStringSync();
    final ext = extension(configFile.path);
    if (ext == '.yaml' || ext == '.yml') {
      addConfigMap(loadYaml(stringContent));
    } else if (ext == '.json') {
      addConfigMap(jsonDecode(stringContent));
    } else {
      throw Exception(
        'Unknown config file type of file ${configFile.path}. '
            'Supported file types are yaml and json.',
      );
    }
  }

  /// Merges [map] into this configuration.
  void addConfigMap(Map map) {
    merge(_configMap, map);
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
  /// [referenceRoot] is used to resolve configuration references ($-syntax).
  /// If null, [target] will be used as reference root.
  static void merge(
      Map<String, dynamic> target,
      Map source, {
        Map<String, dynamic>? referenceRoot,
      }) {
    dynamic clean(dynamic v) {
      if (v is Map) {
        // avoid unmodifiable maps
        final map = <String, dynamic>{};
        merge(map, v, referenceRoot: referenceRoot ?? target);
        return map;
      } else if (v is Iterable) {
        return v.map(clean).toList();
      } else if (v case final String str when str.startsWith('\\\$')) {
        // escaping leading $ (reference syntax) with \$
        return str.substring(1);
      } else if (v case final String str when str.startsWith('\$')) {
        return ConfigPath(str.substring(1)).getFrom(referenceRoot ?? target);
      } else {
        return v;
      }
    }

    for (final entry in source.entries) {
      if (entry.key is! String) {
        continue;
      }

      if (target[entry.key] is Map<String, dynamic> && entry.value is Map) {
        merge(
          target[entry.key],
          entry.value,
          referenceRoot: referenceRoot ?? target,
        );
      } else {
        target[entry.key] = clean(entry.value);
      }
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
