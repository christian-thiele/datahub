import 'dart:convert';
import 'dart:io';
import 'package:boost/boost.dart';
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
    final raw = _getFrom(path.parts, _configMap);
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

    return tryFindEnum(value, values.nonNulls.cast<Enum>()) as T;
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
      _merge(_configMap, _singleValueAsMap(path, value));
    } else {
      log.error('Invalid command line argument "$configArgument".');
    }
  }

  /// Read and add config file into the config map.
  ///
  /// Config files can be added via command line argument when using
  /// [ApplicationHost]:
  /// `dart service.dart --f path/to/file.yaml`
  ///
  /// Supported file types are yaml and json.
  void addConfigFile(File configFile) async {
    final stringContent = await configFile.readAsString();
    final ext = extension(configFile.path);
    if (ext == '.yaml' || ext == '.yml') {
      final content = loadYaml(stringContent);
      _merge(_configMap, content);
    } else if (ext == '.json') {
      final content = jsonDecode(stringContent);
      _merge(_configMap, content);
    } else {
      throw Exception(
        'Unknown config file type of file ${configFile.path}. '
        'Supported file types are yaml and json.',
      );
    }
  }

  /// Add values to the config map.
  void addConfigMap(Map<String, dynamic> map) {
    _merge(_configMap, map);
  }

  static void _merge(Map<String, dynamic> target, Map map) {
    dynamic clean(dynamic v) {
      if (v is Map) {
        // avoid unmodifiable maps
        final map = <String, dynamic>{};
        _merge(map, v);
        return map;
      } else if (v is Iterable) {
        return v.map(clean).toList();
      } else {
        return v;
      }
    }

    for (final entry in map.entries) {
      if (entry.key is! String) {
        continue;
      }

      if (target[entry.key] is Map<String, dynamic> && entry.value is Map) {
        _merge(target[entry.key], entry.value);
      } else {
        target[entry.key] = clean(entry.value);
      }
    }
  }

  Map<String, dynamic> _singleValueAsMap(ConfigPath path, dynamic value) {
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
