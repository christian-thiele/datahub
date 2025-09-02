// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extra_equipment.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _ExtraEquipment with DataObject<ExtraEquipment> {
  const _ExtraEquipment();
  static final $general = DataField<ExtraEquipment, List<General>>(
    name: 'general',
    valueOf: (p) => p.general,
    meta: [
      const ApertureField(enumValues: const [
        General.handicappedSpaces,
        General.motorcycleSpaces,
        General.parentAndChildSpaces,
        General.womanSpaces,
        General.extraLargeSpaces,
        General.valetParking,
        General.longTermBooking,
        General.carSharing,
        General.carRental,
        General.carWash,
        General.bikeSharing
      ]),
    ],
  );

  static final $facility = DataField<ExtraEquipment, List<Facility>>(
    name: 'facility',
    valueOf: (p) => p.facility,
    meta: [
      const ApertureField(enumValues: const [
        Facility.chargingInfrastructure,
        Facility.toilet,
        Facility.elevator,
        Facility.loadingBay,
        Facility.bikeRacks,
        Facility.umbrella,
        Facility.wifi,
        Facility.issuesReceipts,
        Facility.studentArt
      ]),
    ],
  );

  static final $security = DataField<ExtraEquipment, List<Security>>(
    name: 'security',
    valueOf: (p) => p.security,
    meta: [
      const ApertureField(enumValues: const [
        Security.lit,
        Security.partiallyLit,
        Security.video,
        Security.personal,
        Security.saferParking,
        Security.secureParking,
        Security.gated,
        Security.flaps
      ]),
    ],
  );

  static final $payment = DataField<ExtraEquipment, List<Payment>>(
    name: 'payment',
    valueOf: (p) => p.payment,
    meta: [
      const ApertureField(enumValues: const [
        Payment.coins,
        Payment.notes,
        Payment.ec,
        Payment.creditCard,
        Payment.visa,
        Payment.mastercard,
        Payment.amex,
        Payment.maestro,
        Payment.cashCard,
        Payment.vCashCard,
        Payment.mobile,
        Payment.cards,
        Payment.eftpos,
        Payment.diners,
        Payment.discover,
        Payment.geldkarte,
        Payment.cheque,
        Payment.jcb,
        Payment.operatorCard,
        Payment.smartCard,
        Payment.telepeage,
        Payment.totalgr,
        Payment.moneo,
        Payment.flashpay,
        Payment.cepas,
        Payment.octopus,
        Payment.aliPay,
        Payment.wechatPay,
        Payment.easyCard,
        Payment.carteBleue,
        Payment.touchNGo
      ]),
    ],
  );

  static final DataBean<ExtraEquipment> bean = DataBean<ExtraEquipment>(
    name: 'ExtraEquipment',
    fields: List<DataField<ExtraEquipment, dynamic>>.unmodifiable([
      $general,
      $facility,
      $security,
      $payment,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ExtraEquipment, dynamic>> get $$fields => bean.fields;
  ExtraEquipment copyWith({
    List<General>? general,
    List<Facility>? facility,
    List<Security>? security,
    List<Payment>? payment,
  }) {
    final $data = this as ExtraEquipment;
    return ExtraEquipment(
      general: general ?? $data.general,
      facility: facility ?? $data.facility,
      security: security ?? $data.security,
      payment: payment ?? $data.payment,
    );
  }

  static ExtraEquipment fromValues(Map<String, dynamic> data) {
    return ExtraEquipment(
      general: data['general'],
      facility: data['facility'],
      security: data['security'],
      payment: data['payment'],
    );
  }

  static ExtraEquipment fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ExtraEquipment, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return ExtraEquipment(
      general: $codec.decodeList<General>(
          data['general'],
          (v, {String? name}) =>
              $codec.decodeEnum(v, General.values, name: name),
          name: DataCodec.childName(name, 'general')),
      facility: $codec.decodeList<Facility>(
          data['facility'],
          (v, {String? name}) =>
              $codec.decodeEnum(v, Facility.values, name: name),
          name: DataCodec.childName(name, 'facility')),
      security: $codec.decodeList<Security>(
          data['security'],
          (v, {String? name}) =>
              $codec.decodeEnum(v, Security.values, name: name),
          name: DataCodec.childName(name, 'security')),
      payment: $codec.decodeList<Payment>(
          data['payment'],
          (v, {String? name}) =>
              $codec.decodeEnum(v, Payment.values, name: name),
          name: DataCodec.childName(name, 'payment')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as ExtraEquipment;
    return {
      'general': $codec.encodeList<General>($data.general, $codec.encodeEnum),
      'facility':
          $codec.encodeList<Facility>($data.facility, $codec.encodeEnum),
      'security':
          $codec.encodeList<Security>($data.security, $codec.encodeEnum),
      'payment': $codec.encodeList<Payment>($data.payment, $codec.encodeEnum),
    }..removeWhere((k, v) => v == null);
  }
}
