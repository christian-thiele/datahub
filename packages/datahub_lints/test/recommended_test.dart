import 'dart:io';

import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:datahub_lints/main.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final recommended =
      loadYaml(File('../datahub/lib/recommended.yaml').readAsStringSync())
          as YamlMap;
  final plugin = recommended['plugins']['datahub_lints'] as YamlMap;

  test('enables every opt-in lint', () {
    final registry = _RecordingRegistry();
    DatahubLintsPlugin().register(registry);

    final diagnostics = plugin['diagnostics'] as YamlMap;
    expect(
      diagnostics.keys.toSet(),
      registry.lintRules,
      reason:
          'datahub/lib/recommended.yaml should switch on exactly the rules '
          'registered with registerLintRule.',
    );
    expect(diagnostics.values, everyElement(isTrue));
  });

  test('requests a plugin version that includes this one', () {
    final pubspec =
        loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final version = Version.parse(pubspec['version'] as String);
    final constraint = VersionConstraint.parse(plugin['version'] as String);

    expect(
      constraint.allows(version),
      isTrue,
      reason:
          "Bump the plugin version in datahub/lib/recommended.yaml to match "
          "pubspec.yaml's $version.",
    );
  });
}

/// Records the names of the rules the plugin registers as opt-in lints.
class _RecordingRegistry implements PluginRegistry {
  final lintRules = <String>{};

  @override
  void registerLintRule(AbstractAnalysisRule rule) => lintRules.add(rule.name);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
