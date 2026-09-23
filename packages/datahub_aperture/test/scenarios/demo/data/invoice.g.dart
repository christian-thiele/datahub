// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Invoice with DataObject<Invoice> {
  const $Invoice();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Invoice, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $invoiceNumber = DataField<Invoice, String>(
    name: 'invoiceNumber',
    valueOf: (p) => p.invoiceNumber,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(isDisplayField: true, readOnly: true),
      const Meta(name: 'Invoice No.'),
    ],
    constraints: [
      const RegExpConstraint<String?>(expression: '^INV-\\d{4}-\\d{4}\$'),
    ],
  );

  static final $clientId = DataField<Invoice, int>(
    name: 'clientId',
    valueOf: (p) => p.clientId,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [
      const Meta(name: 'Client'),
      const RelationId<Client>(),
      const ApertureField(readOnly: true),
    ],
  );

  static final $projectId = DataField<Invoice, int?>(
    name: 'projectId',
    valueOf: (p) => p.projectId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [
      const Meta(name: 'Project'),
      const RelationId<Project>(),
    ],
  );

  static final $status = DataField<Invoice, InvoiceStatus>(
    name: 'status',
    valueOf: (p) => p.status,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? InvoiceStatus.draft),
      InvoiceStatus.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [EnumConstraint(values: InvoiceStatus.values)],
  );

  static final $issuedAt = DataField<Invoice, DateTime>(
    name: 'issuedAt',
    valueOf: (p) => p.issuedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [
      const ApertureField(isDisplayField: true),
      const Meta(name: 'Issued'),
    ],
  );

  static final $dueAt = DataField<Invoice, DateTime>(
    name: 'dueAt',
    valueOf: (p) => p.dueAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [const Meta(name: 'Due')],
  );

  static final $paidAt = DataField<Invoice, DateTime?>(
    name: 'paidAt',
    valueOf: (p) => p.paidAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const Meta(name: 'Paid')],
  );

  static final $servicePeriodStart = DataField<Invoice, DateTime?>(
    name: 'servicePeriodStart',
    valueOf: (p) => p.servicePeriodStart,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const Meta(name: 'Service period from')],
  );

  static final $servicePeriodEnd = DataField<Invoice, DateTime?>(
    name: 'servicePeriodEnd',
    valueOf: (p) => p.servicePeriodEnd,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const Meta(name: 'Service period until')],
  );

  static final $billingAddress = DataField<Invoice, Address>(
    name: 'billingAddress',
    valueOf: (p) => p.billingAddress,
    dataBean: () => $Address.bean,
    fromJson: (value, {String? name}) =>
        $Address.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
    meta: [const Meta(name: 'Billing address')],
  );

  static final $lines = DataField<Invoice, List<InvoiceLine>>(
    name: 'lines',
    valueOf: (p) => p.lines,
    dataBean: () => $InvoiceLine.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<InvoiceLine>(
      value,
      $InvoiceLine.bean.fromJson,
      name: name,
    ),
    toJson: (value) =>
        $$codec.encodeList<InvoiceLine>(value, (v) => v.toJson()),
    meta: [const Meta(name: 'Line items')],
  );

  static final $netTotal = DataField<Invoice, double>(
    name: 'netTotal',
    valueOf: (p) => p.netTotal,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [
      const ApertureField(readOnly: true),
      const Meta(name: 'Net'),
    ],
  );

  static final $taxTotal = DataField<Invoice, double>(
    name: 'taxTotal',
    valueOf: (p) => p.taxTotal,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [
      const ApertureField(readOnly: true),
      const Meta(name: 'Tax'),
    ],
  );

  static final $grossTotal = DataField<Invoice, double>(
    name: 'grossTotal',
    valueOf: (p) => p.grossTotal,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [
      const ApertureField(isDisplayField: true, readOnly: true),
      const Meta(name: 'Gross'),
    ],
  );

  static final $currency = DataField<Invoice, String>(
    name: 'currency',
    valueOf: (p) => p.currency,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? 'EUR'), name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [const RegExpConstraint<String?>(expression: '^[A-Z]{3}\$')],
  );

  static final $paymentReference = DataField<Invoice, String?>(
    name: 'paymentReference',
    valueOf: (p) => p.paymentReference,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const Meta(name: 'Payment reference')],
  );

  static final $remindersSent = DataField<Invoice, int>(
    name: 'remindersSent',
    valueOf: (p) => p.remindersSent,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Meta(name: 'Reminders sent')],
    constraints: [const RangeConstraint<num?>(min: 0, max: 3)],
  );

  static final $notes = DataField<Invoice, String?>(
    name: 'notes',
    valueOf: (p) => p.notes,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const ApertureField(allowFilter: false, allowSort: false)],
  );

  static final DataBean<Invoice> bean = DataBean<Invoice>(
    name: 'Invoice',
    fields: List<DataField<Invoice, dynamic>>.unmodifiable([
      $id,
      $invoiceNumber,
      $clientId,
      $projectId,
      $status,
      $issuedAt,
      $dueAt,
      $paidAt,
      $servicePeriodStart,
      $servicePeriodEnd,
      $billingAddress,
      $lines,
      $netTotal,
      $taxTotal,
      $grossTotal,
      $currency,
      $paymentReference,
      $remindersSent,
      $notes,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(namePlural: 'Invoices', icon: 58637),
      const ApertureMeta(titleTemplate: '{{ invoiceNumber }}'),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Invoice, dynamic>> get $$fields => bean.fields;
  Invoice copyWith({
    int? id,
    String? invoiceNumber,
    int? clientId,
    int? projectId,
    bool nullProjectId = false,
    InvoiceStatus? status,
    DateTime? issuedAt,
    DateTime? dueAt,
    DateTime? paidAt,
    bool nullPaidAt = false,
    DateTime? servicePeriodStart,
    bool nullServicePeriodStart = false,
    DateTime? servicePeriodEnd,
    bool nullServicePeriodEnd = false,
    Address? billingAddress,
    List<InvoiceLine>? lines,
    double? netTotal,
    double? taxTotal,
    double? grossTotal,
    String? currency,
    String? paymentReference,
    bool nullPaymentReference = false,
    int? remindersSent,
    String? notes,
    bool nullNotes = false,
  }) {
    final $data = this as Invoice;
    return Invoice(
      id: id ?? $data.id,
      invoiceNumber: invoiceNumber ?? $data.invoiceNumber,
      clientId: clientId ?? $data.clientId,
      projectId: nullProjectId ? null : (projectId ?? $data.projectId),
      status: status ?? $data.status,
      issuedAt: issuedAt ?? $data.issuedAt,
      dueAt: dueAt ?? $data.dueAt,
      paidAt: nullPaidAt ? null : (paidAt ?? $data.paidAt),
      servicePeriodStart: nullServicePeriodStart
          ? null
          : (servicePeriodStart ?? $data.servicePeriodStart),
      servicePeriodEnd: nullServicePeriodEnd
          ? null
          : (servicePeriodEnd ?? $data.servicePeriodEnd),
      billingAddress: billingAddress ?? $data.billingAddress,
      lines: lines ?? $data.lines,
      netTotal: netTotal ?? $data.netTotal,
      taxTotal: taxTotal ?? $data.taxTotal,
      grossTotal: grossTotal ?? $data.grossTotal,
      currency: currency ?? $data.currency,
      paymentReference: nullPaymentReference
          ? null
          : (paymentReference ?? $data.paymentReference),
      remindersSent: remindersSent ?? $data.remindersSent,
      notes: nullNotes ? null : (notes ?? $data.notes),
    );
  }

  static Invoice fromValues(Map<String, dynamic> data) {
    return Invoice(
      id: data['id'] ?? 0,
      invoiceNumber: data['invoiceNumber'],
      clientId: data['clientId'],
      projectId: data['projectId'],
      status: data['status'] ?? InvoiceStatus.draft,
      issuedAt: data['issuedAt'],
      dueAt: data['dueAt'],
      paidAt: data['paidAt'],
      servicePeriodStart: data['servicePeriodStart'],
      servicePeriodEnd: data['servicePeriodEnd'],
      billingAddress: data['billingAddress'],
      lines: data['lines']?.cast<InvoiceLine>().toList(growable: false),
      netTotal: data['netTotal'],
      taxTotal: data['taxTotal'],
      grossTotal: data['grossTotal'],
      currency: data['currency'] ?? 'EUR',
      paymentReference: data['paymentReference'],
      remindersSent: data['remindersSent'] ?? 0,
      notes: data['notes'],
    );
  }

  static Invoice fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Invoice, data.runtimeType, name);
    }
    return Invoice(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      invoiceNumber: $invoiceNumber.fromJson(
        data['invoiceNumber'],
        name: DataCodec.childName(name, 'invoiceNumber'),
      ),
      clientId: $clientId.fromJson(
        data['clientId'],
        name: DataCodec.childName(name, 'clientId'),
      ),
      projectId: $projectId.fromJson(
        data['projectId'],
        name: DataCodec.childName(name, 'projectId'),
      ),
      status: $status.fromJson(
        data['status'],
        name: DataCodec.childName(name, 'status'),
      ),
      issuedAt: $issuedAt.fromJson(
        data['issuedAt'],
        name: DataCodec.childName(name, 'issuedAt'),
      ),
      dueAt: $dueAt.fromJson(
        data['dueAt'],
        name: DataCodec.childName(name, 'dueAt'),
      ),
      paidAt: $paidAt.fromJson(
        data['paidAt'],
        name: DataCodec.childName(name, 'paidAt'),
      ),
      servicePeriodStart: $servicePeriodStart.fromJson(
        data['servicePeriodStart'],
        name: DataCodec.childName(name, 'servicePeriodStart'),
      ),
      servicePeriodEnd: $servicePeriodEnd.fromJson(
        data['servicePeriodEnd'],
        name: DataCodec.childName(name, 'servicePeriodEnd'),
      ),
      billingAddress: $billingAddress.fromJson(
        data['billingAddress'],
        name: DataCodec.childName(name, 'billingAddress'),
      ),
      lines: $lines.fromJson(
        data['lines'],
        name: DataCodec.childName(name, 'lines'),
      ),
      netTotal: $netTotal.fromJson(
        data['netTotal'],
        name: DataCodec.childName(name, 'netTotal'),
      ),
      taxTotal: $taxTotal.fromJson(
        data['taxTotal'],
        name: DataCodec.childName(name, 'taxTotal'),
      ),
      grossTotal: $grossTotal.fromJson(
        data['grossTotal'],
        name: DataCodec.childName(name, 'grossTotal'),
      ),
      currency: $currency.fromJson(
        data['currency'],
        name: DataCodec.childName(name, 'currency'),
      ),
      paymentReference: $paymentReference.fromJson(
        data['paymentReference'],
        name: DataCodec.childName(name, 'paymentReference'),
      ),
      remindersSent: $remindersSent.fromJson(
        data['remindersSent'],
        name: DataCodec.childName(name, 'remindersSent'),
      ),
      notes: $notes.fromJson(
        data['notes'],
        name: DataCodec.childName(name, 'notes'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Invoice;
    return {
      'id': $id.toJson($$data.id),
      'invoiceNumber': $invoiceNumber.toJson($$data.invoiceNumber),
      'clientId': $clientId.toJson($$data.clientId),
      'projectId': $projectId.toJson($$data.projectId),
      'status': $status.toJson($$data.status),
      'issuedAt': $issuedAt.toJson($$data.issuedAt),
      'dueAt': $dueAt.toJson($$data.dueAt),
      'paidAt': $paidAt.toJson($$data.paidAt),
      'servicePeriodStart': $servicePeriodStart.toJson(
        $$data.servicePeriodStart,
      ),
      'servicePeriodEnd': $servicePeriodEnd.toJson($$data.servicePeriodEnd),
      'billingAddress': $billingAddress.toJson($$data.billingAddress),
      'lines': $lines.toJson($$data.lines),
      'netTotal': $netTotal.toJson($$data.netTotal),
      'taxTotal': $taxTotal.toJson($$data.taxTotal),
      'grossTotal': $grossTotal.toJson($$data.grossTotal),
      'currency': $currency.toJson($$data.currency),
      'paymentReference': $paymentReference.toJson($$data.paymentReference),
      'remindersSent': $remindersSent.toJson($$data.remindersSent),
      'notes': $notes.toJson($$data.notes),
    }..removeWhere((k, v) => v == null);
  }
}
