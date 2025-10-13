import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:datahub_aperture_frontend/widgets/dialogs/schedule_dialog.dart';
import 'package:datahub_aperture_frontend/widgets/resources/revision_view.dart';
import 'package:datahub_aperture_frontend/widgets/side_panel.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture_frontend/models/filtered_resource.dart';
import 'package:datahub_aperture_frontend/models/view_models/action_model.dart';
import 'package:datahub_aperture_frontend/widgets/form_fields/resource_field_form.dart';
import 'package:datahub_aperture_frontend/widgets/icon_text.dart';
import 'package:datahub_aperture_frontend/widgets/options_button.dart';
import 'package:flutter/material.dart';

import 'resource_relation_view.dart';

class ResourceElementEditView extends StatelessWidget {
  final String title;

  final ResourceData data;
  final List<ResourceField> fields;
  final Map<ResourceField, dynamic> changes;
  final Map<ResourceField, String> validations;
  final void Function(ResourceField field, dynamic value) onFieldValueChanged;

  final List<FilteredResource> relations;

  final void Function(DateTime? revisionLive)? onSavePressed;
  final void Function(DateTime? revisionLive)? onDeletePressed;

  final List<ActionModel> actions;
  final void Function(String)? onActionPressed;

  const ResourceElementEditView({
    super.key,
    required this.title,
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
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Spacer(),

                    if (actions.isNotEmpty && onActionPressed != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: OptionsButton(
                          menuChildren: [
                            for (final action in actions)
                              MenuItemButton(
                                onPressed: () => onActionPressed?.call(action.id),
                                leadingIcon: Icon(
                                  IconData(
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
                      ),

                    if (onDeletePressed != null)
                      OptionsButton(
                        onPressed: switch (onDeletePressed) {
                          final call? => () => call(DateTime.timestamp()),
                          _ => null,
                        },
                        menuEnabled: onDeletePressed != null,
                        menuChildren: [
                          MenuItemButton(
                            child: IconText(
                              Icons.schedule,
                              S.of(context).deleteScheduled,
                            ),
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
                        child: IconText(
                          Icons.delete_outline,
                          S.of(context).delete,
                        ),
                      ),
                  ],
                ),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 16,
                        children: [
                          ResourceFieldForm(
                            fields: fields,
                            data: data,
                            changes: changes,
                            validations: validations,
                            onFieldValueChanged: onFieldValueChanged,
                            onSavePressed: onSavePressed,
                          ),
                          for (final relation in relations)
                            ResourceRelationView(filteredResource: relation),
                        ],
                      ),
                    ),
                    //if (data.revision case final revision?)
                    //  SidePanel(child: RevisionView(revision: revision)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (data.revisionId != null)
          SidePanel(
            child: RevisionView(
              revisions: data.revisions,
              currentId: data.revisionId!,
            ),
          ),
      ],
    );
  }
}
