import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:datahub/data.dart';
import 'package:source_gen/source_gen.dart';

ConstantReader? getMeta(FieldElement2 field) {
  final annotation = TypeChecker.typeNamed(Meta).firstAnnotationOf(field);
  if (annotation != null) {
    return ConstantReader(annotation);
  } else {
    return null;
  }
}

String? getDefaultValueExpression(FieldFormalParameterElement2 param) {
  if (param.hasDefaultValue) {
    return _dartLiteral(param.computeConstantValue()!);
  }

  return null;
}

String metaInvocation(DartObject annotation) {
  final name = annotation.type!.getDisplayString();
  final revived = ConstantReader(annotation).revive();

  final accessor = revived.accessor.isEmpty ? '' : '.${revived.accessor}';
  final posArgs = revived.positionalArguments.map(_dartLiteral).join(', ');
  final namedArgs = revived.namedArguments.entries
      .map((e) => '${e.key}: ${_dartLiteral(e.value)}')
      .join(', ');

  final args = [
    if (posArgs.isNotEmpty) posArgs,
    if (namedArgs.isNotEmpty) namedArgs,
  ].join(', ');

  return 'const $name$accessor($args)';
}

/// Convert a DartObject (constant) to valid Dart source.
/// Covers strings, nums, bools, null, lists, maps, enums, and Type literals.
String _dartLiteral(DartObject o) {
  final r = ConstantReader(o);

  if (r.isNull) return 'null';
  if (r.isString) return _stringLiteral(r.stringValue);
  if (r.isInt) return r.intValue.toString();
  if (r.isDouble) return r.doubleValue.toString();
  if (r.isBool) return r.boolValue.toString();

  if (r.isList) {
    final items = r.listValue.map(_dartLiteral).join(', ');
    return 'const [$items]';
  }

  if (r.isMap) {
    final entries = <String>[];
    for (final entry in r.mapValue.entries) {
      final k = _dartLiteral(entry.key!);
      final v = _dartLiteral(entry.value!);
      entries.add('$k: $v');
    }
    return 'const {${entries.join(', ')}}';
  }

  if (r.isType) {
    final t = o.toTypeValue()!;
    final name = t.getDisplayString();
    return name;
  }

  if (o.type != null && o.type!.element3 is EnumElement2) {
    return r.revive().accessor;
  }

  // Nested const objects (e.g., another annotation-like const)
  // Try to revive and print it similarly.
  final nested = r.revive();
  final typeName = o.type?.getDisplayString() ?? 'Object';
  final acc = nested.accessor.isEmpty ? '' : '.${nested.accessor}';
  final pos = nested.positionalArguments.map(_dartLiteral).join(', ');
  final named = nested.namedArguments.entries
      .map((e) => '${e.key}: ${_dartLiteral(e.value)}')
      .join(', ');
  final all = [
    if (pos.isNotEmpty) pos,
    if (named.isNotEmpty) named,
  ].join(', ');
  return 'const $typeName$acc($all)';
}

String _stringLiteral(String value) {
  // Basic safe escaping; for full generality you can expand this.
  final escaped = value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t');
  return "'$escaped'";
}
