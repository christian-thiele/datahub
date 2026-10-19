// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_invoices.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ExportInvoices with DataObject<ExportInvoices> {
  const $ExportInvoices();
  static const $$codec = JsonDataCodec();
  static final $onlyOverdue = DataField<ExportInvoices, bool>(
    name: 'onlyOverdue',
    valueOf: (p) => p.onlyOverdue,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
    meta: [
      const Meta(
        name: 'Only overdue',
        description: 'Leave out all other invoices.',
      ),
    ],
  );

  static final DataBean<ExportInvoices> bean = DataBean<ExportInvoices>(
    name: 'ExportInvoices',
    fields: List<DataField<ExportInvoices, dynamic>>.unmodifiable([
      $onlyOverdue,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [const Meta(name: 'Export invoices', icon: 57857)],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ExportInvoices, dynamic>> get $$fields => bean.fields;
  ExportInvoices copyWith({bool? onlyOverdue}) {
    final $data = this as ExportInvoices;
    return ExportInvoices(onlyOverdue: onlyOverdue ?? $data.onlyOverdue);
  }

  static ExportInvoices fromValues(Map<String, dynamic> data) {
    return ExportInvoices(onlyOverdue: data['onlyOverdue'] ?? false);
  }

  static ExportInvoices fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(ExportInvoices, data.runtimeType, name);
    }
    return ExportInvoices(
      onlyOverdue: $onlyOverdue.fromJson(
        data['onlyOverdue'],
        name: DataCodec.childName(name, 'onlyOverdue'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ExportInvoices;
    return {'onlyOverdue': $onlyOverdue.toJson($$data.onlyOverdue)}
      ..removeWhere((k, v) => v == null);
  }
}
