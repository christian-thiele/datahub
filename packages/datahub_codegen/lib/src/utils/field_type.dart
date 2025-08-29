import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import 'utils.dart';

abstract class TransferFieldType {
  final bool nullable;

  String get typeName;

  String get typeNameNullability => typeName + (nullable ? '?' : '');

  const TransferFieldType(this.nullable);

  String buildEncodingStatement(String valueAccessor) {
    return 'encodeTyped<$typeNameNullability>($valueAccessor)';
  }

  String buildDecodingStatement(String valueAccessor, String nameAccessor) {
    return 'decodeTyped<$typeNameNullability>($valueAccessor, name: $nameAccessor)';
  }

  factory TransferFieldType.fromDartType(DartType type) {
    final nullable = type.nullabilitySuffix != NullabilitySuffix.none;
    if (type is DynamicType) {
      return DynamicFieldType();
    } else if (type.isDartCoreString) {
      return StringFieldType(nullable);
    } else if (type.isDartCoreInt) {
      return IntFieldType(nullable);
    } else if (type.isDartCoreDouble) {
      return DoubleFieldType(nullable);
    } else if (type.isDartCoreBool) {
      return BoolFieldType(nullable);
    } else if (type.isDartCoreDateTime) {
      return DateTimeFieldType(nullable);
    } else if (type.isDartCoreDuration) {
      return DurationFieldType(nullable);
    } else if (type.isUint8List) {
      return ByteFieldType(nullable);
    } else if (type.isDartCoreList) {
      final arg = (type as ParameterizedType).typeArguments.first;
      return ListFieldType(TransferFieldType.fromDartType(arg), nullable);
    } else if (type.isDartCoreMap) {
      final args = (type as ParameterizedType).typeArguments;
      if (!args.first.isDartCoreString) {
        throw Exception(
            'Only String keys are supported when using Map in Transfer Object.');
      }
      return MapFieldType(
          TransferFieldType.fromDartType(args.elementAt(1)), nullable);
    } else if (type.isTransferObject) {
      return ObjectFieldType(type.element!.name!, nullable);
    } else if (type.isEnum) {
      return EnumFieldType(type.element!.name!, nullable);
    } else {
      throw Exception('Invalid field type ${type.element?.name}.');
    }
  }
}

class DynamicFieldType extends TransferFieldType {
  const DynamicFieldType() : super(false);

  @override
  final typeName = 'dynamic';
}

class StringFieldType extends TransferFieldType {
  const StringFieldType(super.nullable);

  @override
  final typeName = 'String';
}

class IntFieldType extends TransferFieldType {
  const IntFieldType(super.nullable);

  @override
  final typeName = 'int';
}

class DoubleFieldType extends TransferFieldType {
  const DoubleFieldType(super.nullable);

  @override
  final typeName = 'double';
}

class BoolFieldType extends TransferFieldType {
  const BoolFieldType(super.nullable);

  @override
  final typeName = 'bool';
}

class DateTimeFieldType extends TransferFieldType {
  const DateTimeFieldType(super.nullable);

  @override
  final typeName = 'DateTime';
}

class DurationFieldType extends TransferFieldType {
  const DurationFieldType(super.nullable);

  @override
  final typeName = 'Duration';
}

class ByteFieldType extends TransferFieldType {
  const ByteFieldType(super.nullable);

  @override
  final typeName = 'Uint8List';
}

class ListFieldType extends TransferFieldType {
  final TransferFieldType elementType;

  @override
  String get typeName => 'List<${elementType.typeNameNullability}>';

  const ListFieldType(this.elementType, super.nullable);

  @override
  String buildEncodingStatement(String valueAccessor) {
    if (elementType is ObjectFieldType || elementType is EnumFieldType) {
      final encodingStatement = elementType.buildEncodingStatement('v');
      return 'encodeList<$typeNameNullability, ${elementType.typeNameNullability}>($valueAccessor, (v) => $encodingStatement)';
    } else {
      return 'encodeListTyped<$typeNameNullability, ${elementType.typeNameNullability}>($valueAccessor)';
    }
  }

  @override
  String buildDecodingStatement(String valueAccessor, String nameAccessor) {
    if (elementType is ObjectFieldType || elementType is EnumFieldType) {
      final decodingStatement = elementType.buildDecodingStatement('v', 'n');
      return 'decodeList<$typeNameNullability, ${elementType.typeNameNullability}>($valueAccessor, (v, n) => $decodingStatement, name: $nameAccessor)';
    } else {
      return 'decodeListTyped<$typeNameNullability, ${elementType.typeNameNullability}>($valueAccessor, name: $nameAccessor)';
    }
  }
}

class MapFieldType extends TransferFieldType {
  final TransferFieldType valueType;

  const MapFieldType(this.valueType, super.nullable);

  @override
  String get typeName => 'Map<String, ${valueType.typeName}>';

  @override
  String buildEncodingStatement(String valueAccessor) {
    if (valueType is ObjectFieldType) {
      final encodingStatement = valueType.buildEncodingStatement('v');
      return 'encodeMap<$typeNameNullability, ${valueType.typeNameNullability}>($valueAccessor, (v) => $encodingStatement)';
    } else {
      return 'encodeMapTyped<$typeNameNullability, ${valueType.typeNameNullability}>($valueAccessor)';
    }
  }

  @override
  String buildDecodingStatement(String valueAccessor, String nameAccessor) {
    if (valueType is ObjectFieldType) {
      final decodingStatement = valueType.buildDecodingStatement('v', 'n');
      return 'decodeList<$typeNameNullability, ${valueType.typeNameNullability}>($valueAccessor, (v, n) => $decodingStatement, name: $nameAccessor)';
    } else {
      return 'decodeMapTyped<$typeNameNullability, ${valueType.typeNameNullability}>($valueAccessor, name: $nameAccessor)';
    }
  }
}

class ObjectFieldType extends TransferFieldType {
  @override
  final String typeName;

  ObjectFieldType(this.typeName, super.nullable);

  @override
  String buildEncodingStatement(String valueAccessor) {
    return nullable ? '$valueAccessor?.toJson()' : '$valueAccessor.toJson()';
  }

  @override
  String buildDecodingStatement(String valueAccessor, String nameAccessor) {
    final decode =
        '${typeName}TransferBean.toObject($valueAccessor, name: $nameAccessor)';

    if (nullable) {
      return '(($valueAccessor) != null) ? $decode : null';
    }

    return decode;
  }
}

class EnumFieldType extends TransferFieldType {
  @override
  final String typeName;

  EnumFieldType(this.typeName, super.nullable);

  @override
  String buildEncodingStatement(String valueAccessor) {
    if (nullable) {
      return '$valueAccessor?.name';
    }

    return '$valueAccessor.name';
  }

  @override
  String buildDecodingStatement(String valueAccessor, String nameAccessor) {
    if (nullable) {
      return 'decodeEnumNullable($valueAccessor, $typeName.values, name: $nameAccessor)';
    }

    return 'decodeEnum($valueAccessor, $typeName.values, name: $nameAccessor)';
  }
}
