// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_line.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $InvoiceLine with DataObject<InvoiceLine> {
  const $InvoiceLine();
  static const $$codec = JsonDataCodec();
  static final $position = DataField<InvoiceLine, int>(
    name: 'position',
    valueOf: (p) => p.position,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Meta(name: 'Pos.')],
  );

  static final $description = DataField<InvoiceLine, String>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $sku = DataField<InvoiceLine, String?>(
    name: 'sku',
    valueOf: (p) => p.sku,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const Meta(name: 'SKU')],
  );

  static final $quantity = DataField<InvoiceLine, double>(
    name: 'quantity',
    valueOf: (p) => p.quantity,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
  );

  static final $unit = DataField<InvoiceLine, PriceUnitType>(
    name: 'unit',
    valueOf: (p) => p.unit,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, PriceUnitType.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: PriceUnitType.values)],
  );

  static final $unitPrice = DataField<InvoiceLine, double>(
    name: 'unitPrice',
    valueOf: (p) => p.unitPrice,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [const Meta(name: 'Unit price')],
  );

  static final $discount = DataField<InvoiceLine, double>(
    name: 'discount',
    valueOf: (p) => p.discount,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble((value ?? 0.0), name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    constraints: [const RangeConstraint<num?>(min: 0, max: 1)],
  );

  static final $taxRate = DataField<InvoiceLine, double>(
    name: 'taxRate',
    valueOf: (p) => p.taxRate,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [const Meta(name: 'Tax rate')],
    constraints: [const RangeConstraint<num?>(min: 0, max: 0.3)],
  );

  static final DataBean<InvoiceLine> bean = DataBean<InvoiceLine>(
    name: 'InvoiceLine',
    fields: List<DataField<InvoiceLine, dynamic>>.unmodifiable([
      $position,
      $description,
      $sku,
      $quantity,
      $unit,
      $unitPrice,
      $discount,
      $taxRate,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<InvoiceLine, dynamic>> get $$fields => bean.fields;
  InvoiceLine copyWith({
    int? position,
    String? description,
    String? sku,
    bool nullSku = false,
    double? quantity,
    PriceUnitType? unit,
    double? unitPrice,
    double? discount,
    double? taxRate,
  }) {
    final $data = this as InvoiceLine;
    return InvoiceLine(
      position: position ?? $data.position,
      description: description ?? $data.description,
      sku: nullSku ? null : (sku ?? $data.sku),
      quantity: quantity ?? $data.quantity,
      unit: unit ?? $data.unit,
      unitPrice: unitPrice ?? $data.unitPrice,
      discount: discount ?? $data.discount,
      taxRate: taxRate ?? $data.taxRate,
    );
  }

  static InvoiceLine fromValues(Map<String, dynamic> data) {
    return InvoiceLine(
      position: data['position'],
      description: data['description'],
      sku: data['sku'],
      quantity: data['quantity'],
      unit: data['unit'],
      unitPrice: data['unitPrice'],
      discount: data['discount'] ?? 0.0,
      taxRate: data['taxRate'],
    );
  }

  static InvoiceLine fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(InvoiceLine, data.runtimeType, name);
    }
    return InvoiceLine(
      position: $position.fromJson(
        data['position'],
        name: DataCodec.childName(name, 'position'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      sku: $sku.fromJson(data['sku'], name: DataCodec.childName(name, 'sku')),
      quantity: $quantity.fromJson(
        data['quantity'],
        name: DataCodec.childName(name, 'quantity'),
      ),
      unit: $unit.fromJson(
        data['unit'],
        name: DataCodec.childName(name, 'unit'),
      ),
      unitPrice: $unitPrice.fromJson(
        data['unitPrice'],
        name: DataCodec.childName(name, 'unitPrice'),
      ),
      discount: $discount.fromJson(
        data['discount'],
        name: DataCodec.childName(name, 'discount'),
      ),
      taxRate: $taxRate.fromJson(
        data['taxRate'],
        name: DataCodec.childName(name, 'taxRate'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as InvoiceLine;
    return {
      'position': $position.toJson($$data.position),
      'description': $description.toJson($$data.description),
      'sku': $sku.toJson($$data.sku),
      'quantity': $quantity.toJson($$data.quantity),
      'unit': $unit.toJson($$data.unit),
      'unitPrice': $unitPrice.toJson($$data.unitPrice),
      'discount': $discount.toJson($$data.discount),
      'taxRate': $taxRate.toJson($$data.taxRate),
    }..removeWhere((k, v) => v == null);
  }
}
