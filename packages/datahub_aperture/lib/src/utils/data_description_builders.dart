import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_aperture/utils.dart';

ResourceDescription buildResourceDescription(
  ApertureResource res,
  Iterable<DataBean> relatedBeans,
) {
  final repository = res.repository.find();
  final bean = repository.bean;
  final relations = bean.allMetaOfType<ApertureRelation>().map((meta) {
    final relatedBean = relatedBeans.firstWhere(
      (e) => e.type == meta.type,
      orElse: () => throw ApiError(
        'Related bean for ${meta.type.name} not found for ApertureRelation of ${bean.name}.',
      ),
    );

    final relationIdField = relatedBean.fields.firstWhere(
      (f) => f.hasMetaOfType<RelationId>((m) => m.type == bean.type),
      orElse: () => throw ApiError(
        'Data class ${relatedBean.name} does not provide RelationId for relation to ${bean.name}.',
      ),
    );

    final relatedMeta = relatedBean.meta.whereType<Meta>().firstOrNull;
    return ResourceRelation(
      name: relatedMeta?.namePlural ?? relatedMeta?.name ?? relatedBean.name,
      resourceId: relatedBean.name,
      filter: ResourceRelationFilter(
        fieldId: relationIdField.name,
        type: ResourceFilterType.equals,
        valueFieldId: bean.requireIdField.name,
      ),
    );
  }).toList();

  final meta = bean.metaOfType<Meta>();
  final apertureMeta = bean.metaOfType<ApertureMeta>();
  final workflow = findResourceWorkflow(res);

  final isReadOnly = false;
  return ResourceDescription(
    id: buildResourceId(res),
    name: meta?.name ?? niceName(bean.name),
    namePlural: meta?.namePlural,
    icon: meta?.icon ?? Icons.data_object,
    readOnly: isReadOnly,
    revisable: repository is RevisableDataRepository,
    actions: [
      for (final action in res.actions) action.buildDescription(relatedBeans),
    ],
    fields: [
      for (final field in bean.fields)
        fieldDescription(bean, field, relatedBeans),
    ],
    relations: relations,
    idField: bean.fields
        .firstWhere(
          (e) => e.meta.whereType<Id>().isNotEmpty,
          orElse: () => throw MissingIdFieldError(bean),
        )
        .name,
    displayFields: bean.fields
        .where((e) => e.hasMetaOfType<ApertureField>((e) => e.isDisplayField))
        .map((e) => e.name)
        .toList(),
    titleTemplate: apertureMeta?.titleTemplate,
    workflow: workflow != null
        ? buildResourceWorkflowDescription(workflow, relatedBeans)
        : null,
  );
}

String buildResourceId(ApertureResource res) => res.repository.find().bean.name;

/// The workflow of the element type of [res], if the application has one.
///
/// The element type identifies a workflow, so no configuration is needed.
Workflow? findResourceWorkflow(ApertureResource res) {
  final name = res.repository.find().bean.name;
  return Find<Workflow?>(
    (workflow) => workflow?.describe().name == name,
  ).find();
}

ResourceWorkflow buildResourceWorkflowDescription(
  Workflow workflow,
  Iterable<DataBean> relatedBeans,
) {
  final description = workflow.describe();
  return ResourceWorkflow(
    stateField: description.stateField,
    states: description.states,
    writesHistory: description.writesHistory,
    steps: [
      for (final step in description.steps)
        ResourceWorkflowStep(
          name: step.name,
          kind: step.kind,
          state: step.state,
          after: step.after,
          scheduled: step.scheduled,
          accept: step.accept,
          signal: step.signalBean?.name,
          failureState: step.failureState,
        ),
    ],
    signals: [
      for (final step in description.steps)
        if (step.signalBean case final bean?)
          ResourceWorkflowSignal(
            action: _actionDescription(
              bean,
              relatedBeans,
              defaultIcon: Icons.bolt,
            ),
            accept: step.accept,
          ),
    ],
  );
}

ResourceField fieldDescription(
  DataBean bean,
  DataField field,
  Iterable<DataBean> relatedBeans,
) {
  final meta = field.metaOfType<Meta>();
  final apertureMeta = field.metaOfType<ApertureField>();
  final validation = field.constraintOfType<RegExpConstraint>();
  final length = field.constraintOfType<MaxLengthConstraint>();
  final isAuto = field.hasMetaOfType<Id>((id) => id.auto);

  // Relations to types that are no resource have nothing to look up.
  final ResourceFieldLookup? lookup;
  if (field.metaOfType<RelationId>() case final relationId?
      when relatedBeans.any((e) => e.type == relationId.type)) {
    final relationBean = relatedBeans.firstWhere(
      (e) => e.type == relationId.type,
    );
    lookup = ResourceFieldLookup(
      resourceId: relationBean.name,
      resourceFieldId: relationBean.requireIdField.name,
      filter: ResourceRelationFilter(),
    );
  } else {
    lookup = null;
  }

  final type = _fieldType(field);
  return ResourceField(
    id: field.name,
    name: meta?.name ?? niceName(field.name),
    description: meta?.description,
    readOnly: isAuto || (apertureMeta?.readOnly ?? false),
    auto: isAuto,
    validation: validation?.expression,
    length: length?.length,
    type: type,
    nullable: field.type.isNullable,
    objectDescription: _objectDescription(field, type, relatedBeans),
    enumValues: field
        .constraintOfType<EnumConstraint>()
        ?.values
        .map((e) => e.name)
        .toList(),
    lookup: lookup,
  );
}

List<ResourceField>? _objectDescription(
  DataField field,
  ResourceFieldType type,
  Iterable<DataBean> relatedBeans,
) {
  if (type == ResourceFieldType.list) {
    final constraints = field.constraints
        .whereType<ElementConstraint>()
        .map((e) => e.constraint)
        .toList();
    return [
      ResourceField(
        id: 'element',
        name: '',
        type: _fieldListElementType(field),
        readOnly: field.metaOfType<ApertureField>()?.readOnly ?? false,
        nullable: false,
        validation: constraints
            .whereType<RegExpConstraint>()
            .firstOrNull
            ?.expression,
        length: constraints
            .whereType<MaxLengthConstraint>()
            .firstOrNull
            ?.length,
        objectDescription: [
          if (field.dataBean case final bean?)
            for (final field in bean.fields)
              fieldDescription(bean, field, relatedBeans),
        ],
        enumValues: constraints
            .whereType<EnumConstraint>()
            .firstOrNull
            ?.values
            .map((e) => e.name)
            .toList(),
      ),
    ];
  }

  return [
    if (field.dataBean case final bean?)
      for (final field in bean.fields)
        fieldDescription(bean, field, relatedBeans),
  ];
}

ResourceFieldType _fieldType(DataField<dynamic, dynamic> field) {
  return switch (field) {
    DataField<dynamic, String?>() => ResourceFieldType.string,
    DataField<dynamic, Enum?>() => ResourceFieldType.stringEnum,
    DataField<dynamic, int?>() => ResourceFieldType.int,
    DataField<dynamic, double?>() => ResourceFieldType.double,
    DataField<dynamic, bool?>() => ResourceFieldType.bool,
    DataField<dynamic, DateTime?>() => ResourceFieldType.timestamp,
    DataField<dynamic, Uint8List?>() => ResourceFieldType.bytes,
    DataField<dynamic, Geometry?>() => ResourceFieldType.geometry,
    DataField<dynamic, DataObject?>() => ResourceFieldType.object,
    DataField<dynamic, Map<String, dynamic>?>()
        when field.type.isSupertypeOf<Map<String, dynamic>>() =>
      ResourceFieldType.jsonMap,
    DataField<dynamic, List?>() when field.type.isSupertypeOf<List>() =>
      ResourceFieldType.jsonList,
    DataField<dynamic, List?>() => ResourceFieldType.list,
    _ => throw ApiError(
      'Field ${field.name} of type ${field.type.name} is not supported by Aperture.',
    ),
  };
}

ResourceFieldType _fieldListElementType(DataField<dynamic, dynamic> field) {
  return switch (field) {
    DataField<dynamic, List<String>?>() => ResourceFieldType.string,
    DataField<dynamic, List<Enum>?>() => ResourceFieldType.stringEnum,
    DataField<dynamic, List<int>?>() => ResourceFieldType.int,
    DataField<dynamic, List<double>?>() => ResourceFieldType.double,
    DataField<dynamic, List<bool>?>() => ResourceFieldType.bool,
    DataField<dynamic, List<DateTime>?>() => ResourceFieldType.timestamp,
    DataField<dynamic, List<Uint8List>?>() => ResourceFieldType.bytes,
    DataField<dynamic, List<Geometry>?>() => ResourceFieldType.geometry,
    DataField<dynamic, List<DataObject>?>() => ResourceFieldType.object,
    _ => throw ApiError(
      'Field ${field.name} of type ${field.type.name} is not supported by Aperture.',
    ),
  };
}

ResourceAction buildResourceActionDescription(
  ApertureAction action,
  Iterable<DataBean> beans,
) => _actionDescription(action.bean, beans, defaultIcon: Icons.data_object);

String buildResourceActionId(ApertureAction action) => action.bean.name;

/// An action whose parameters are the fields of [bean], used for actions and
/// for workflow signals.
ResourceAction _actionDescription(
  DataBean bean,
  Iterable<DataBean> beans, {
  required int defaultIcon,
}) {
  final meta = bean.metaOfType<Meta>();

  return ResourceAction(
    id: bean.name,
    displayName: meta?.name ?? niceName(bean.name),
    icon: meta?.icon ?? defaultIcon,
    parameterFields: [
      for (final field in bean.fields) fieldDescription(bean, field, beans),
    ],
  );
}
