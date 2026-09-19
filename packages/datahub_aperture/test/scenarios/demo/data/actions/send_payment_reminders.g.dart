// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_payment_reminders.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $SendPaymentReminders
    with DataObject<SendPaymentReminders> {
  const $SendPaymentReminders();
  static const $$codec = JsonDataCodec();
  static final $minDaysOverdue = DataField<SendPaymentReminders, int>(
    name: 'minDaysOverdue',
    valueOf: (p) => p.minDaysOverdue,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 7), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [
      const Meta(
        name: 'Minimum days overdue',
        description: 'Only remind invoices that are at least this late.',
      ),
    ],
    constraints: [const RangeConstraint<num?>(min: 0, max: 365)],
  );

  static final DataBean<SendPaymentReminders> bean =
      DataBean<SendPaymentReminders>(
        name: 'SendPaymentReminders',
        fields: List<DataField<SendPaymentReminders, dynamic>>.unmodifiable([
          $minDaysOverdue,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
        meta: [const Meta(name: 'Send payment reminders', icon: 58448)],
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<SendPaymentReminders, dynamic>> get $$fields => bean.fields;
  SendPaymentReminders copyWith({int? minDaysOverdue}) {
    final $data = this as SendPaymentReminders;
    return SendPaymentReminders(
      minDaysOverdue: minDaysOverdue ?? $data.minDaysOverdue,
    );
  }

  static SendPaymentReminders fromValues(Map<String, dynamic> data) {
    return SendPaymentReminders(minDaysOverdue: data['minDaysOverdue'] ?? 7);
  }

  static SendPaymentReminders fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        SendPaymentReminders,
        data.runtimeType,
        name,
      );
    }
    return SendPaymentReminders(
      minDaysOverdue: $minDaysOverdue.fromJson(
        data['minDaysOverdue'],
        name: DataCodec.childName(name, 'minDaysOverdue'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as SendPaymentReminders;
    return {'minDaysOverdue': $minDaysOverdue.toJson($$data.minDaysOverdue)}
      ..removeWhere((k, v) => v == null);
  }
}
