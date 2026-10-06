// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_test.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Position with DataObject<Position> {
  const $Position();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Position, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? ''), name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $userId = DataField<Position, String>(
    name: 'userId',
    valueOf: (p) => p.userId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $amount = DataField<Position, int>(
    name: 'amount',
    valueOf: (p) => p.amount,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $date = DataField<Position, DateTime>(
    name: 'date',
    valueOf: (p) => p.date,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $invoiceId = DataField<Position, String?>(
    name: 'invoiceId',
    valueOf: (p) => p.invoiceId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<Position> bean = DataBean<Position>(
    name: 'Position',
    fields: List<DataField<Position, dynamic>>.unmodifiable([
      $id,
      $userId,
      $amount,
      $date,
      $invoiceId,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Position, dynamic>> get $$fields => bean.fields;
  Position copyWith({
    String? id,
    String? userId,
    int? amount,
    DateTime? date,
    String? invoiceId,
    bool nullInvoiceId = false,
  }) {
    final $data = this as Position;
    return Position(
      id: id ?? $data.id,
      userId: userId ?? $data.userId,
      amount: amount ?? $data.amount,
      date: date ?? $data.date,
      invoiceId: nullInvoiceId ? null : (invoiceId ?? $data.invoiceId),
    );
  }

  static Position fromValues(Map<String, dynamic> data) {
    return Position(
      id: data['id'] ?? '',
      userId: data['userId'],
      amount: data['amount'],
      date: data['date'],
      invoiceId: data['invoiceId'],
    );
  }

  static Position fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Position, data.runtimeType, name);
    }
    return Position(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      userId: $userId.fromJson(
        data['userId'],
        name: DataCodec.childName(name, 'userId'),
      ),
      amount: $amount.fromJson(
        data['amount'],
        name: DataCodec.childName(name, 'amount'),
      ),
      date: $date.fromJson(
        data['date'],
        name: DataCodec.childName(name, 'date'),
      ),
      invoiceId: $invoiceId.fromJson(
        data['invoiceId'],
        name: DataCodec.childName(name, 'invoiceId'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Position;
    return {
      'id': $id.toJson($$data.id),
      'userId': $userId.toJson($$data.userId),
      'amount': $amount.toJson($$data.amount),
      'date': $date.toJson($$data.date),
      'invoiceId': $invoiceId.toJson($$data.invoiceId),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $BillingPeriod with DataObject<BillingPeriod> {
  const $BillingPeriod();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<BillingPeriod, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id()],
  );

  static final $index = DataField<BillingPeriod, int>(
    name: 'index',
    valueOf: (p) => p.index,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $end = DataField<BillingPeriod, DateTime>(
    name: 'end',
    valueOf: (p) => p.end,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $state = DataField<BillingPeriod, PeriodState>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? PeriodState.open),
      PeriodState.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: PeriodState.values)],
  );

  static final DataBean<BillingPeriod> bean = DataBean<BillingPeriod>(
    name: 'BillingPeriod',
    fields: List<DataField<BillingPeriod, dynamic>>.unmodifiable([
      $id,
      $index,
      $end,
      $state,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<BillingPeriod, dynamic>> get $$fields => bean.fields;
  BillingPeriod copyWith({
    String? id,
    int? index,
    DateTime? end,
    PeriodState? state,
  }) {
    final $data = this as BillingPeriod;
    return BillingPeriod(
      id: id ?? $data.id,
      index: index ?? $data.index,
      end: end ?? $data.end,
      state: state ?? $data.state,
    );
  }

  static BillingPeriod fromValues(Map<String, dynamic> data) {
    return BillingPeriod(
      id: data['id'],
      index: data['index'],
      end: data['end'],
      state: data['state'] ?? PeriodState.open,
    );
  }

  static BillingPeriod fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(BillingPeriod, data.runtimeType, name);
    }
    return BillingPeriod(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      index: $index.fromJson(
        data['index'],
        name: DataCodec.childName(name, 'index'),
      ),
      end: $end.fromJson(data['end'], name: DataCodec.childName(name, 'end')),
      state: $state.fromJson(
        data['state'],
        name: DataCodec.childName(name, 'state'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as BillingPeriod;
    return {
      'id': $id.toJson($$data.id),
      'index': $index.toJson($$data.index),
      'end': $end.toJson($$data.end),
      'state': $state.toJson($$data.state),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $BillingInvoice with DataObject<BillingInvoice> {
  const $BillingInvoice();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<BillingInvoice, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id()],
  );

  static final $userId = DataField<BillingInvoice, String>(
    name: 'userId',
    valueOf: (p) => p.userId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $periodEnd = DataField<BillingInvoice, DateTime>(
    name: 'periodEnd',
    valueOf: (p) => p.periodEnd,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final $total = DataField<BillingInvoice, int>(
    name: 'total',
    valueOf: (p) => p.total,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $state = DataField<BillingInvoice, BillingInvoiceState>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? BillingInvoiceState.created),
      BillingInvoiceState.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: BillingInvoiceState.values)],
  );

  static final DataBean<BillingInvoice> bean = DataBean<BillingInvoice>(
    name: 'BillingInvoice',
    fields: List<DataField<BillingInvoice, dynamic>>.unmodifiable([
      $id,
      $userId,
      $periodEnd,
      $total,
      $state,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<BillingInvoice, dynamic>> get $$fields => bean.fields;
  BillingInvoice copyWith({
    String? id,
    String? userId,
    DateTime? periodEnd,
    int? total,
    BillingInvoiceState? state,
  }) {
    final $data = this as BillingInvoice;
    return BillingInvoice(
      id: id ?? $data.id,
      userId: userId ?? $data.userId,
      periodEnd: periodEnd ?? $data.periodEnd,
      total: total ?? $data.total,
      state: state ?? $data.state,
    );
  }

  static BillingInvoice fromValues(Map<String, dynamic> data) {
    return BillingInvoice(
      id: data['id'],
      userId: data['userId'],
      periodEnd: data['periodEnd'],
      total: data['total'] ?? 0,
      state: data['state'] ?? BillingInvoiceState.created,
    );
  }

  static BillingInvoice fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(BillingInvoice, data.runtimeType, name);
    }
    return BillingInvoice(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      userId: $userId.fromJson(
        data['userId'],
        name: DataCodec.childName(name, 'userId'),
      ),
      periodEnd: $periodEnd.fromJson(
        data['periodEnd'],
        name: DataCodec.childName(name, 'periodEnd'),
      ),
      total: $total.fromJson(
        data['total'],
        name: DataCodec.childName(name, 'total'),
      ),
      state: $state.fromJson(
        data['state'],
        name: DataCodec.childName(name, 'state'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as BillingInvoice;
    return {
      'id': $id.toJson($$data.id),
      'userId': $userId.toJson($$data.userId),
      'periodEnd': $periodEnd.toJson($$data.periodEnd),
      'total': $total.toJson($$data.total),
      'state': $state.toJson($$data.state),
    }..removeWhere((k, v) => v == null);
  }
}
