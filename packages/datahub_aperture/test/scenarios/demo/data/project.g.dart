// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Project with DataObject<Project> {
  const $Project();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Project, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $code = DataField<Project, String>(
    name: 'code',
    valueOf: (p) => p.code,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true, readOnly: true)],
    constraints: [
      const RegExpConstraint<String?>(expression: '^P-\\d{4}-\\d{3}\$'),
    ],
  );

  static final $name = DataField<Project, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [const MaxLengthConstraint<String?>(length: 120)],
  );

  static final $description = DataField<Project, String?>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const ApertureField(allowFilter: false, allowSort: false)],
    constraints: [const MaxLengthConstraint<String?>(length: 4000)],
  );

  static final $clientId = DataField<Project, int>(
    name: 'clientId',
    valueOf: (p) => p.clientId,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [
      const Meta(name: 'Client'),
      const RelationId<Client>(),
    ],
  );

  static final $projectLeadId = DataField<Project, int?>(
    name: 'projectLeadId',
    valueOf: (p) => p.projectLeadId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [
      const Meta(name: 'Project lead'),
      const RelationId<Employee>(),
    ],
  );

  static final $status = DataField<Project, ProjectStatus>(
    name: 'status',
    valueOf: (p) => p.status,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? ProjectStatus.planned),
      ProjectStatus.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [EnumConstraint(values: ProjectStatus.values)],
  );

  static final $priority = DataField<Project, Priority>(
    name: 'priority',
    valueOf: (p) => p.priority,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? Priority.normal),
      Priority.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: Priority.values)],
  );

  static final $billingType = DataField<Project, BillingType>(
    name: 'billingType',
    valueOf: (p) => p.billingType,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, BillingType.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    meta: [const Meta(name: 'Billing')],
    constraints: [EnumConstraint(values: BillingType.values)],
  );

  static final $startDate = DataField<Project, DateTime>(
    name: 'startDate',
    valueOf: (p) => p.startDate,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [const Meta(name: 'Start')],
  );

  static final $endDate = DataField<Project, DateTime?>(
    name: 'endDate',
    valueOf: (p) => p.endDate,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const Meta(name: 'End', description: 'Planned or actual end date.')],
  );

  static final $budget = DataField<Project, double>(
    name: 'budget',
    valueOf: (p) => p.budget,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [const Meta(description: 'Total budget in client currency (net).')],
    constraints: [const RangeConstraint<num?>(min: 0, max: 100000000)],
  );

  static final $estimatedHours = DataField<Project, int?>(
    name: 'estimatedHours',
    valueOf: (p) => p.estimatedHours,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [const Meta(name: 'Estimated hours')],
    constraints: [const RangeConstraint<num?>(min: 0, max: 100000)],
  );

  static final $technologies = DataField<Project, List<String>>(
    name: 'technologies',
    valueOf: (p) => p.technologies,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
    meta: [const Meta(name: 'Tech stack')],
  );

  static final $links = DataField<Project, Map<String, dynamic>>(
    name: 'links',
    valueOf: (p) => p.links,
    fromJson: (value, {String? name}) => $$codec.decodeMap<dynamic>(
      (value ?? const {}),
      $$codec.decodeDynamic,
      name: name,
    ),
    toJson: (value) => $$codec.encodeMap<dynamic>(value, $$codec.encodeDynamic),
    meta: [
      const ApertureField(
        allowFilter: false,
        allowSearch: false,
        allowSort: false,
      ),
      const Meta(
        description: 'External links, e.g. repository, board, staging.',
      ),
    ],
  );

  static final DataBean<Project> bean = DataBean<Project>(
    name: 'Project',
    fields: List<DataField<Project, dynamic>>.unmodifiable([
      $id,
      $code,
      $name,
      $description,
      $clientId,
      $projectLeadId,
      $status,
      $priority,
      $billingType,
      $startDate,
      $endDate,
      $budget,
      $estimatedHours,
      $technologies,
      $links,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(namePlural: 'Projects', icon: 59122),
      const ApertureMeta(titleTemplate: '{{ code }} · {{ name }}'),
      const ApertureRelation<TimeEntry>(),
      const ApertureRelation<Invoice>(),
      const ApertureRelation<SupportTicket>(),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Project, dynamic>> get $$fields => bean.fields;
  Project copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    bool nullDescription = false,
    int? clientId,
    int? projectLeadId,
    bool nullProjectLeadId = false,
    ProjectStatus? status,
    Priority? priority,
    BillingType? billingType,
    DateTime? startDate,
    DateTime? endDate,
    bool nullEndDate = false,
    double? budget,
    int? estimatedHours,
    bool nullEstimatedHours = false,
    List<String>? technologies,
    Map<String, dynamic>? links,
  }) {
    final $data = this as Project;
    return Project(
      id: id ?? $data.id,
      code: code ?? $data.code,
      name: name ?? $data.name,
      description: nullDescription ? null : (description ?? $data.description),
      clientId: clientId ?? $data.clientId,
      projectLeadId: nullProjectLeadId
          ? null
          : (projectLeadId ?? $data.projectLeadId),
      status: status ?? $data.status,
      priority: priority ?? $data.priority,
      billingType: billingType ?? $data.billingType,
      startDate: startDate ?? $data.startDate,
      endDate: nullEndDate ? null : (endDate ?? $data.endDate),
      budget: budget ?? $data.budget,
      estimatedHours: nullEstimatedHours
          ? null
          : (estimatedHours ?? $data.estimatedHours),
      technologies: technologies ?? $data.technologies,
      links: links ?? $data.links,
    );
  }

  static Project fromValues(Map<String, dynamic> data) {
    return Project(
      id: data['id'] ?? 0,
      code: data['code'],
      name: data['name'],
      description: data['description'],
      clientId: data['clientId'],
      projectLeadId: data['projectLeadId'],
      status: data['status'] ?? ProjectStatus.planned,
      priority: data['priority'] ?? Priority.normal,
      billingType: data['billingType'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      budget: data['budget'],
      estimatedHours: data['estimatedHours'],
      technologies:
          data['technologies']?.cast<String>().toList(growable: false) ??
          const [],
      links: data['links'] ?? const {},
    );
  }

  static Project fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Project, data.runtimeType, name);
    }
    return Project(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      code: $code.fromJson(
        data['code'],
        name: DataCodec.childName(name, 'code'),
      ),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      clientId: $clientId.fromJson(
        data['clientId'],
        name: DataCodec.childName(name, 'clientId'),
      ),
      projectLeadId: $projectLeadId.fromJson(
        data['projectLeadId'],
        name: DataCodec.childName(name, 'projectLeadId'),
      ),
      status: $status.fromJson(
        data['status'],
        name: DataCodec.childName(name, 'status'),
      ),
      priority: $priority.fromJson(
        data['priority'],
        name: DataCodec.childName(name, 'priority'),
      ),
      billingType: $billingType.fromJson(
        data['billingType'],
        name: DataCodec.childName(name, 'billingType'),
      ),
      startDate: $startDate.fromJson(
        data['startDate'],
        name: DataCodec.childName(name, 'startDate'),
      ),
      endDate: $endDate.fromJson(
        data['endDate'],
        name: DataCodec.childName(name, 'endDate'),
      ),
      budget: $budget.fromJson(
        data['budget'],
        name: DataCodec.childName(name, 'budget'),
      ),
      estimatedHours: $estimatedHours.fromJson(
        data['estimatedHours'],
        name: DataCodec.childName(name, 'estimatedHours'),
      ),
      technologies: $technologies.fromJson(
        data['technologies'],
        name: DataCodec.childName(name, 'technologies'),
      ),
      links: $links.fromJson(
        data['links'],
        name: DataCodec.childName(name, 'links'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Project;
    return {
      'id': $id.toJson($$data.id),
      'code': $code.toJson($$data.code),
      'name': $name.toJson($$data.name),
      'description': $description.toJson($$data.description),
      'clientId': $clientId.toJson($$data.clientId),
      'projectLeadId': $projectLeadId.toJson($$data.projectLeadId),
      'status': $status.toJson($$data.status),
      'priority': $priority.toJson($$data.priority),
      'billingType': $billingType.toJson($$data.billingType),
      'startDate': $startDate.toJson($$data.startDate),
      'endDate': $endDate.toJson($$data.endDate),
      'budget': $budget.toJson($$data.budget),
      'estimatedHours': $estimatedHours.toJson($$data.estimatedHours),
      'technologies': $technologies.toJson($$data.technologies),
      'links': $links.toJson($$data.links),
    }..removeWhere((k, v) => v == null);
  }
}
