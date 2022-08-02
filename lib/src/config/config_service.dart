import 'dart:convert';
import 'dart:io';

import 'package:datahub/utils.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:boost/boost.dart';

import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/transfer_object.dart';

import 'config_exception.dart';
import 'config_path.dart';
import 'environment.dart';
import 'log_level.dart';

/// Internal service parsing configuration files, command line arguments
/// and environment variables.
///
/// The config path "datahub" is reserved for internal values:
///
/// `datahub.log` defines the log level [LogService]. See enum values in [LogLevel].
/// `datahub.environment` defines the service environment. See enum values in [Environment].
///
/// TODO more docs
class ConfigService extends BaseService {
  final _log = resolve<LogService>();
  final _configMap = <String, dynamic>{};
  final List<String> arguments;

  /// The services environment.
  ///
  /// The value of this is determined by the config value "datahub.environment".
  /// The default value is [Environment.dev].
  @override
  late final Environment environment;

  ConfigService(Map<String, dynamic> defaultConfig, this.arguments) {
    _merge(_configMap, defaultConfig);
  }

  @override
  Future<void> initialize() async {
    for (final arg in arguments) {
      if (arg.startsWith('--')) {
        addConfigArgument(arg.substring(2));
      } else {
        addConfigFile(File(arg));
      }

      final file = File(arg);

      if (!await file.exists()) {
        throw Exception('Config file "${file.path}" not found.');
      }

      try {
        final stringContents = await file.readAsString();
        final mapContents = (extension(file.path).toLowerCase() == '.json')
            ? jsonDecode(stringContents)
            : loadYaml(stringContents);

        _merge(_configMap, mapContents);
      } catch (e, stack) {
        _log.critical(
          'Could not load config file "${file.path}".',
          error: e,
          trace: stack,
          sender: 'DataHub',
        );
      }
    }

    _readDatahubConfig();
  }

  /// Get a config value under the given [path].
  ///
  /// Throws [ConfigPathException] if value does not exist.
  /// If a null return value is preferred instead, simply set a nullable
  /// type for [T] and no exception will be thrown.
  ///
  /// Valid types for [T] (nullable, as well as non-nullable)
  /// are [String], [int], [double], [bool], [DateTime], [Uint8List],
  /// [List]<[int]> or [List]<[String]> or [Map]<[String], dynamic>.
  ///
  /// If the value does not match the requested type or cannot be parsed
  /// into the given type, a [ConfigTypeException] is thrown.
  T fetch<T>(ConfigPath path) {
    try {
      final raw = path.getFrom(_configMap);
      final decoded = decodeTypedNullable<T>(raw);
      if (decoded is T) {
        return decoded;
      }

      throw ConfigTypeException(path.toString(), T, raw.runtimeType);
    } on ConfigPathException catch (_) {
      if (null is T) {
        return null as T;
      } else {
        rethrow;
      }
    }
  }

  /// Get a config value as map and parse it into the given TransferObject.
  ///
  /// If the value does not exist, a [ConfigPathException] is thrown.
  ///
  /// If the value does not match the requested type or cannot be parsed
  /// into the given type, a [ConfigTypeException] is thrown.
  T fetchObject<T extends TransferObjectBase>(
      ConfigPath path, TransferBean<T> bean) {
    final map = fetch<Map<String, dynamic>>(path);
    return bean.toObject(map);
  }

  /// Add a single config value by using the command line syntax.
  /// This is usually used for command line argument parsing.
  ///
  /// Syntax:
  /// `path.to.value=value`
  ///
  /// You can modify config values by adding an argument to the run command
  /// like this:
  /// `dart service.dart --path.to.value=value`
  ///
  /// Config values and files override each other in the order they are provided
  /// as arguments.
  ///
  /// TODO escape sequences
  void addConfigArgument(String configArgument) {
    final splitPoint = configArgument.indexOf('=');
    if (splitPoint > 0) {
      final path = ConfigPath(configArgument.substring(0, splitPoint));
      final value = configArgument.substring(splitPoint + 1);
      _merge(_configMap, _singleValueAsMap(path, value));
    } else {
      _log.error('Invalid command line argument "$configArgument".');
    }
  }

  /// Read and add config file into the config map.
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
      throw Exception('Unknown config file type of file ${configFile.path}. '
          'Supported file types are yaml and json.');
    }
  }

  @override
  Future<void> shutdown() async {}

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

    return path.parts.reversed.fold(value, (v, k) => <String, dynamic>{k: v});
  }

  void _readDatahubConfig() {
    try {
      final datahubConfig =
          fetch<Map<String, dynamic>?>(ConfigPath('datahub')) ?? {};
      if (datahubConfig['log'] != null) {
        _log.setLogLevel(findEnum(
            datahubConfig['log'].toString().toLowerCase(), LogLevel.values));
      }

      if (datahubConfig['environment'] != null) {
        environment = findEnum(
          datahubConfig['environment'].toString().toLowerCase(),
          Environment.values,
        );
      } else {
        environment = Environment.dev;
      }
    } on ConfigPathException catch (_) {
      _log.warn(
        'No datahub config found, using default values.',
        sender: 'DataHub',
      );
      environment = Environment.dev;
    }
  }
}
