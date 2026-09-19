// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mark_invoice_paid.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $MarkInvoicePaid with DataObject<MarkInvoicePaid> {
  const $MarkInvoicePaid();
  static const $$codec = JsonDataCodec();
  static final $paidAt = DataField<MarkInvoicePaid, DateTime>(
    name: 'paidAt',
    valueOf: (p) => p.paidAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [const Meta(name: 'Payment received')],
  );

  static final $paymentReference = DataField<MarkInvoicePaid, String?>(
    name: 'paymentReference',
    valueOf: (p) => p.paymentReference,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [
      const Meta(
        name: 'Payment reference',
        description: 'Bank transfer reference, if available.',
      ),
    ],
  );

  static final DataBean<MarkInvoicePaid> bean = DataBean<MarkInvoicePaid>(
    name: 'MarkInvoicePaid',
    fields: List<DataField<MarkInvoicePaid, dynamic>>.unmodifiable([
      $paidAt,
      $paymentReference,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [const Meta(name: 'Mark as paid', icon: 58498)],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<MarkInvoicePaid, dynamic>> get $$fields => bean.fields;
  MarkInvoicePaid copyWith({
    DateTime? paidAt,
    String? paymentReference,
    bool nullPaymentReference = false,
  }) {
    final $data = this as MarkInvoicePaid;
    return MarkInvoicePaid(
      paidAt: paidAt ?? $data.paidAt,
      paymentReference: nullPaymentReference
          ? null
          : (paymentReference ?? $data.paymentReference),
    );
  }

  static MarkInvoicePaid fromValues(Map<String, dynamic> data) {
    return MarkInvoicePaid(
      paidAt: data['paidAt'],
      paymentReference: data['paymentReference'],
    );
  }

  static MarkInvoicePaid fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        MarkInvoicePaid,
        data.runtimeType,
        name,
      );
    }
    return MarkInvoicePaid(
      paidAt: $paidAt.fromJson(
        data['paidAt'],
        name: DataCodec.childName(name, 'paidAt'),
      ),
      paymentReference: $paymentReference.fromJson(
        data['paymentReference'],
        name: DataCodec.childName(name, 'paymentReference'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as MarkInvoicePaid;
    return {
      'paidAt': $paidAt.toJson($$data.paidAt),
      'paymentReference': $paymentReference.toJson($$data.paymentReference),
    }..removeWhere((k, v) => v == null);
  }
}
