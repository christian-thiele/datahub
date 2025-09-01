import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_resource_repository.dart';
import 'package:datahub_aperture/src/data/meta/aperture_display_field.dart';
import 'package:datahub_aperture/src/data/meta/aperture_field.dart';

class ApertureDataResource<T extends DataObject<T>> extends ApertureResource {
  final DataBean<T> bean;

  ApertureDataResource(this.bean, {required super.repository})
      : super(description: _description(bean, repository));

  static ResourceDescription _description<T extends DataObject<T>>(
    DataBean<T> bean,
    ApertureResourceRepository repository,
  ) {
    final meta = bean.meta.whereType<Meta>().firstOrNull;
    return ResourceDescription(
      id: bean.name,
      name: meta?.name ?? bean.name,
      namePlural: meta?.namePlural,
      icon: meta?.icon ?? Icons.data_object,
      readOnly: repository is! ApertureResourceWriteRepository,
      fields: [
        for (final field in bean.fields) _fieldDescription<T>(bean, field),
      ],
      relations: [],
      idField: bean.fields
          .firstWhere(
            (e) => e.meta.whereType<Id>().isNotEmpty,
            orElse: () => throw ApiError(
              'Data class ${bean.name} does not provide an Id field.',
            ),
          )
          .name,
      displayField: bean.fields
          .where((e) => e.meta.whereType<ApertureDisplayField>().isNotEmpty)
          .firstOrNull
          ?.name,
    );
  }

  static ResourceField _fieldDescription<T extends DataObject<T>>(
    DataBean<T> bean,
    DataField<T, dynamic> field,
  ) {
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
