import 'package:datahub/datahub.dart';

part 'header_object.g.dart';

@Data()
class HeaderObject extends $HeaderObject {
  final String? description;
  final String type;
  final String? format;
  final Map<String, dynamic>? items;
  final String? collectionFormat;
  @JsonKey('default')
  final dynamic defaultValue;
  final double? maximum;
  final bool? exclusiveMaximum;
  final double? minimum;
  final bool? exclusiveMinimum;
  final int? maxLength;
  final int? minLength;
  final String? pattern;
  final int? maxItems;
  final int? minItems;
  final bool? uniqueItems;
  @JsonKey('enum')
  final List<dynamic>? enumValues;
  final double? multipleOf;

  const HeaderObject({
    this.description,
    required this.type,
    this.format,
    this.items,
    this.collectionFormat,
    this.defaultValue,
    this.maximum,
    this.exclusiveMaximum,
    this.minimum,
    this.exclusiveMinimum,
    this.maxLength,
    this.minLength,
    this.pattern,
    this.maxItems,
    this.minItems,
    this.uniqueItems,
    this.enumValues,
    this.multipleOf,
  });
}
