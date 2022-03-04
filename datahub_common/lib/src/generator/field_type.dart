import 'package:analyzer/dart/element/type.dart';

import 'utils.dart';

abstract class FieldType {
  String get typeName;

  const FieldType();

  String buildEncodingStatement(String valueAccessor, bool nullable) {
    return 'encodeTyped<$typeName>($valueAccessor)';
  }

  String buildDecodingStatement(String valueAccessor, bool nullable) {
    final method = nullable ? 'decodeTypedNullable' : 'decodeTyped';
    return '$method<$typeName>($valueAccessor)';
  }

  factory FieldType.fromDartType(DartType type) {
    if (type.isDartCoreString) {
      return StringFieldType();
    } else if (type.isDartCoreInt) {
      return IntFieldType();
    } else if (type.isDartCoreDouble) {
      return DoubleFieldType();
    } else if (type.isDartCoreBool) {
      return BoolFieldType();
    } else if (type.isDartCoreDateTime) {
      return DateTimeFieldType();
    } else if (type.isUint8List) {
      return ByteFieldType();
    } else if (type.isDartCoreList) {
      final arg = (type as ParameterizedType).typeArguments.first;
      return ListFieldType(FieldType.fromDartType(arg));
    } else if (type.isDartCoreMap) {
      final args = (type as ParameterizedType).typeArguments;
      if (!args.first.isDartCoreString) {
        throw Exception(
            'Only String keys are supported when using Map in Transfer Object.');
      }
      return MapFieldType(
        FieldType.fromDartType(args.elementAt(1)),
      );
    } else if (type.isTransferObject) {
      return ObjectFieldType(type.element!.name!);
    } else if (type.isEnum) {
      return EnumFieldType(type.element!.name!);
    } else {
      throw Exception('Invalid field type ${type.element?.name}.');
    }
  }
}

class StringFieldType extends FieldType {
  const StringFieldType();

  @override
  final typeName = 'String';
}

class IntFieldType extends FieldType {
  const IntFieldType();

  @override
  final typeName = 'int';
}

class DoubleFieldType extends FieldType {
  const DoubleFieldType();

  @override
  final typeName = 'double';
}

class BoolFieldType extends FieldType {
  const BoolFieldType();

  @override
  final typeName = 'bool';
}

class DateTimeFieldType extends FieldType {
  const DateTimeFieldType();

  @override
  final typeName = 'DateTime';
}

class ByteFieldType extends FieldType {
  const ByteFieldType();

  @override
  final typeName = 'Uint8List';
}

class ListFieldType extends FieldType {
  final FieldType elementType;

  @override
  String get typeName => 'List<${elementType.typeName}>';

  const ListFieldType(this.elementType);

  @override
  String buildEncodingStatement(String valueAccessor, bool nullable) {
    const lambdaParam = 'e';
    final encoder =
        '($lambdaParam) => ${elementType.buildEncodingStatement(lambdaParam, false)}';
    return 'encodeList<${elementType.typeName}>($valueAccessor, $encoder)';
  }

  @override
  String buildDecodingStatement(String valueAccessor, bool nullable) {
    const lambdaParam = 'e';
    final decoder =
        '($lambdaParam) => ${elementType.buildDecodingStatement(lambdaParam, false)}';
    return 'decodeList<${elementType.typeName}>($valueAccessor, $decoder)';
  }
}

class MapFieldType extends FieldType {
  final FieldType valueType;

  const MapFieldType(this.valueType);

  @override
  String get typeName => 'Map<String, ${valueType.typeName}>';

  @override
  String buildEncodingStatement(String valueAccessor, bool nullable) {
    const lambdaParam = 'e';
    final encoder =
        '($lambdaParam) => ${valueType.buildEncodingStatement(lambdaParam, nullable)}';
    return 'encodeStringMap<${valueType.typeName}>($valueAccessor, $encoder)';
  }

  @override
  String buildDecodingStatement(String valueAccessor, bool nullable) {
    const lambdaParam = 'e';
    final decoder =
        '($lambdaParam) => ${valueType.buildDecodingStatement(lambdaParam, nullable)}';
    return 'decodeStringMap<${valueType.typeName}>($valueAccessor, $decoder)';
  }
}

class ObjectFieldType extends FieldType {
  @override
  final typeName;

  ObjectFieldType(this.typeName);

  @override
  String buildEncodingStatement(String valueAccessor, bool nullable) {
    if (nullable) {
      return '(($valueAccessor) != null) ? ${typeName}TransferBean.staticToMap($valueAccessor!) : null';
    }

    return '${typeName}TransferBean.staticToMap($valueAccessor)';
  }

  @override
  String buildDecodingStatement(String valueAccessor, bool nullable) {
    final decode = '${typeName}TransferBean.staticToObject($valueAccessor)';

    if (nullable) {
      return '(($valueAccessor) != null) ? $decode : null';
    }

    return decode;
  }
}

class EnumFieldType extends FieldType {
  @override
  final String typeName;

  EnumFieldType(this.typeName);

  @override
  String buildEncodingStatement(String valueAccessor, bool nullable) {
    if (nullable) {
      return 'encodeEnumNullable($valueAccessor)';
    }

    return 'encodeEnum($valueAccessor)';
  }

  @override
  String buildDecodingStatement(String valueAccessor, bool nullable) {
    if (nullable) {
      return 'decodeEnumNullable($valueAccessor, $typeName.values)';
    }

    return 'decodeEnum($valueAccessor, $typeName.values)';
  }
}
