import 'dart:io';

import 'package:boost/boost.dart';

/// App configuration parsed from environment variables and
/// command line arguments.
///
/// Define configuration parameters first by instantiating [ConfigParser] and
/// calling [setOption] then call [parse] to receive the
/// detected values.
///
/// Values are detected in the following order with each step overriding
/// values set by a previous step:
///
/// 1. default values
/// 2. environment values
/// 3. command line arguments
class ConfigParser {
  static const allowedTypes = [String, int, double, bool];

  final _params = <_ConfigParam>[];

  ConfigParser();

  void addOption(String name,
      {String? abbr,
      String? description,
      String? environment,
      Type type = String,
      bool required = false,
      dynamic defaultValue}) {
    if (_params.any((element) => element.name == name)) {
      throw BoostException('Option name already in use: --"$name"');
    }

    if (abbr != null && _params.any((element) => element.abbr == abbr)) {
      throw BoostException('Option abbreviation already in use: -"$abbr"');
    }

    if (environment != null &&
        _params.any((element) => element.environment == environment)) {
      throw BoostException(
          'Option environment variable already in use: "$environment"');
    }

    if (!allowedTypes.contains(type)) {
      throw BoostException('Type "$type" not supported by ConfigParser.');
    }

    _params.add(_ConfigParam(
        name, abbr, environment, description, type, defaultValue, required));
  }

  /// Parse configuration from environment and (optional) cli arguments.
  Map<String, dynamic> parse([List<String>? args]) {
    final cliValues = _parseCli(args);
    final values = <String, dynamic>{};
    for (final param in _params) {
      dynamic raw = param.defaultValue;
      if (!nullOrWhitespace(param.environment) &&
          Platform.environment.containsKey(param.environment)) {
        raw = Platform.environment[param.environment];
      }
      if (cliValues.containsKey(param)) {
        raw = cliValues[param];
      }

      if (param.required && raw == null) {
        throw BoostException('Missing value for config param "${param.name}".');
      }

      if (param.type == String) {
        values[param.name] = raw?.toString();
      } else if (param.type == int) {
        if (raw is int) {
          values[param.name] = raw;
        } else if (raw == null) {
          values[param.name] = null;
        } else {
          try {
            values[param.name] = int.parse(raw.toString());
          } catch (_) {
            throw BoostException(
                'Expected type int for param ${param.name}, instead got "$raw".');
          }
        }
      } else if (param.type == double) {
        if (raw is double) {
          values[param.name] = raw;
        } else if (raw == null) {
          values[param.name] = null;
        } else {
          try {
            values[param.name] = double.parse(raw.toString());
          } catch (_) {
            throw BoostException(
                'Expected type double for param ${param.name}, instead got "$raw".');
          }
        }
      } else if (param.type == bool) {
        if (raw is bool) {
          values[param.name] = raw;
        } else if (raw is num) {
          values[param.name] = raw > 0;
        } else if (raw == null) {
          values[param.name] = null;
        } else {
          values[param.name] = raw.toString().toLowerCase() == 'true';
        }
      } else {
        throw BoostException(
            'Type "${param.type}" not supported by ConfigParser.');
      }
    }

    return values;
  }

  Map<_ConfigParam, dynamic> _parseCli(List<String>? args) {
    if (args == null) {
      return {};
    }

    final values = <_ConfigParam, dynamic>{};

    _ConfigParam? param;
    StringBuffer? _argBuffer;
    for (final current in args) {
      if (param != null) {
        if (_argBuffer != null) {
          _argBuffer.write(' ');
          if (current.endsWith('"')) {
            _argBuffer.write(current.substring(0, current.length - 1));
            values[param] = _argBuffer.toString();
            param = null;
            _argBuffer = null;
          } else {
            _argBuffer.write(current);
          }
        } else {
          if (current.startsWith('"')) {
            if (current.endsWith('"')) {
              values[param] = current.substring(1, current.length - 1);
              param = null;
            } else {
              _argBuffer = StringBuffer(current.substring(1));
            }
          } else {
            values[param] = current;
            param = null;
          }
        }
      } else {
        if (current.startsWith('--')) {
          final name = current.substring(2);
          param = _params.where((p0) => p0.name == name).firstOrNull ??
              (throw BoostException('Invalid command line argument: $current'));
        } else if (current.startsWith('-')) {
          final abbr = current.substring(1);
          param = _params.where((p0) => p0.abbr == abbr).firstOrNull ??
              (throw BoostException('Invalid command line argument: $current'));
        } else {
          throw BoostException('Invalid command line argument: $current');
        }
      }
    }

    if (_argBuffer != null) {
      throw BoostException('Invalid command line syntax: "${args.join(' ')}"');
    }

    return values;
  }
}

class _ConfigParam {
  final String name;
  final String? abbr;
  final String? environment;
  final String? description;
  final dynamic defaultValue;
  final Type type;
  final bool required;

  _ConfigParam(
    this.name,
    this.abbr,
    this.environment,
    this.description,
    this.type,
    this.defaultValue,
    this.required,
  );
}
