import 'package:analyzer/dart/element/element.dart';
import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

import 'package:datahub_codegen/src/data_bean/field_description.dart';

import 'data_bean_field.dart';

class DataBeanBuilder {
  final String layoutClass;
  final String layoutName;
  final NamingConvention namingConvention;
  final List<Tuple<FieldElement, ParameterElement>> daoFields;

  DataBeanBuilder(
    this.layoutClass,
    this.layoutName,
    this.daoFields,
    this.namingConvention,
  );

  Iterable<String> build() sync* {
    yield '// ignore_for_file: non_constant_identifier_names';
    final fields =
        daoFields.map((e) => _toDataBeanField(e, namingConvention)).toList();

    final primaryKeyField = fields
        .firstOrNullWhere((f) => f.dataField is PrimaryKeyFieldDescription);
    final primaryKeyClass = primaryKeyField?.field.type.element?.name;

    final baseClass = primaryKeyClass != null
        ? 'PrimaryKeyDataBean<$layoutClass, $primaryKeyClass>'
        : 'DataBean<$layoutClass>';

    yield 'final ${layoutClass}DataBean = _${layoutClass}DataBeanImpl._();';
    yield 'class _${layoutClass}DataBeanImpl extends $baseClass {';

    yield "@override final layoutName = '$layoutName';";
    if (primaryKeyField != null) {
      yield '@override PrimaryKey get primaryKey => ${primaryKeyField.field.name};';
    }

    yield* buildConstConstructor();
    yield* buildFieldsAccessors(fields);
    yield* buildUnmapMethod(fields);
    yield* buildMapValuesMethod(fields);
    yield '}';
  }

  Iterable<String> buildConstConstructor() sync* {
    yield '_${layoutClass}DataBeanImpl._();';
  }

  Iterable<String> buildUnmapMethod(List<DataBeanField> fields) sync* {
    final objectName = 'dao';
    yield '@override Map<DataField, dynamic> unmap($layoutClass $objectName, '
        '{bool includePrimaryKey = false}) { return {';
    for (final field in fields) {
      if (field.dataField is PrimaryKeyFieldDescription) {
        yield 'if (includePrimaryKey)';
      }
      yield "${field.field.name}: ${field.getEncodingStatement('$objectName.${field.valueAccessor}')},";
    }
    yield '}; }';
  }

  Iterable<String> buildMapValuesMethod(List<DataBeanField> fields) sync* {
    final objectName = 'data';
    yield '@override $layoutClass mapValues(Map<String, dynamic> $objectName) {';
    yield 'return $layoutClass(';
    for (final field in fields) {
      final decodingStatement = field.getDecodingStatement(objectName);
      if (field.parameter.isNamed) {
        yield '${field.parameter.name}: $decodingStatement,';
      } else {
        yield '$decodingStatement,';
      }
    }
    yield '); }';
  }

  DataBeanField _toDataBeanField(Tuple<FieldElement, ParameterElement> e,
          NamingConvention convention) =>
      DataBeanField.fromElements(e.a, e.b, convention);

  Iterable<String> buildFieldsAccessors(List<DataBeanField> fields) sync* {
    for (final field in fields) {
      final initializer = _buildInitializer(field);
      yield 'final ${field.field.name} = $initializer;';
    }

    yield '@override late final fields = [';
    for (final field in fields) {
      yield '${field.field.name},';
    }
    yield '];';

    yield '@override late final reactivePartitions = [';
    for (final field in fields.where((e) =>
        DataBeanField.isPrimaryKeyField(e.field) ||
        e.dataField.isReactivePartition)) {
      yield '${field.field.name},';
    }
    yield '];';
  }

  String _buildInitializer(DataBeanField beanField) {
    final dataField = beanField.dataField;
    if (dataField is PrimaryKeyFieldDescription) {
      return "PrimaryKey<${dataField.typeName}>(layoutName: '${dataField.layoutName}', name: '${dataField.name}', length: ${dataField.length}, autoIncrement: ${dataField.autoIncrement},)";
    } else if (dataField is ForeignKeyFieldDescription) {
      if (beanField.foreignFieldAccessor == null) {
        throw Exception(
            'ForeignFieldAccessor == null, this is likely a bug in the data_bean_generator code!');
      }
      return "ForeignKey<${dataField.typeName}>(foreignPrimaryKey: ${beanField.foreignFieldAccessor}, layoutName: '${dataField.layoutName}', name: '${dataField.name}', "
          'nullable: ${dataField.nullable},)';
    } else {
      return "DataField<${dataField.typeName}>(layoutName: '${dataField.layoutName}', name: '${dataField.name}', "
          'nullable: ${dataField.nullable}, length: ${dataField.length},)';
    }
  }
}
