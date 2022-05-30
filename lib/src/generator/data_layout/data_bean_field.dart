import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/persistence.dart';
import 'package:cl_datahub/src/generator/utils.dart';
import 'package:source_gen/source_gen.dart';

import 'data_bean_exception.dart';

class DataBeanField {
  final FieldElement field;
  final ParameterElement parameter;
  final DataField dataField;
  final String? foreignFieldAccessor;

  DataBeanField(
      this.field, this.parameter, this.dataField, this.foreignFieldAccessor);

  DataBeanField.fromElements(this.field, this.parameter)
      : dataField = getDataField(field),
        foreignFieldAccessor = getForeignFieldAccessor(field);

  static DataField getDataField(FieldElement field) {
    final fieldName = getColumnName(field);
    final fieldType = getColumnType(field);
    final fieldLength = getLength(field);
    final fieldNullable = getNullability(field);
    final layoutName = getLayoutName(field.enclosingElement as ClassElement);

    if (isPrimaryKeyField(field)) {
      if (fieldType != FieldType.Int && fieldType != FieldType.String) {
        throw DataBeanException(
            'Invalid field type for primary key field: $fieldType');
      }

      if (fieldNullable) {
        throw DataBeanException('Primary key field $fieldType is nullable.');
      }

      return PrimaryKey(
        fieldType,
        layoutName,
        fieldName,
        length: fieldLength,
        autoIncrement: fieldType == FieldType.Int && isAutoIncrement(field),
      );
    } else if (isForeignKeyField(field)) {
      final foreignPrimary = getForeignPrimaryKey(field);
      if (fieldType != foreignPrimary.type) {
        throw DataBeanException(
            'Foreign key field "$fieldName" does not match type of foreign primary key.');
      }
      return ForeignKey(
        foreignPrimary,
        layoutName,
        fieldName,
        nullable: fieldNullable,
      );
    } else {
      return DataField(
        fieldType,
        layoutName,
        fieldName,
        length: fieldLength,
        nullable: fieldNullable,
      );
    }
  }

  static FieldType getColumnType(FieldElement field) {
    final fieldType = field.type;
    if (fieldType.isDartCoreString) {
      return FieldType.String;
    } else if (fieldType.isDartCoreInt) {
      return FieldType.Int;
    } else if (fieldType.isDartCoreDouble) {
      return FieldType.Float;
    } else if (fieldType.isDartCoreBool) {
      return FieldType.Bool;
    } else if (fieldType.isDartCoreDateTime) {
      return FieldType.DateTime;
    } else if (fieldType.isUint8List) {
      return FieldType.Bytes;
    } else if (TypeChecker.fromRuntime(Point).isExactlyType(fieldType)) {
      return FieldType.Point;
    } else if (fieldType.isJsonType) {
      return FieldType.Json;
    } else {
      throw DataBeanException.invalidType(fieldType);
    }
  }

  static String getColumnName(FieldElement field) {
    final annotation = getAnnotation(field, DaoField);
    return readField<String>(annotation, 'name') ?? field.name;
  }

  static bool getNullability(FieldElement field) {
    return field.type.nullabilitySuffix != NullabilitySuffix.none;
  }

  static int getLength(FieldElement field) {
    final annotation = getAnnotation(field, DaoField);
    return readField<int>(annotation, 'length') ??
        DataField.getDefaultLength(getColumnType(field));
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
      return readField<bool>(annotation, 'autoIncrement')!;
    }
    return false;
  }

  static PrimaryKey getForeignPrimaryKey(FieldElement field) {
    final annotation = getAnnotation(field, ForeignKeyDaoField) ??
        (throw Exception('Not a foreign key field.'));
    final foreignType = readTypeField(annotation, 'foreignType')!;
    final fieldElement = findPrimaryKeyField(
            podoFields(foreignType.element as ClassElement).a.toList()) ??
        (throw DataBeanException(
            'DAO "${foreignType.element?.name}" does not provide a primary key.'));
    return getDataField(fieldElement) as PrimaryKey;
  }

  // this is kind of a hacky workaround
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
    return '${foreignClassElement.name}DataBean.${fieldElement.name}Field';
  }
}
