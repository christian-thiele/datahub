import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/models/filtered_resource.dart';
import 'package:datahub_aperture_frontend/models/view_models/action_model.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/schedule_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_field_form.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/options_button.dart';
import 'package:datahub_aperture_frontend/widgets/page_header.dart';
import 'package:datahub_aperture_frontend/widgets/resources/revision_view.dart';
import 'package:datahub_aperture_frontend/widgets/side_panel.dart';
import 'package:flutter/material.dart';

import 'resource_relation_view.dart';

class ResourceElementEditView extends StatelessWidget {
  final String title;

  final ResourceData data;
  final List<ResourceField> fields;
  final Map<ResourceField, dynamic> changes;
  final Map<String, String> validations;
  final void Function(ResourceField field, dynamic value) onFieldValueChanged;

  final List<FilteredResource> relations;

  final void Function(DateTime? from)? onSavePressed;
  final void Function(DateTime? from)? onDeletePressed;

  final List<ActionModel> actions;
  final void Function(String)? onActionPressed;
  final bool revisable;

  /// Leads to this element, not including its [title].
  final List<Breadcrumb> breadcrumbs;

  const ResourceElementEditView({
    super.key,
    required this.title,
    this.breadcrumbs = const [],
    required this.fields,
    required this.data,
    required this.changes,
    this.validations = const {},
    this.relations = const [],
    required this.onFieldValueChanged,
    required this.onSavePressed,
    this.onDeletePressed,
    required this.actions,
    this.onActionPressed,
    this.revisable = true,
  });

  @override
  Widget build(BuildContext context) {
    final readOnly =
        data.version != null &&
        data.revisions.isNotEmpty &&
        data.version !=
            data.revisions
                .map((e) => e.version)
                .fold<int>(0, (max, v) => v > max ? v : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        PageHeader(
          title: title,
          breadcrumbs: [...breadcrumbs, Breadcrumb(title)],
          actions: [
            if (actions.isNotEmpty && onActionPressed != null)
              OptionsButton(
                variant: OptionsButtonVariant.secondary,
                menuChildren: [
                  for (final action in actions)
                    MenuItemButton(
                      onPressed: () => onActionPressed?.call(action.id),
                      leadingIcon: Icon(
                        IconData(
                          // ignore: non_const_argument_for_const_parameter
                          action.icon,
                          fontFamily: 'MaterialIcons',
                        ),
                      ),
                      child: Text(action.name),
                    ),
                ],
                child: IconText(
                  Icons.play_circle_outline,
                  S.of(context).actions,
                ),
              ),
            if (onDeletePressed != null)
              OptionsButton(
                variant: OptionsButtonVariant.danger,
                onPressed: switch (onDeletePressed) {
                  final call? => () => call(null),
                  _ => null,
                },
                menuEnabled: revisable && onDeletePressed != null,
                menuChildren: [
                  if (revisable) ...[
                    MenuItemButton(
                      leadingIcon: Icon(Icons.schedule),
                      child: Text(S.of(context).deleteScheduled),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ScheduleDialog(
                            title: S.of(context).deleteScheduled,
                          ),
                        ).then((result) {
                          if (result case DateTime liveDate) {
                            onDeletePressed?.call(liveDate);
                          }
                        });
                      },
                    ),
                  ],
                ],
                child: IconText(Icons.delete_outline, S.of(context).delete),
              ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showRevisions = revisable && data.version != null;
              final revisionView = showRevisions
                  ? RevisionView(
                      revisions: data.revisions,
                      currentVersion: data.version!,
                    )
                  : null;
              final stacked = constraints.maxWidth < 900;

              final content = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ResourceFieldForm(
                        fields: fields,
                        data: data,
                        changes: changes,
                        validations: validations,
                        onFieldValueChanged: onFieldValueChanged,
                        onSavePressed: onSavePressed,
                        revisable: revisable,
                        readOnly: readOnly,
                      ),
                    ),
                  ),
                  for (final relation in relations)
                    ResourceRelationView(filteredResource: relation),
                  if (stacked && revisionView != null)
                    SizedBox(
                      height: 520,
                      child: SidePanel(width: null, child: revisionView),
                    ),
                ],
              );

              if (stacked) {
                return SingleChildScrollView(child: content);
              }

              return Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  Expanded(child: SingleChildScrollView(child: content)),
                  if (revisionView != null) SidePanel(child: revisionView),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
