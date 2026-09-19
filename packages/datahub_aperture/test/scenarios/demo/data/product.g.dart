// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Product with DataObject<Product> {
  const $Product();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Product, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? ''), name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $sku = DataField<Product, String>(
    name: 'sku',
    valueOf: (p) => p.sku,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(isDisplayField: true),
      const Meta(name: 'SKU'),
    ],
    constraints: [
      const RegExpConstraint<String?>(
        expression: '^[A-Z]{3}-[A-Z0-9]{2,6}-\\d{5}\$',
      ),
    ],
  );

  static final $title = DataField<Product, String>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [const MaxLengthConstraint<String?>(length: 120)],
  );

  static final $description = DataField<Product, String?>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const ApertureField(allowFilter: false, allowSort: false)],
    constraints: [const MaxLengthConstraint<String?>(length: 1000)],
  );

  static final $category = DataField<Product, ProductCategory>(
    name: 'category',
    valueOf: (p) => p.category,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, ProductCategory.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: ProductCategory.values)],
  );

  static final $price = DataField<Product, double>(
    name: 'price',
    valueOf: (p) => p.price,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [
      const ApertureField(isDisplayField: true),
      const Meta(description: 'Net price per unit, before discount.'),
    ],
    constraints: [const RangeConstraint<num?>(min: 0, max: 1000000)],
  );

  static final $unit = DataField<Product, PriceUnitType>(
    name: 'unit',
    valueOf: (p) => p.unit,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, PriceUnitType.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: PriceUnitType.values)],
  );

  static final $taxRate = DataField<Product, double>(
    name: 'taxRate',
    valueOf: (p) => p.taxRate,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble((value ?? 0.19), name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [
      const Meta(
        name: 'Tax rate',
        description: 'Fraction, e.g. 0.19 for 19 %.',
      ),
    ],
    constraints: [const RangeConstraint<num?>(min: 0, max: 0.3)],
  );

  static final $discount = DataField<Product, double>(
    name: 'discount',
    valueOf: (p) => p.discount,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble((value ?? 0.0), name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [
      const Meta(
        description: 'Negotiated discount as fraction, e.g. 0.1 for 10 %.',
      ),
    ],
    constraints: [const RangeConstraint<num?>(min: 0, max: 0.5)],
  );

  static final $validFrom = DataField<Product, DateTime>(
    name: 'validFrom',
    valueOf: (p) => p.validFrom,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [const Meta(name: 'Valid from')],
  );

  static final $validUntil = DataField<Product, DateTime?>(
    name: 'validUntil',
    valueOf: (p) => p.validUntil,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const Meta(name: 'Valid until')],
  );

  static final $clientId = DataField<Product, int>(
    name: 'clientId',
    valueOf: (p) => p.clientId,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [
      const Meta(name: 'Client'),
      const RelationId<Client>(),
    ],
  );

  static final $active = DataField<Product, bool>(
    name: 'active',
    valueOf: (p) => p.active,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? true), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final DataBean<Product> bean = DataBean<Product>(
    name: 'Product',
    fields: List<DataField<Product, dynamic>>.unmodifiable([
      $id,
      $sku,
      $title,
      $description,
      $category,
      $price,
      $unit,
      $taxRate,
      $discount,
      $validFrom,
      $validUntil,
      $clientId,
      $active,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(
        name: 'Price agreement',
        namePlural: 'Price agreements',
        description:
            'Client specific products and services with agreed prices.',
        icon: 58671,
      ),
      const ApertureMeta(titleTemplate: '{{ title }}'),
      const ApertureRelation<TimeEntry>(),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Product, dynamic>> get $$fields => bean.fields;
  Product copyWith({
    String? id,
    String? sku,
    String? title,
    String? description,
    bool nullDescription = false,
    ProductCategory? category,
    double? price,
    PriceUnitType? unit,
    double? taxRate,
    double? discount,
    DateTime? validFrom,
    DateTime? validUntil,
    bool nullValidUntil = false,
    int? clientId,
    bool? active,
  }) {
    final $data = this as Product;
    return Product(
      id: id ?? $data.id,
      sku: sku ?? $data.sku,
      title: title ?? $data.title,
      description: nullDescription ? null : (description ?? $data.description),
      category: category ?? $data.category,
      price: price ?? $data.price,
      unit: unit ?? $data.unit,
      taxRate: taxRate ?? $data.taxRate,
      discount: discount ?? $data.discount,
      validFrom: validFrom ?? $data.validFrom,
      validUntil: nullValidUntil ? null : (validUntil ?? $data.validUntil),
      clientId: clientId ?? $data.clientId,
      active: active ?? $data.active,
    );
  }

  static Product fromValues(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      sku: data['sku'],
      title: data['title'],
      description: data['description'],
      category: data['category'],
      price: data['price'],
      unit: data['unit'],
      taxRate: data['taxRate'] ?? 0.19,
      discount: data['discount'] ?? 0.0,
      validFrom: data['validFrom'],
      validUntil: data['validUntil'],
      clientId: data['clientId'],
      active: data['active'] ?? true,
    );
  }

  static Product fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Product, data.runtimeType, name);
    }
    return Product(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      sku: $sku.fromJson(data['sku'], name: DataCodec.childName(name, 'sku')),
      title: $title.fromJson(
        data['title'],
        name: DataCodec.childName(name, 'title'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      category: $category.fromJson(
        data['category'],
        name: DataCodec.childName(name, 'category'),
      ),
      price: $price.fromJson(
        data['price'],
        name: DataCodec.childName(name, 'price'),
      ),
      unit: $unit.fromJson(
        data['unit'],
        name: DataCodec.childName(name, 'unit'),
      ),
      taxRate: $taxRate.fromJson(
        data['taxRate'],
        name: DataCodec.childName(name, 'taxRate'),
      ),
      discount: $discount.fromJson(
        data['discount'],
        name: DataCodec.childName(name, 'discount'),
      ),
      validFrom: $validFrom.fromJson(
        data['validFrom'],
        name: DataCodec.childName(name, 'validFrom'),
      ),
      validUntil: $validUntil.fromJson(
        data['validUntil'],
        name: DataCodec.childName(name, 'validUntil'),
      ),
      clientId: $clientId.fromJson(
        data['clientId'],
        name: DataCodec.childName(name, 'clientId'),
      ),
      active: $active.fromJson(
        data['active'],
        name: DataCodec.childName(name, 'active'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Product;
    return {
      'id': $id.toJson($$data.id),
      'sku': $sku.toJson($$data.sku),
      'title': $title.toJson($$data.title),
      'description': $description.toJson($$data.description),
      'category': $category.toJson($$data.category),
      'price': $price.toJson($$data.price),
      'unit': $unit.toJson($$data.unit),
      'taxRate': $taxRate.toJson($$data.taxRate),
      'discount': $discount.toJson($$data.discount),
      'validFrom': $validFrom.toJson($$data.validFrom),
      'validUntil': $validUntil.toJson($$data.validUntil),
      'clientId': $clientId.toJson($$data.clientId),
      'active': $active.toJson($$data.active),
    }..removeWhere((k, v) => v == null);
  }
}
