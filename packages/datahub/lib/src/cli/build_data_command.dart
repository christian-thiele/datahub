import 'dart:async';
import 'dart:io';

import 'package:datahub/utils.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'build_data/openapi_2_0/openapi_2_0.dart' as openApi2;

import 'cli_command.dart';
import 'cli_exception.dart';
import 'utils.dart';

class Property {
  final String type;
  final bool required;
  final String name;
  final String? jsonKey;
  final String? description;

  Property({
    required this.type,
    required this.required,
    required this.name,
    required this.jsonKey,
    required this.description,
  });
}

class BuildDataCommand extends CliCommand {
  BuildDataCommand() {
    argParser.addOption(
      'out',
      abbr: 'o',
      help: 'Data class output directory',
      defaultsTo: './data',
    );
    argParser.addOption(
      'prefix',
      abbr: 'p',
      help: 'Data class name prefix',
      defaultsTo: '',
    );
    argParser.addMultiOption(
      'name',
      abbr: 'n',
      help: 'Only build the given data class',
    );
  }

  @override
  String get description => 'Builds DataObject classes from an OpenAPI file.';

  @override
  String get name => 'build-data';

  @override
  Future<void> runCommand() async {
    final inputFileName =
        argResults!.rest.firstOrNull ??
        (throw CliException('Missing input file name.'));

    final inputFile = File(inputFileName);
    final baseDir = Directory(argResults!.option('out')!);
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    late final openApi2.SwaggerObject openApi;
    await step('Parsing OpenAPI definitions', () async {
      final yaml = normalizeJson(loadYaml(await inputFile.readAsString()));
      if (yaml['swagger'] == '2.0') {
        openApi = openApi2.$SwaggerObject.fromJson(yaml);
      } else {
        throw CliException('Unknown input file format.');
      }
    });

    final definitions = switch (argResults!.multiOption('name')) {
      List<String> names when names.isNotEmpty =>
        openApi.definitions.entries.where((e) => names.contains(e.key)),
      _ => openApi.definitions.entries,
    };

    for (final definition in definitions) {
      final schemaName = definition.key;
      final dataName = argResults!.option('prefix')! + schemaName;
      final schema = definition.value as Map<String, dynamic>;
      await step('Creating $dataName', () async {
        if (schema['type'] != 'object') {
          throw CliException('$schemaName is not an object.');
        }
        final schemaProperties = schema['properties'] as Map<String, dynamic>;
        final properties = <Property>[];
        for (final (jsonKey, schemaProperty) in schemaProperties.tuples) {
          final dartPropertyName = toNamingConvention(
            jsonKey,
            NamingConvention.lowerCamelCase,
          );
          properties.add(
            Property(
              type: jsonSchemaTypeToDartType(schemaProperty['type']),
              required:
                  (schema['required'] as List?)?.contains(jsonKey) ?? false,
              name: dartPropertyName,
              jsonKey: (dartPropertyName != jsonKey) ? jsonKey : null,
              description: schema['description'],
            ),
          );
        }

        final fileBaseName = toNamingConvention(
          dataName,
          NamingConvention.lowerSnakeCase,
        );
        final outFile = File(path.join(baseDir.path, '$fileBaseName.dart'));
        final sink = outFile.openWrite();

        sink.writeln('import \'package:datahub/datahub.dart\';');
        sink.writeln('');
        sink.writeln('part \'$fileBaseName.g.dart\';');
        sink.writeln('');
        sink.writeln('@Data()');
        sink.writeln('class $dataName extends \$$dataName {');

        for (final property in properties) {
          if (property.jsonKey case final jsonKey?) {
            sink.write('@JsonKey(\'$jsonKey\') ');
          }
          sink.writeln(
            'final ${property.type}${property.required ? '' : '?'} ${property.name};',
          );
        }

        sink.writeln('const $dataName({');
        for (final property in properties) {
          if (property.required) {
            sink.write('required ');
          }
          sink.write('this.${property.name},');
        }
        sink.writeln('});');

        sink.writeln('}');

        await sink.close();

        dart('format ${outFile.path}');
      });
    }

    await step('Running build_runner.', () async {
      await dart('run build_runner build', baseDir: baseDir, verbose: verbose);
    });
  }
}

String jsonSchemaTypeToDartType(String schemaProperty) {
  return switch (schemaProperty) {
    'string' => 'String',
    'integer' ||
    'int8' ||
    'int16' ||
    'int32' ||
    'int64' ||
    'uint8' ||
    'uint16' ||
    'uint32' => 'int',
    'number' => 'double',
    'boolean' => 'bool',
    _ => 'dynamic',
  };
}
