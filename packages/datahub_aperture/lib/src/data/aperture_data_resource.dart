import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_aperture/utils.dart';

import 'aperture_data_action.dart';
import 'meta/aperture_relation.dart';
import 'meta/aperture_display_field.dart';
import 'meta/aperture_field.dart';

class ApertureDataResource {
  final DataBean bean;
  final Find<DataRepository> repository;
  final List<ApertureDataAction> actions;

  const ApertureDataResource(
    this.bean,
    this.repository, {
    this.actions = const [],
  });

  ResourceDescription buildDescription(Iterable<DataBean> relatedBeans) {
    final relations = bean.allMetaOfType<ApertureRelation>().map((meta) {
      final relatedBean = relatedBeans.firstWhere(
        (e) => e.type == meta.type,
        orElse: () => throw ApiError(
            'Related bean for ${meta.type.name} of ${bean.name} not found for ApertureRelation.'),
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

    return ResourceDescription(
      id: bean.name,
      name: meta?.name ?? niceName(bean.name),
      namePlural: meta?.namePlural,
      icon: meta?.icon ?? Icons.data_object,
      readOnly: repository is! ApertureResourceWriteRepository,
      actions: [
        for (final action in actions) action.buildDescription(relatedBeans),
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
      displayField: bean.fields
          .where((e) => e.meta.whereType<ApertureDisplayField>().isNotEmpty)
          .firstOrNull
          ?.name,
    );
  }

  static ResourceField fieldDescription(
      DataBean bean, DataField field, Iterable<DataBean> relatedBeans) {
    final meta = field.metaOfType<Meta>();
    final apertureMeta = field.metaOfType<ApertureField>();
    final validation = field.constraintOfType<RegExpConstraint>();
    final length = field.constraintOfType<MaxLengthConstraint>();

    final ResourceFieldLookup? lookup;
    if (field.metaOfType<RelationId>() case final relationId?) {
      final relationBean =
          relatedBeans.firstWhere((e) => e.type == relationId.type);
      lookup = ResourceFieldLookup(
        resourceId: relationBean.name,
        resourceFieldId: relationBean.requireIdField.name,
        filter: ResourceRelationFilter(),
      );
    } else {
      lookup = null;
    }

    return ResourceField(
      id: field.name,
      name: meta?.name ?? niceName(field.name),
      description: meta?.description,
      readOnly: apertureMeta?.readOnly ?? false,
      validation: validation?.expression,
      length: length?.length,
      type: _fieldType(field),
      nullable: field.type.isNullable,
      objectDescription: _objectDescription(field, relatedBeans),
      enumValues: field
          .constraintOfType<EnumConstraint>()
          ?.values
          .map((e) => e.name)
          .toList(),
      lookup: lookup,
    );
  }

  static List<ResourceField>? _objectDescription(
    DataField field,
    Iterable<DataBean> relatedBeans,
  ) {
    if (field case DataField<dynamic, List?>()) {
      return [
        ResourceField(
          id: 'element',
          name: '',
          type: _fieldListElementType(field),
          readOnly: field.metaOfType<ApertureField>()?.readOnly ?? false,
          nullable: false,
          objectDescription: [
            if (field.dataBean case final bean?)
              for (final field in bean.fields)
                fieldDescription(bean, field, relatedBeans),
          ],
          enumValues: field
              .constraintOfType<EnumConstraint>()
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

  static ResourceFieldType _fieldType(DataField<dynamic, dynamic> field) {
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
      DataField<dynamic, List>() => ResourceFieldType.list,
      _ => throw ApiError(
          'Field ${field.name} of type ${field.type.name} is not supported by Aperture.',
        )
    };
  }

  static ResourceFieldType _fieldListElementType(
      DataField<dynamic, dynamic> field) {
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
        )
    };
  }
}
