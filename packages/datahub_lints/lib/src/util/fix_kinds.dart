import 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Fix kinds for the DataHub analysis rules.
abstract final class DatahubFixKind {
  static const useInstanceFind = FixKind(
    'datahub.fix.useInstanceFind',
    DartFixKindPriority.standard,
    'Use the ServiceInstance find method',
  );

  static const useInstanceRead = FixKind(
    'datahub.fix.useInstanceRead',
    DartFixKindPriority.standard,
    'Use the ServiceInstance read method',
  );

  static const addAwait = FixKind(
    'datahub.fix.addAwait',
    DartFixKindPriority.standard,
    "Add the 'await' keyword",
  );

  static const makeFieldLate = FixKind(
    'datahub.fix.makeFieldLate',
    DartFixKindPriority.standard,
    "Make the field 'late final'",
  );

  static const addConstKeyword = FixKind(
    'datahub.fix.addConstKeyword',
    DartFixKindPriority.standard,
    "Add the 'const' keyword",
  );

  static const addEnumValues = FixKind(
    'datahub.fix.addEnumValues',
    DartFixKindPriority.standard,
    "Add the 'values' argument",
  );

  static const addPartDirective = FixKind(
    'datahub.fix.addPartDirective',
    DartFixKindPriority.standard,
    'Add the generated part directive',
  );

  static const extendGeneratedClass = FixKind(
    'datahub.fix.extendGeneratedClass',
    DartFixKindPriority.standard,
    'Extend the generated data class',
  );

  static const moveSuperInitializeFirst = FixKind(
    'datahub.fix.moveSuperInitializeFirst',
    DartFixKindPriority.standard,
    'Move super.initialize() to the top',
  );

  static const moveSuperDisposeLast = FixKind(
    'datahub.fix.moveSuperDisposeLast',
    DartFixKindPriority.standard,
    'Move super.dispose() to the bottom',
  );
}

/// Assist kinds for the DataHub boilerplate generators.
abstract final class DatahubAssistKind {
  static const generateServiceInstance = AssistKind(
    'datahub.assist.generateServiceInstance',
    30,
    'Generate ServiceInstance',
  );

  static const convertToDataClass = AssistKind(
    'datahub.assist.convertToDataClass',
    30,
    'Convert to DataHub data class',
  );

  static const addFindInjection = AssistKind(
    'datahub.assist.addFindInjection',
    30,
    'Add Find injection field',
  );
}
