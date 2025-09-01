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
  late final List<ApertureResource> resources;

  ApertureConfigDataDelegate({
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
      name: meta?.name ?? bean.name,
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
    final validation = field.meta.whereType<Validation>().firstOrNull;

    return ResourceField(
      id: field.name,
      name: meta?.name ?? field.name,
      description: meta?.description,
      readOnly: apertureMeta?.readOnly ?? false,
      validation: validation?.expression,
      type: switch (field) {
        DataField<dynamic, String?>() => ResourceFieldType.text,
        DataField<dynamic, int?>() => ResourceFieldType.int,
        DataField<dynamic, double?>() => ResourceFieldType.double,
        DataField<dynamic, bool?>() => ResourceFieldType.bool,
        DataField<dynamic, DateTime?>() => ResourceFieldType.timestamp,
        DataField<dynamic, Uint8List?>() => ResourceFieldType.file,
        _ => throw ApiError(
            'Field ${bean.name}.${field.name} of type ${field.type} is not supported by Aperture.',
          )
      },
      nullable: field.type.isNullable,
    );
  }
}
