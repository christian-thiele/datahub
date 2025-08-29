import 'package:analyzer/dart/element/element.dart';
import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_codegen/src/data_bean/field_description.dart';

import 'data_bean_field.dart';

class DataSuperclassBuilder {
  final String layoutClass;
  final NamingConvention convention;
  final List<Tuple<FieldElement, ParameterElement>> daoFields;

  DataSuperclassBuilder(this.layoutClass, this.daoFields, this.convention);

  Iterable<String> build() sync* {
    final fields =
        daoFields.map((e) => _toDataBeanField(e, convention)).toList();
    final primaryKeyField = fields
        .firstOrNullWhere((f) => f.dataField is PrimaryKeyFieldDescription);
    final primaryKeyClass = primaryKeyField?.field.type.element?.name;

    final baseClass = primaryKeyClass != null
        ? 'PrimaryKeyDao<$layoutClass, $primaryKeyClass>'
        : 'BaseDao<$layoutClass>';

    yield 'abstract class _Dao extends $baseClass {';
    yield '@override _${layoutClass}DataBeanImpl get bean => ${layoutClass}DataBean;';
    if (primaryKeyClass != null) {
      yield* buildGetPrimaryKeyMethod(primaryKeyField!);
      yield* buildCopyWithPrimaryKeyMethod(primaryKeyField);
    }
    yield '}';
  }

  Iterable<String> buildGetPrimaryKeyMethod(
      DataBeanField primaryKeyField) sync* {
    final primaryKeyClass = primaryKeyField.field.type.element!.name;
    yield '@override $primaryKeyClass getPrimaryKey() => '
        '(this as $layoutClass).${primaryKeyField.field.name};';
  }

  Iterable<String> buildCopyWithPrimaryKeyMethod(
      DataBeanField primaryKeyField) sync* {
    final primaryKeyClass = primaryKeyField.field.type.element!.name;
    yield '@override $layoutClass copyWithPrimaryKey($primaryKeyClass value) => '
        '(this as $layoutClass).copyWith(${primaryKeyField.field.name}: value);';
  }
}

DataBeanField _toDataBeanField(
        Tuple<FieldElement, ParameterElement> e, NamingConvention convention) =>
    DataBeanField.fromElements(e.a, e.b, convention);
