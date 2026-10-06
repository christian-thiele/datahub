import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../../util/constant_values.dart';
import '../../util/datahub_types.dart';

// The rules in this file report what `Schedule.validate` and
// `Scheduler.registerSchedule` throw for while the application starts.

/// Reports a `Schedule` whose name is empty.
class ScheduleRequiresNameRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'schedule_requires_name',
    'A schedule needs a name.',
    correctionMessage:
        'Try giving the schedule a name that is unique in the application.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.schedule_requires_name',
  );

  ScheduleRequiresNameRule()
    : super(
        name: 'schedule_requires_name',
        description:
            'The name identifies a schedule across instances, so it must not '
            'be empty.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _ScheduleVisitor((schedule) {
        final name = schedule.name;
        if (name != null && stringValueOf(name) == '') {
          reportAtNode(name);
        }
      }),
    );
  }
}

/// Reports a `Schedule.every` whose interval is not positive.
class ScheduleRequiresPositiveIntervalRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'schedule_requires_positive_interval',
    'The interval of a schedule must be positive.',
    correctionMessage: 'Try an interval greater than Duration.zero.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.schedule_requires_positive_interval',
  );

  ScheduleRequiresPositiveIntervalRule()
    : super(
        name: 'schedule_requires_positive_interval',
        description: 'Schedule.every needs an interval greater than zero.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _ScheduleVisitor((schedule) {
        if (schedule.kind != 'every') {
          return;
        }

        final interval = namedArgument(schedule.node, 'interval');
        final value = interval == null ? null : durationValueOf(interval);
        if (interval != null && value != null && value <= Duration.zero) {
          reportAtNode(interval);
        }
      }),
    );
  }
}

/// Reports a `Schedule.daily` / `Schedule.monthly` with a day, hour or minute
/// out of range.
class ScheduleTimeOutOfRangeRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'schedule_time_out_of_range',
    "'{0}' must be between {1} and {2}, but is {3}.",
    correctionMessage: "Try a '{0}' between {1} and {2}.",
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.schedule_time_out_of_range',
  );

  /// The valid range of each argument. Days after the end of a month mean its
  /// last day, so every month accepts 31.
  static const _ranges = {'day': (1, 31), 'hour': (0, 23), 'minute': (0, 59)};

  ScheduleTimeOutOfRangeRule()
    : super(
        name: 'schedule_time_out_of_range',
        description:
            'Daily and monthly schedules need an hour between 0 and 23, a '
            'minute between 0 and 59 and a day between 1 and 31.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _ScheduleVisitor((schedule) {
        if (schedule.kind == 'every') {
          return;
        }

        for (final MapEntry(key: name, value: (min, max)) in _ranges.entries) {
          final argument = namedArgument(schedule.node, name);
          final value = argument == null ? null : intValueOf(argument);
          if (argument != null &&
              value != null &&
              (value < min || value > max)) {
            reportAtNode(argument, arguments: [name, min, max, value]);
          }
        }
      }),
    );
  }
}

/// Reports schedules with the same name in one list of components.
///
/// Schedules are registered with the one scheduler of the application, which
/// throws for the second one. Schedules spread across several lists or added
/// at runtime are not compared.
class DuplicateScheduleNameRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'duplicate_schedule_name',
    "There is already a schedule named '{0}'.",
    correctionMessage: 'Try giving each schedule a unique name.',
    severity: DiagnosticSeverity.WARNING,
    uniqueName: 'LintCode.duplicate_schedule_name',
  );

  DuplicateScheduleNameRule()
    : super(
        name: 'duplicate_schedule_name',
        description:
            'The name identifies a schedule across instances, so it must be '
            'unique in the application.',
      );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addListLiteral(this, _DuplicateVisitor(this));
  }
}

class _DuplicateVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _DuplicateVisitor(this.rule);

  @override
  void visitListLiteral(ListLiteral node) {
    final names = <String>{};
    for (final element in node.elements.whereType<Expression>()) {
      final name = _ScheduleCreation.of(element)?.name;
      final value = name == null ? null : stringValueOf(name);
      if (name != null && value != null && !names.add(value)) {
        rule.reportAtNode(name, arguments: [value]);
      }
    }
  }
}

/// A `Schedule.every(...)`, `Schedule.daily(...)` or `Schedule.monthly(...)`.
class _ScheduleCreation {
  final InstanceCreationExpression node;

  /// The name of the factory constructor.
  final String kind;

  _ScheduleCreation(this.node, this.kind);

  static _ScheduleCreation? of(Expression expression) {
    if (expression is! InstanceCreationExpression ||
        !isType(expression.staticType, 'Schedule')) {
      return null;
    }

    return switch (expression.constructorName.name?.name) {
      final kind? => _ScheduleCreation(expression, kind),
      null => null,
    };
  }

  /// The name argument.
  Expression? get name => positionalArgument(node, 0);
}

class _ScheduleVisitor extends SimpleAstVisitor<void> {
  final void Function(_ScheduleCreation schedule) onSchedule;

  _ScheduleVisitor(this.onSchedule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (_ScheduleCreation.of(node) case final schedule?) {
      onSchedule(schedule);
    }
  }
}
