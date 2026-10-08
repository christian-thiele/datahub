// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renew_price_agreement.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $RenewPriceAgreement
    with DataObject<RenewPriceAgreement> {
  const $RenewPriceAgreement();
  static const $$codec = JsonDataCodec();
  static final $validFrom = DataField<RenewPriceAgreement, DateTime>(
    name: 'validFrom',
    valueOf: (p) => p.validFrom,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [
      const Meta(
        name: 'Valid from',
        description: 'The current agreement ends when the new one starts.',
      ),
    ],
  );

  static final $price = DataField<RenewPriceAgreement, double>(
    name: 'price',
    valueOf: (p) => p.price,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [const Meta(description: 'Net price per unit of the new agreement.')],
    constraints: [const RangeConstraint<num?>(min: 0, max: 1000000)],
  );

  static final DataBean<RenewPriceAgreement> bean =
      DataBean<RenewPriceAgreement>(
        name: 'RenewPriceAgreement',
        fields: List<DataField<RenewPriceAgreement, dynamic>>.unmodifiable([
          $validFrom,
          $price,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
        meta: [const Meta(name: 'Renew price agreement', icon: 57537)],
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<RenewPriceAgreement, dynamic>> get $$fields => bean.fields;
  RenewPriceAgreement copyWith({DateTime? validFrom, double? price}) {
    final $data = this as RenewPriceAgreement;
    return RenewPriceAgreement(
      validFrom: validFrom ?? $data.validFrom,
      price: price ?? $data.price,
    );
  }

  static RenewPriceAgreement fromValues(Map<String, dynamic> data) {
    return RenewPriceAgreement(
      validFrom: data['validFrom'],
      price: data['price'],
    );
  }

  static RenewPriceAgreement fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        RenewPriceAgreement,
        data.runtimeType,
        name,
      );
    }
    return RenewPriceAgreement(
      validFrom: $validFrom.fromJson(
        data['validFrom'],
        name: DataCodec.childName(name, 'validFrom'),
      ),
      price: $price.fromJson(
        data['price'],
        name: DataCodec.childName(name, 'price'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as RenewPriceAgreement;
    return {
      'validFrom': $validFrom.toJson($$data.validFrom),
      'price': $price.toJson($$data.price),
    }..removeWhere((k, v) => v == null);
  }
}
