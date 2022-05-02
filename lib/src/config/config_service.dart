import 'dart:convert';
import 'dart:io';

import 'package:cl_datahub/ioc.dart';
import 'package:cl_datahub/services.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import 'config_exception.dart';
import 'config_path.dart';

/// Internal service parsing configuration files, command line arguments
/// and environment variables.
///
/// TODO docs
class ConfigService extends BaseService {
  final _log = resolve<LogService>();
  final _configMap = <String, dynamic>{};
  final List<File> _configFiles;

  ConfigService(this._configFiles);

  @override
  Future<void> initialize() async {
    for (final file in _configFiles) {
      if (!await file.exists()) {
        throw Exception('Config file "${file.path}" not found.');
      }

      try {
        final stringContents = await file.readAsString();
        final mapContents = (extension(file.path).toLowerCase() == '.json')
            ? jsonDecode(stringContents)
            : loadYaml(stringContents);

        _merge(_configMap, mapContents);
        _log.verbose('Loaded configuration file: ${file.path}');
      } catch (e, stack) {
        _log.critical(
          'Could not load config file "${file.path}".',
          error: e,
          trace: stack,
          sender: 'DataHub',
        );
      }
    }
  }

  T fetchConfig<T>(ConfigPath path, T? defaultValue) {
    final value = path.getFrom(_configMap);
    if (value is T) {
      return value;
    }

    if (value == null) {
      return defaultValue ??
          (throw ConfigPathException(path.toString(), path.parts.last));
    }

    if (T == num || T == double) {
      return (double.tryParse(value.toString()) ??
          (throw ConfigTypeException(
              configPath.toString(), T, value.runtimeType))) as T;
    }

    if (T == int) {
      return (int.tryParse(value.toString()) ??
          (throw ConfigTypeException(
              configPath.toString(), T, value.runtimeType))) as T;
    }

    if (T == bool) {
      final str = value.toString().toLowerCase();
      return (str == '1' || str == 'true' || str == 'yes') as T;
    }

    if (T == String) {
      return value.toString() as T;
    }

    throw ConfigTypeException(configPath.toString(), T, value.runtimeType);
  }

  static void _merge(Map target, Map map) {
    for (final entry in map.entries) {
      if (target[entry.key] is Map && entry.value is Map) {
        _merge(target[entry.key], entry.value);
      } else if (entry.value is Map) {
        // avoid unmodifiable maps
        target[entry.key] = {};
        _merge(target[entry.key], entry.value);
      } else {
        target[entry.key] = entry.value;
      }
    }
  }

  @override
  Future<void> shutdown() async {}
}
