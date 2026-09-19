// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Sale with DataObject<Sale> {
  const $Sale();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Sale, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $region = DataField<Sale, String>(
    name: 'region',
    valueOf: (p) => p.region,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $quantity = DataField<Sale, int>(
    name: 'quantity',
    valueOf: (p) => p.quantity,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $price = DataField<Sale, double>(
    name: 'price',
    valueOf: (p) => p.price,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
  );

  static final DataBean<Sale> bean = DataBean<Sale>(
    name: 'Sale',
    fields: List<DataField<Sale, dynamic>>.unmodifiable([
      $id,
      $region,
      $quantity,
      $price,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Sale, dynamic>> get $$fields => bean.fields;
  Sale copyWith({int? id, String? region, int? quantity, double? price}) {
    final $data = this as Sale;
    return Sale(
      id: id ?? $data.id,
      region: region ?? $data.region,
      quantity: quantity ?? $data.quantity,
      price: price ?? $data.price,
    );
  }

  static Sale fromValues(Map<String, dynamic> data) {
    return Sale(
      id: data['id'] ?? 0,
      region: data['region'],
      quantity: data['quantity'],
      price: data['price'],
    );
  }

  static Sale fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Sale, data.runtimeType, name);
    }
    return Sale(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      region: $region.fromJson(
        data['region'],
        name: DataCodec.childName(name, 'region'),
      ),
      quantity: $quantity.fromJson(
        data['quantity'],
        name: DataCodec.childName(name, 'quantity'),
      ),
      price: $price.fromJson(
        data['price'],
        name: DataCodec.childName(name, 'price'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Sale;
    return {
      'id': $id.toJson($$data.id),
      'region': $region.toJson($$data.region),
      'quantity': $quantity.toJson($$data.quantity),
      'price': $price.toJson($$data.price),
    }..removeWhere((k, v) => v == null);
  }
}
