import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';
import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_aperture/src/data/aperture_data_resource.dart';

import 'meta/aperture_relation.dart';
import 'meta/aperture_field.dart';
import 'meta/aperture_display_field.dart';

class ApertureConfigDataDelegate implements ApertureConfigDelegate {
  @override
  final String title;

  @override
  final ApertureTheme theme;

  @override
  late final List<ApertureResource> resources;

  ApertureConfigDataDelegate({
    this.title = 'Aperture',
    this.theme = const ApertureTheme(),
    List<ApertureDataResource> dataResources = const [],
  }) {
    resources = [
      for (final res in dataResources)
        ApertureResource(
          description: buildDescription(res, dataResources.map((e) => e.bean)),
          repository: res.repository,
        )
    ];
  }

  static ResourceDescription buildDescription(
    ApertureDataResource resource,
    Iterable<DataBean> beans,
  ) {
    final bean = resource.bean;
    final repository = resource.repository;

    final relations = bean.meta.whereType<ApertureRelation>().map((meta) {
      final idField = bean.idField ?? (throw MissingIdFieldError(bean));

      final relatedBean = beans.firstWhere(
        (e) => e.type == meta.type,
        orElse: () => throw ApiError(
            'Related bean for ${meta.type.name} of ${bean.name} not found for ApertureRelation.'),
      );

      final relationIdField = relatedBean.fields.firstWhere(
        (f) => f.meta.whereType<RelationId>().any((m) => m.type == bean.type),
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
          valueFieldId: idField.name,
        ),
      );
    }).toList();

    final meta = bean.meta.whereType<Meta>().firstOrNull;

    return ResourceDescription(
      id: bean.name,
      name: meta?.name ?? niceName(bean.name),
      namePlural: meta?.namePlural,
      icon: meta?.icon ?? Icons.data_object,
      readOnly: repository is! ApertureResourceWriteRepository,
      fields: [
        for (final field in bean.fields) _fieldDescription(bean, field),
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

  static ResourceField _fieldDescription(DataBean bean, DataField field) {
    final meta = field.meta.whereType<Meta>().firstOrNull;
    final apertureMeta = field.meta.whereType<ApertureField>().firstOrNull;
    final validation = field.constraintOfType<RegExpConstraint>();
    final length = field.constraintOfType<MaxLengthConstraint>();

    return ResourceField(
      id: field.name,
      name: meta?.name ?? niceName(field.name),
      description: meta?.description,
      readOnly: apertureMeta?.readOnly ?? false,
      validation: validation?.expression,
      length: length?.length,
      type: _fieldType(field),
      nullable: field.type.isNullable,
      objectDescription: _objectDescription(field, meta, apertureMeta),
      enumValues: field
          .constraintOfType<EnumConstraint>()
          ?.values
          .map((e) => e.name)
          .toList(),
    );
  }

  static List<ResourceField>? _objectDescription(
    DataField field,
    Meta? meta,
    ApertureField? apertureMeta,
  ) {
    if (field case DataField<dynamic, List?>()) {
      return [
        ResourceField(
          id: 'element',
          name: '',
          type: _fieldListElementType(field),
          readOnly: apertureMeta?.readOnly ?? false,
          nullable: false,
          objectDescription: [
            if (field.dataBean case final bean?)
              for (final field in bean.fields) _fieldDescription(bean, field),
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
        for (final field in bean.fields) _fieldDescription(bean, field),
    ];
  }

  static String niceName(String name) {
    return splitWords(name)
        .map(firstUpper)
        .map((e) => (e == 'Id') ? 'ID' : e)
        .join(' ');
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
