import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_codegen/src/data_bean/field_description.dart';

import 'package:datahub_codegen/utils.dart';

import 'data_bean_exception.dart';

class DataBeanField {
  final FieldElement field;
  final ParameterElement parameter;
  final FieldDescription dataField;
  final String? foreignFieldAccessor;

  DataBeanField(
    this.field,
    this.parameter,
    this.dataField,
    this.foreignFieldAccessor,
  );

  DataBeanField.fromElements(
    this.field,
    this.parameter,
    NamingConvention convention,
  )   : dataField = getDataFieldDescription(field, convention),
        foreignFieldAccessor = getForeignFieldAccessor(field);

  String get valueAccessor => field.type.isEnum
      ? '${field.name}${dataField.nullable ? '?.name' : '.name'}'
      : field.name;

  static FieldDescription getDataFieldDescription(
    FieldElement field,
    NamingConvention convention,
  ) {
    final fieldName = getColumnName(field, convention);
    final fieldType = getTypeName(field) ?? getInferredTypeName(field);
    final fieldLength = getLength(field);
    final fieldNullable = getNullability(field);
    final layoutName =
        getLayoutName(field.enclosingElement as ClassElement, convention);

    if (isPrimaryKeyField(field)) {
      if (fieldType != 'IntDataType' &&
          fieldType != 'SerialDataType' &&
          fieldType != 'StringDataType') {
        throw DataBeanException(
            'Invalid field type for primary key field: $fieldType');
      }

      if (fieldNullable) {
        throw DataBeanException('Primary key field $fieldType is nullable.');
      }

      return PrimaryKeyFieldDescription(
        layoutName: layoutName,
        name: fieldName,
        nullable: fieldNullable,
        length: fieldLength,
        typeName: fieldType,
        dartType: field.type,
        autoIncrement: isAutoIncrement(field),
        isReactivePartition: isReactivePartition(field),
      );
    } else if (isForeignKeyField(field)) {
      final foreignPrimary = getForeignPrimaryKeyDescription(field, convention);
      if (field.type != foreignPrimary.dartType) {
        throw DataBeanException(
            'Foreign key field "${field.name}" does not match type of foreign primary key.');
      }
      return ForeignKeyFieldDescription(
        typeName: field.type.isDartCoreInt ? 'IntDataType' : 'StringDataType',
        foreignPrimaryKey: foreignPrimary,
        layoutName: layoutName,
        name: fieldName,
        nullable: fieldNullable,
        length: fieldLength,
        dartType: field.type,
        isReactivePartition: isReactivePartition(field),
      );
    } else {
      return FieldDescription(
        typeName: fieldType,
        layoutName: layoutName,
        name: fieldName,
        nullable: fieldNullable,
        length: fieldLength,
        dartType: field.type,
        isReactivePartition: isReactivePartition(field),
      );
    }
  }

  static String getInferredTypeName(FieldElement field) {
    final fieldType = field.type;
    return switch (fieldType) {
      DartType(isDartCoreString: true) => 'StringDataType',
      DartType(isDartCoreInt: true) => 'IntDataType',
      DartType(isDartCoreDouble: true) => 'DoubleDataType',
      DartType(isDartCoreBool: true) => 'BoolDataType',
      DartType(isDartCoreDateTime: true) => 'DateTimeDataType',
      DartType(isUint8List: true) => 'ByteDataType',
      DartType(isEnum: true) => 'StringDataType',
      DartType(isTransferObject: true) ||
      DartType(isJsonMapType: true) =>
        'JsonMapDataType',
      ParameterizedType(
        isDartCoreList: true,
        typeArguments: [
          DartType(isDartCoreString: true) || DartType(isEnum: true)
        ]
      ) =>
        'StringArrayDataType',
      ParameterizedType(
        isDartCoreList: true,
        typeArguments: [DartType(isDartCoreInt: true)]
      ) =>
        'IntArrayDataType',
      ParameterizedType(
        isDartCoreList: true,
        typeArguments: [DartType(isDartCoreDouble: true)]
      ) =>
        'DoubleArrayDataType',
      ParameterizedType(
        isDartCoreList: true,
        typeArguments: [DartType(isDartCoreBool: true)]
      ) =>
        'BoolArrayDataType',
      DartType(isDartCoreList: true) => 'JsonListDataType',
      _ => throw DataBeanException.invalidType(fieldType),
    };
  }

  static String getColumnName(FieldElement field, NamingConvention convention) {
    final annotation = getAnnotation(field, DaoField);
    return readFieldLiteral<String>(annotation, 'name') ??
        toNamingConvention(field.name, convention);
  }

  static bool getNullability(FieldElement field) {
    return field.type.nullabilitySuffix != NullabilitySuffix.none;
  }

  static int getLength(FieldElement field) {
    final annotation = getAnnotation(field, DaoField);
    return readFieldLiteral<int>(annotation, 'length') ?? 0;
  }

  static String? getTypeName(FieldElement field) {
    final annotation = getAnnotation(field, DaoField);
    final obj = readField(annotation, 'type');
    return obj?.toTypeValue()?.element?.name;
  }

  static FieldElement? findPrimaryKeyField(List<FieldElement> fields) {
    final primaryKeyFields = fields.where(isPrimaryKeyField).toList();
    if (primaryKeyFields.length > 1) {
      throw DataBeanException('DAO has multiple primary key fields.');
    }
    return primaryKeyFields.firstOrNull;
  }

  static bool isPrimaryKeyField(FieldElement field) {
    return getAnnotation(field, PrimaryKeyDaoField) != null;
  }

  static bool isForeignKeyField(FieldElement field) {
    return getAnnotation(field, ForeignKeyDaoField) != null;
  }

  static bool isAutoIncrement(FieldElement field) {
    final annotation = getAnnotation(field, PrimaryKeyDaoField);
    if (annotation != null) {
      return readFieldLiteral<bool>(annotation, 'autoIncrement')!;
    }
    return false;
  }

  static bool isReactivePartition(FieldElement field) {
    final annotation = getAnnotation(field, ReactivePartition);
    return annotation != null;
  }

  static PrimaryKeyFieldDescription getForeignPrimaryKeyDescription(
      FieldElement field, NamingConvention convention) {
    final annotation = getAnnotation(field, ForeignKeyDaoField) ??
        (throw Exception('Not a foreign key field.'));
    final foreignType = readTypeField(annotation, 'foreignType')!;
    final fieldElement = findPrimaryKeyField(
            podoFields(foreignType.element as ClassElement).a.toList()) ??
        (throw DataBeanException(
            'DAO "${foreignType.element?.name}" does not provide a primary key.'));
    return getDataFieldDescription(fieldElement, convention)
        as PrimaryKeyFieldDescription;
  }

  static String? getForeignFieldAccessor(FieldElement field) {
    final annotation = getAnnotation(field, ForeignKeyDaoField);
    if (annotation == null) {
      return null;
    }

    final foreignType = readTypeField(annotation, 'foreignType')!;
    final foreignClassElement = foreignType.element as ClassElement;
    final fieldElement = findPrimaryKeyField(
            podoFields(foreignClassElement).a.toList()) ??
        (throw DataBeanException(
            'DAO "${foreignType.element?.name}" does not provide a primary key.'));
    return '${foreignClassElement.name}DataBean.${fieldElement.name}';
  }

  String getEncodingStatement(String accessor) {
    if (field.type.isDartCoreList) {
      final elementType = (field.type as ParameterizedType).typeArguments.first;
      if (elementType.isTransferObject) {
        final elementTypeNullable =
            elementType.nullabilitySuffix != NullabilitySuffix.none;
        final elementTypeName =
            '${elementType.element!.name}${elementTypeNullable ? '?' : ''}';
        return 'encodeList<List<$elementTypeName>${dataField.nullable ? '?' : ''}, $elementTypeName>($accessor, (v) => v${elementTypeNullable ? '?' : ''}.toJson())';
      }
    }

    if (field.type.isTransferObject) {
      return '$accessor${dataField.nullable ? '?' : ''}.toJson()';
    }

    return accessor;
  }

  /// Get statement for decoding field type value from map object.
  String getDecodingStatement(String objectName) {
    final accessor = "$objectName['${dataField.name}']";

    if (field.type.isEnum) {
      final enumType = field.type.element!.name!;
      if (dataField.nullable) {
        return '$enumType.values.cast<$enumType?>().firstWhere((v) => v?.name == ($accessor), orElse: () => null)';
      } else {
        return '$enumType.values.firstWhere((v) => v.name == ($accessor))';
      }
    } else if (field.type.isDartCoreList) {
      final elementType = (field.type as ParameterizedType).typeArguments.first;
      final elementTypeNullable =
          elementType.nullabilitySuffix != NullabilitySuffix.none;
      final elementTypeName =
          '${elementType.element!.name}${elementTypeNullable ? '?' : ''}';

      if (elementType.isEnum) {
        final enumType = elementType.element!.name!;
        final decodeNonNull = '$enumType.values.firstWhere((e) => e.name == v)';
        final decode = elementTypeNullable
            ? '$accessor != null ? $decodeNonNull : null'
            : decodeNonNull;

        return 'decodeList<List<$elementTypeName>${dataField.nullable ? '?' : ''}, $elementTypeName>($accessor, (v, n) => $decode)';
      } else if (elementType.isTransferObject) {
        final decodeNonNull =
            '${elementType.element!.name}TransferBean.toObject(v, name: n)';
        final decode = elementTypeNullable
            ? '$accessor != null ? $decodeNonNull : null'
            : decodeNonNull;

        return 'decodeList<List<$elementTypeName>${dataField.nullable ? '?' : ''}, $elementTypeName>($accessor, (v, n) => $decode)';
      }

      return 'decodeListTyped<List<$elementTypeName>${dataField.nullable ? '?' : ''}, $elementTypeName>($accessor)';
    } else if (field.type.isDartCoreMap) {
      final elementType = (field.type as ParameterizedType).typeArguments[1];
      final elementTypeNullable =
          elementType.nullabilitySuffix != NullabilitySuffix.none;
      final elementTypeName =
          '${elementType.element!.name}${elementTypeNullable ? '?' : ''}';
      return 'decodeMapTyped<Map<String, $elementTypeName>${dataField.nullable ? '?' : ''}, $elementTypeName>($accessor)';
    } else if (field.type.isTransferObject) {
      final decode =
          "${field.type.element!.name}TransferBean.toObject($accessor, name: '${field.name}')";
      if (field.type.nullabilitySuffix != NullabilitySuffix.none) {
        return '$accessor != null ? $decode : null';
      } else {
        return decode;
      }
    } else {
      return accessor;
    }
  }
}
