import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:flutter/material.dart';

/// The steps of a workflow and what triggers them.
class WorkflowStepsView extends StatelessWidget {
  final ResourceWorkflow workflow;

  const WorkflowStepsView({super.key, required this.workflow});

  static String trigger(BuildContext context, ResourceWorkflowStep step) {
    final s = S.of(context);
    return [
      switch (step.kind) {
        WorkflowStepKind.enter => s.stepOnEnter(step.state ?? ''),
        WorkflowStepKind.signal => s.stepOnSignal(step.accept.join(', ')),
      },
      if (step.scheduled)
        s.stepAtElementTime
      else if (step.after case final after? when after > Duration.zero)
        s.stepAfter(formatCoarseDuration(after)),
      if (step.failureState case final failureState?)
        s.stepFailureState(failureState),
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          S.of(context).steps,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final step in workflow.steps)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  step.kind == WorkflowStepKind.signal
                      ? Icons.bolt
                      : Icons.login,
                  size: 16,
                  color: colors.textMuted,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.name,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      trigger(context, step),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
