// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $TimeEntry with DataObject<TimeEntry> {
  const $TimeEntry();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<TimeEntry, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $date = DataField<TimeEntry, DateTime>(
    name: 'date',
    valueOf: (p) => p.date,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [const ApertureField(isDisplayField: true)],
  );

  static final $hours = DataField<TimeEntry, double>(
    name: 'hours',
    valueOf: (p) => p.hours,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [const RangeConstraint<num?>(min: 0.25, max: 12)],
  );

  static final $description = DataField<TimeEntry, String>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [
      const MinLengthConstraint<String?>(length: 3),
      const MaxLengthConstraint<String?>(length: 500),
    ],
  );

  static final $projectId = DataField<TimeEntry, int>(
    name: 'projectId',
    valueOf: (p) => p.projectId,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [
      const Meta(name: 'Project'),
      const RelationId<Project>(),
    ],
  );

  static final $employeeId = DataField<TimeEntry, int>(
    name: 'employeeId',
    valueOf: (p) => p.employeeId,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [
      const Meta(name: 'Employee'),
      const RelationId<Employee>(),
    ],
  );

  static final $productId = DataField<TimeEntry, String?>(
    name: 'productId',
    valueOf: (p) => p.productId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [
      const Meta(
        name: 'Service',
        description: 'Price agreement this time is billed on.',
      ),
      const RelationId<Product>(),
    ],
  );

  static final $billable = DataField<TimeEntry, bool>(
    name: 'billable',
    valueOf: (p) => p.billable,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? true), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $invoiced = DataField<TimeEntry, bool>(
    name: 'invoiced',
    valueOf: (p) => p.invoiced,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
    meta: [const Meta(description: 'Already included in an invoice.')],
  );

  static final DataBean<TimeEntry> bean = DataBean<TimeEntry>(
    name: 'TimeEntry',
    fields: List<DataField<TimeEntry, dynamic>>.unmodifiable([
      $id,
      $date,
      $hours,
      $description,
      $projectId,
      $employeeId,
      $productId,
      $billable,
      $invoiced,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(
        name: 'Time entry',
        namePlural: 'Timesheet',
        description: 'Booked working hours.',
        icon: 58978,
      ),
      const ApertureMeta(titleTemplate: '{{ hours }} h · {{ description }}'),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<TimeEntry, dynamic>> get $$fields => bean.fields;
  TimeEntry copyWith({
    int? id,
    DateTime? date,
    double? hours,
    String? description,
    int? projectId,
    int? employeeId,
    String? productId,
    bool nullProductId = false,
    bool? billable,
    bool? invoiced,
  }) {
    final $data = this as TimeEntry;
    return TimeEntry(
      id: id ?? $data.id,
      date: date ?? $data.date,
      hours: hours ?? $data.hours,
      description: description ?? $data.description,
      projectId: projectId ?? $data.projectId,
      employeeId: employeeId ?? $data.employeeId,
      productId: nullProductId ? null : (productId ?? $data.productId),
      billable: billable ?? $data.billable,
      invoiced: invoiced ?? $data.invoiced,
    );
  }

  static TimeEntry fromValues(Map<String, dynamic> data) {
    return TimeEntry(
      id: data['id'] ?? 0,
      date: data['date'],
      hours: data['hours'],
      description: data['description'],
      projectId: data['projectId'],
      employeeId: data['employeeId'],
      productId: data['productId'],
      billable: data['billable'] ?? true,
      invoiced: data['invoiced'] ?? false,
    );
  }

  static TimeEntry fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(TimeEntry, data.runtimeType, name);
    }
    return TimeEntry(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      date: $date.fromJson(
        data['date'],
        name: DataCodec.childName(name, 'date'),
      ),
      hours: $hours.fromJson(
        data['hours'],
        name: DataCodec.childName(name, 'hours'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      projectId: $projectId.fromJson(
        data['projectId'],
        name: DataCodec.childName(name, 'projectId'),
      ),
      employeeId: $employeeId.fromJson(
        data['employeeId'],
        name: DataCodec.childName(name, 'employeeId'),
      ),
      productId: $productId.fromJson(
        data['productId'],
        name: DataCodec.childName(name, 'productId'),
      ),
      billable: $billable.fromJson(
        data['billable'],
        name: DataCodec.childName(name, 'billable'),
      ),
      invoiced: $invoiced.fromJson(
        data['invoiced'],
        name: DataCodec.childName(name, 'invoiced'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as TimeEntry;
    return {
      'id': $id.toJson($$data.id),
      'date': $date.toJson($$data.date),
      'hours': $hours.toJson($$data.hours),
      'description': $description.toJson($$data.description),
      'projectId': $projectId.toJson($$data.projectId),
      'employeeId': $employeeId.toJson($$data.employeeId),
      'productId': $productId.toJson($$data.productId),
      'billable': $billable.toJson($$data.billable),
      'invoiced': $invoiced.toJson($$data.invoiced),
    }..removeWhere((k, v) => v == null);
  }
}
