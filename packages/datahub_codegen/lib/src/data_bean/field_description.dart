import 'package:analyzer/dart/element/type.dart';

class FieldDescription {
  final String layoutName;
  final String name;
  final DartType dartType;
  final String typeName;
  final int length;
  final bool nullable;
  final bool isReactivePartition;

  FieldDescription({
    required this.layoutName,
    required this.name,
    required this.typeName,
    required this.length,
    required this.nullable,
    required this.dartType,
    required this.isReactivePartition,
  });
}

class PrimaryKeyFieldDescription extends FieldDescription {
  final bool autoIncrement;

  PrimaryKeyFieldDescription({
    required super.layoutName,
    required super.name,
    required super.typeName,
    required super.length,
    required super.nullable,
    required super.dartType,
    required super.isReactivePartition,
    required this.autoIncrement,
  });
}

class ForeignKeyFieldDescription extends FieldDescription {
  final FieldDescription foreignPrimaryKey;

  ForeignKeyFieldDescription({
    required super.layoutName,
    required super.name,
    required super.typeName,
    required super.length,
    required super.nullable,
    required super.dartType,
    required super.isReactivePartition,
    required this.foreignPrimaryKey,
  });
}
