// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_test.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Invoice with DataObject<Invoice> {
  const $Invoice();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Invoice, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? ''), name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $recipient = DataField<Invoice, String>(
    name: 'recipient',
    valueOf: (p) => p.recipient,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $invoiceFile = DataField<Invoice, String?>(
    name: 'invoiceFile',
    valueOf: (p) => p.invoiceFile,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $amount = DataField<Invoice, int>(
    name: 'amount',
    valueOf: (p) => p.amount,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $state = DataField<Invoice, InvoiceWorkflowState>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? InvoiceWorkflowState.created),
      InvoiceWorkflowState.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: InvoiceWorkflowState.values)],
  );

  static final $paymentReference = DataField<Invoice, String?>(
    name: 'paymentReference',
    valueOf: (p) => p.paymentReference,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<Invoice> bean = DataBean<Invoice>(
    name: 'Invoice',
    fields: List<DataField<Invoice, dynamic>>.unmodifiable([
      $id,
      $recipient,
      $invoiceFile,
      $amount,
      $state,
      $paymentReference,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Invoice, dynamic>> get $$fields => bean.fields;
  Invoice copyWith({
    String? id,
    String? recipient,
    String? invoiceFile,
    bool nullInvoiceFile = false,
    int? amount,
    InvoiceWorkflowState? state,
    String? paymentReference,
    bool nullPaymentReference = false,
  }) {
    final $data = this as Invoice;
    return Invoice(
      id: id ?? $data.id,
      recipient: recipient ?? $data.recipient,
      invoiceFile: nullInvoiceFile ? null : (invoiceFile ?? $data.invoiceFile),
      amount: amount ?? $data.amount,
      state: state ?? $data.state,
      paymentReference: nullPaymentReference
          ? null
          : (paymentReference ?? $data.paymentReference),
    );
  }

  static Invoice fromValues(Map<String, dynamic> data) {
    return Invoice(
      id: data['id'] ?? '',
      recipient: data['recipient'],
      invoiceFile: data['invoiceFile'],
      amount: data['amount'],
      state: data['state'] ?? InvoiceWorkflowState.created,
      paymentReference: data['paymentReference'],
    );
  }

  static Invoice fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Invoice, data.runtimeType, name);
    }
    return Invoice(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      recipient: $recipient.fromJson(
        data['recipient'],
        name: DataCodec.childName(name, 'recipient'),
      ),
      invoiceFile: $invoiceFile.fromJson(
        data['invoiceFile'],
        name: DataCodec.childName(name, 'invoiceFile'),
      ),
      amount: $amount.fromJson(
        data['amount'],
        name: DataCodec.childName(name, 'amount'),
      ),
      state: $state.fromJson(
        data['state'],
        name: DataCodec.childName(name, 'state'),
      ),
      paymentReference: $paymentReference.fromJson(
        data['paymentReference'],
        name: DataCodec.childName(name, 'paymentReference'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Invoice;
    return {
      'id': $id.toJson($$data.id),
      'recipient': $recipient.toJson($$data.recipient),
      'invoiceFile': $invoiceFile.toJson($$data.invoiceFile),
      'amount': $amount.toJson($$data.amount),
      'state': $state.toJson($$data.state),
      'paymentReference': $paymentReference.toJson($$data.paymentReference),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $PaymentSuccessSignal
    with DataObject<PaymentSuccessSignal> {
  const $PaymentSuccessSignal();
  static const $$codec = JsonDataCodec();
  static final $invoiceId = DataField<PaymentSuccessSignal, String>(
    name: 'invoiceId',
    valueOf: (p) => p.invoiceId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $reference = DataField<PaymentSuccessSignal, String>(
    name: 'reference',
    valueOf: (p) => p.reference,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<PaymentSuccessSignal> bean =
      DataBean<PaymentSuccessSignal>(
        name: 'PaymentSuccessSignal',
        fields: List<DataField<PaymentSuccessSignal, dynamic>>.unmodifiable([
          $invoiceId,
          $reference,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<PaymentSuccessSignal, dynamic>> get $$fields => bean.fields;
  PaymentSuccessSignal copyWith({String? invoiceId, String? reference}) {
    final $data = this as PaymentSuccessSignal;
    return PaymentSuccessSignal(
      invoiceId: invoiceId ?? $data.invoiceId,
      reference: reference ?? $data.reference,
    );
  }

  static PaymentSuccessSignal fromValues(Map<String, dynamic> data) {
    return PaymentSuccessSignal(
      invoiceId: data['invoiceId'],
      reference: data['reference'],
    );
  }

  static PaymentSuccessSignal fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        PaymentSuccessSignal,
        data.runtimeType,
        name,
      );
    }
    return PaymentSuccessSignal(
      invoiceId: $invoiceId.fromJson(
        data['invoiceId'],
        name: DataCodec.childName(name, 'invoiceId'),
      ),
      reference: $reference.fromJson(
        data['reference'],
        name: DataCodec.childName(name, 'reference'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as PaymentSuccessSignal;
    return {
      'invoiceId': $invoiceId.toJson($$data.invoiceId),
      'reference': $reference.toJson($$data.reference),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $PaymentFailedSignal
    with DataObject<PaymentFailedSignal> {
  const $PaymentFailedSignal();
  static const $$codec = JsonDataCodec();
  static final $invoiceId = DataField<PaymentFailedSignal, String>(
    name: 'invoiceId',
    valueOf: (p) => p.invoiceId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $reference = DataField<PaymentFailedSignal, String>(
    name: 'reference',
    valueOf: (p) => p.reference,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $reason = DataField<PaymentFailedSignal, String>(
    name: 'reason',
    valueOf: (p) => p.reason,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<PaymentFailedSignal> bean =
      DataBean<PaymentFailedSignal>(
        name: 'PaymentFailedSignal',
        fields: List<DataField<PaymentFailedSignal, dynamic>>.unmodifiable([
          $invoiceId,
          $reference,
          $reason,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<PaymentFailedSignal, dynamic>> get $$fields => bean.fields;
  PaymentFailedSignal copyWith({
    String? invoiceId,
    String? reference,
    String? reason,
  }) {
    final $data = this as PaymentFailedSignal;
    return PaymentFailedSignal(
      invoiceId: invoiceId ?? $data.invoiceId,
      reference: reference ?? $data.reference,
      reason: reason ?? $data.reason,
    );
  }

  static PaymentFailedSignal fromValues(Map<String, dynamic> data) {
    return PaymentFailedSignal(
      invoiceId: data['invoiceId'],
      reference: data['reference'],
      reason: data['reason'],
    );
  }

  static PaymentFailedSignal fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        PaymentFailedSignal,
        data.runtimeType,
        name,
      );
    }
    return PaymentFailedSignal(
      invoiceId: $invoiceId.fromJson(
        data['invoiceId'],
        name: DataCodec.childName(name, 'invoiceId'),
      ),
      reference: $reference.fromJson(
        data['reference'],
        name: DataCodec.childName(name, 'reference'),
      ),
      reason: $reason.fromJson(
        data['reason'],
        name: DataCodec.childName(name, 'reason'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as PaymentFailedSignal;
    return {
      'invoiceId': $invoiceId.toJson($$data.invoiceId),
      'reference': $reference.toJson($$data.reference),
      'reason': $reason.toJson($$data.reason),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $UnhandledSignal with DataObject<UnhandledSignal> {
  const $UnhandledSignal();
  static const $$codec = JsonDataCodec();
  static final $note = DataField<UnhandledSignal, String>(
    name: 'note',
    valueOf: (p) => p.note,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? ''), name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<UnhandledSignal> bean = DataBean<UnhandledSignal>(
    name: 'UnhandledSignal',
    fields: List<DataField<UnhandledSignal, dynamic>>.unmodifiable([$note]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<UnhandledSignal, dynamic>> get $$fields => bean.fields;
  UnhandledSignal copyWith({String? note}) {
    final $data = this as UnhandledSignal;
    return UnhandledSignal(note: note ?? $data.note);
  }

  static UnhandledSignal fromValues(Map<String, dynamic> data) {
    return UnhandledSignal(note: data['note'] ?? '');
  }

  static UnhandledSignal fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        UnhandledSignal,
        data.runtimeType,
        name,
      );
    }
    return UnhandledSignal(
      note: $note.fromJson(
        data['note'],
        name: DataCodec.childName(name, 'note'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as UnhandledSignal;
    return {'note': $note.toJson($$data.note)}
      ..removeWhere((k, v) => v == null);
  }
}

abstract interface class $ForeignSignal with DataObject<ForeignSignal> {
  const $ForeignSignal();
  static const $$codec = JsonDataCodec();
  static final $note = DataField<ForeignSignal, String>(
    name: 'note',
    valueOf: (p) => p.note,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? ''), name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<ForeignSignal> bean = DataBean<ForeignSignal>(
    name: 'ForeignSignal',
    fields: List<DataField<ForeignSignal, dynamic>>.unmodifiable([$note]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ForeignSignal, dynamic>> get $$fields => bean.fields;
  ForeignSignal copyWith({String? note}) {
    final $data = this as ForeignSignal;
    return ForeignSignal(note: note ?? $data.note);
  }

  static ForeignSignal fromValues(Map<String, dynamic> data) {
    return ForeignSignal(note: data['note'] ?? '');
  }

  static ForeignSignal fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ForeignSignal, data.runtimeType, name);
    }
    return ForeignSignal(
      note: $note.fromJson(
        data['note'],
        name: DataCodec.childName(name, 'note'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ForeignSignal;
    return {'note': $note.toJson($$data.note)}
      ..removeWhere((k, v) => v == null);
  }
}
