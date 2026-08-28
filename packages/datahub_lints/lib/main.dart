import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/assists/add_find_injection.dart';
import 'src/assists/convert_to_data_class.dart';
import 'src/assists/generate_service_instance.dart';
import 'src/fixes/add_await.dart';
import 'src/fixes/add_const_keyword.dart';
import 'src/fixes/add_enum_values.dart';
import 'src/fixes/add_super_initialize.dart';
import 'src/fixes/data_class_fixes.dart';
import 'src/fixes/use_instance_accessor.dart';
import 'src/fixes/use_instance_context.dart';
import 'src/rules/aperture/relation_requires_relation_id.dart';
import 'src/rules/config/enum_config_requires_values.dart';
import 'src/rules/data/data_class_rules.dart';
import 'src/rules/postgres/repository_requires_super_initialize.dart';
import 'src/rules/scaffold/avoid_injection_in_initializer.dart';
import 'src/rules/scaffold/avoid_zone_context_in_service.dart';
import 'src/rules/scaffold/await_lifecycle_super.dart';
import 'src/rules/scaffold/const_service_constructor.dart';
import 'src/rules/scaffold/prefer_instance_accessor.dart';

/// The entry point read by the Dart Analysis Server.
///
/// The server generates code that imports this library and references this
/// variable, so neither the path of this file nor the name of this variable
/// may change.
final plugin = DatahubLintsPlugin();

class DatahubLintsPlugin extends Plugin {
  /// Prefixes diagnostics in `// ignore: datahub_lints/<rule>` comments, so
  /// this must stay equal to the package name.
  @override
  String get name => 'datahub_lints';

  @override
  void register(PluginRegistry registry) {
    _registerScaffoldRules(registry);
    _registerConfigRules(registry);
    _registerDataRules(registry);
    _registerPostgresRules(registry);
    _registerApertureRules(registry);
    _registerAssists(registry);
  }

  void _registerScaffoldRules(PluginRegistry registry) {
    registry.registerWarningRule(PreferInstanceFindRule());
    registry.registerFixForRule(
      PreferInstanceFindRule.code,
      UseInstanceFind.new,
    );

    registry.registerWarningRule(PreferInstanceReadRule());
    registry.registerFixForRule(
      PreferInstanceReadRule.code,
      UseInstanceRead.new,
    );

    registry.registerWarningRule(AvoidZoneContextInServiceRule());
    registry.registerFixForRule(
      AvoidZoneContextInServiceRule.code,
      UseInstanceContext.new,
    );

    registry.registerWarningRule(AwaitLifecycleSuperRule());
    registry.registerFixForRule(AwaitLifecycleSuperRule.code, AddAwait.new);

    // No quick fix: moving the work into initialize() is not a mechanical
    // edit, so the correction message points there instead.
    registry.registerWarningRule(AvoidInjectionInInitializerRule());

    // A convention rather than a correctness issue, so opt-in.
    registry.registerLintRule(ConstServiceConstructorRule());
    registry.registerFixForRule(
      ConstServiceConstructorRule.code,
      AddConstKeyword.new,
    );
  }

  void _registerConfigRules(PluginRegistry registry) {
    registry.registerWarningRule(EnumConfigRequiresValuesRule());
    registry.registerFixForRule(
      EnumConfigRequiresValuesRule.code,
      AddEnumValues.new,
    );
  }

  void _registerDataRules(PluginRegistry registry) {
    registry.registerWarningRule(DataClassRequiresPartRule());
    registry.registerFixForRule(
      DataClassRequiresPartRule.code,
      AddPartDirective.new,
    );

    registry.registerWarningRule(DataClassExtendsGeneratedRule());
    registry.registerFixForRule(
      DataClassExtendsGeneratedRule.code,
      ExtendGeneratedClass.new,
    );

    registry.registerWarningRule(DataClassConstConstructorRule());
    registry.registerFixForRule(
      DataClassConstConstructorRule.code,
      AddDataClassConstructor.new,
    );
  }

  void _registerPostgresRules(PluginRegistry registry) {
    registry.registerWarningRule(RepositoryRequiresSuperInitializeRule());
    registry.registerFixForRule(
      RepositoryRequiresSuperInitializeRule.code,
      AddSuperInitialize.new,
    );
  }

  void _registerApertureRules(PluginRegistry registry) {
    // No quick fix: which field carries the id is the author's choice.
    registry.registerWarningRule(RelationRequiresRelationIdRule());
  }

  /// Boilerplate generators, offered at a syntax node rather than against a
  /// diagnostic.
  void _registerAssists(PluginRegistry registry) {
    registry.registerAssist(GenerateServiceInstance.new);
    registry.registerAssist(ConvertToDataClass.new);
    registry.registerAssist(AddFindInjection.new);
  }
}
