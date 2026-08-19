import 'dart:io';

import 'package:args/args.dart';
import 'package:datahub/telemetry.dart';

import 'configuration.dart';

/// Reading `-c key=value` and `-f file.yaml` command line options into a
/// [Configuration].
///
/// Shared by every host, so an application, a test and `datahub migrate` all
/// take their configuration from the command line the same way.
extension ConfigurationArguments on Configuration {
  /// Applies the `-c key=value` and `-f file` options in [arguments].
  ///
  /// Later options override earlier ones, so the order they appear in on the
  /// command line is the order they are applied in.
  ///
  /// With [strict] set, anything that is not one of those two options is
  /// rejected. A tool that has arguments of its own on the same command line -
  /// `migrate apply --dry-run` - passes `false` and gets the configuration
  /// options picked out of the list, leaving the rest to be handled elsewhere.
  void applyArguments(List<String> arguments, {bool strict = true}) {
    final parser = ArgParser();
    parser.addMultiOption('config', abbr: 'c');
    parser.addMultiOption('file', abbr: 'f');

    if (strict) {
      final result = parser.parse(arguments);
      if (result.rest.isNotEmpty) {
        log.warn(
          'Unrecognized command line arguments: ${result.rest.join(' ')}',
        );
      }
    }

    // ArgParser invokes option callbacks grouped by option, not in the order
    // the arguments were given, so the raw argument list is scanned instead to
    // preserve the documented left-to-right override semantics of -c and -f.
    for (final (option, value) in _optionsInOrder(parser, arguments)) {
      switch (option) {
        case 'config':
          addConfigDirective(value);
        case 'file':
          addConfigFile(File(value));
      }
    }
  }

  /// Yields the options of [parser] in the order they appear in [arguments],
  /// paired with their value.
  ///
  /// Options [parser] does not know are skipped.
  Iterable<(String, String)> _optionsInOrder(
    ArgParser parser,
    List<String> arguments,
  ) sync* {
    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      if (argument == '--') {
        return;
      }

      String? option;
      String? value;

      if (argument.startsWith('--')) {
        final name = argument.substring(2);
        final splitPoint = name.indexOf('=');
        if (splitPoint >= 0) {
          // --option=value
          option = parser
              .findByNameOrAlias(name.substring(0, splitPoint))
              ?.name;
          value = name.substring(splitPoint + 1);
        } else {
          // --option value
          option = parser.findByNameOrAlias(name)?.name;
        }
      } else if (argument.length > 1 && argument.startsWith('-')) {
        option = parser.findByAbbreviation(argument[1])?.name;
        if (option != null && argument.length > 2) {
          // -ovalue (ArgParser does not strip a leading '=' here)
          value = argument.substring(2);
        }
      }

      if (option == null) {
        continue;
      }

      // Options without an attached value consume the following argument.
      value ??= i + 1 < arguments.length ? arguments[++i] : null;
      if (value != null) {
        yield (option, value);
      }
    }
  }
}
