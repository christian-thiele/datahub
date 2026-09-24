// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $SupportTicket with DataObject<SupportTicket> {
  const $SupportTicket();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<SupportTicket, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $ticketNumber = DataField<SupportTicket, String>(
    name: 'ticketNumber',
    valueOf: (p) => p.ticketNumber,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(isDisplayField: true, readOnly: true),
      const Meta(name: 'Ticket No.'),
    ],
    constraints: [const RegExpConstraint<String?>(expression: '^#\\d{5}\$')],
  );

  static final $subject = DataField<SupportTicket, String>(
    name: 'subject',
    valueOf: (p) => p.subject,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [const MaxLengthConstraint<String?>(length: 160)],
  );

  static final $body = DataField<SupportTicket, String>(
    name: 'body',
    valueOf: (p) => p.body,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(allowFilter: false, allowSort: false),
      const Meta(name: 'Message'),
    ],
  );

  static final $clientId = DataField<SupportTicket, int>(
    name: 'clientId',
    valueOf: (p) => p.clientId,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [
      const Meta(name: 'Client'),
      const RelationId<Client>(),
    ],
  );

  static final $contactId = DataField<SupportTicket, int?>(
    name: 'contactId',
    valueOf: (p) => p.contactId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [
      const Meta(name: 'Reported by'),
      const RelationId<Contact>(),
    ],
  );

  static final $projectId = DataField<SupportTicket, int?>(
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

  static final $assigneeId = DataField<SupportTicket, int?>(
    name: 'assigneeId',
    valueOf: (p) => p.assigneeId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [
      const Meta(name: 'Assignee'),
      const RelationId<Employee>(),
    ],
  );

  static final $status = DataField<SupportTicket, TicketStatus>(
    name: 'status',
    valueOf: (p) => p.status,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? TicketStatus.open),
      TicketStatus.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [EnumConstraint(values: TicketStatus.values)],
  );

  static final $priority = DataField<SupportTicket, Priority>(
    name: 'priority',
    valueOf: (p) => p.priority,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? Priority.normal),
      Priority.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [EnumConstraint(values: Priority.values)],
  );

  static final $channel = DataField<SupportTicket, TicketChannel>(
    name: 'channel',
    valueOf: (p) => p.channel,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? TicketChannel.email),
      TicketChannel.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: TicketChannel.values)],
  );

  static final $createdAt = DataField<SupportTicket, DateTime>(
    name: 'createdAt',
    valueOf: (p) => p.createdAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [const Meta(name: 'Created')],
  );

  static final $firstResponseAt = DataField<SupportTicket, DateTime?>(
    name: 'firstResponseAt',
    valueOf: (p) => p.firstResponseAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const Meta(name: 'First response')],
  );

  static final $resolvedAt = DataField<SupportTicket, DateTime?>(
    name: 'resolvedAt',
    valueOf: (p) => p.resolvedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const Meta(name: 'Resolved')],
  );

  static final $resolution = DataField<SupportTicket, String?>(
    name: 'resolution',
    valueOf: (p) => p.resolution,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const ApertureField(allowFilter: false, allowSort: false)],
  );

  static final $labels = DataField<SupportTicket, List<String>>(
    name: 'labels',
    valueOf: (p) => p.labels,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
    constraints: [
      const ElementConstraint<String?>(
        constraint: const RegExpConstraint<String?>(
          expression: '^[a-z0-9-]+\$',
        ),
      ),
    ],
  );

  static final $slaBreached = DataField<SupportTicket, bool>(
    name: 'slaBreached',
    valueOf: (p) => p.slaBreached,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
    meta: [const Meta(name: 'SLA breached')],
  );

  static final $satisfaction = DataField<SupportTicket, int?>(
    name: 'satisfaction',
    valueOf: (p) => p.satisfaction,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [
      const Meta(
        description: 'Customer rating from 1 (poor) to 5 (excellent).',
      ),
    ],
    constraints: [const RangeConstraint<num?>(min: 1, max: 5)],
  );

  static final DataBean<SupportTicket> bean = DataBean<SupportTicket>(
    name: 'SupportTicket',
    fields: List<DataField<SupportTicket, dynamic>>.unmodifiable([
      $id,
      $ticketNumber,
      $subject,
      $body,
      $clientId,
      $contactId,
      $projectId,
      $assigneeId,
      $status,
      $priority,
      $channel,
      $createdAt,
      $firstResponseAt,
      $resolvedAt,
      $resolution,
      $labels,
      $slaBreached,
      $satisfaction,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(name: 'Ticket', namePlural: 'Support tickets', icon: 58913),
      const ApertureMeta(titleTemplate: '{{ ticketNumber }} {{ subject }}'),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<SupportTicket, dynamic>> get $$fields => bean.fields;
  SupportTicket copyWith({
    int? id,
    String? ticketNumber,
    String? subject,
    String? body,
    int? clientId,
    int? contactId,
    bool nullContactId = false,
    int? projectId,
    bool nullProjectId = false,
    int? assigneeId,
    bool nullAssigneeId = false,
    TicketStatus? status,
    Priority? priority,
    TicketChannel? channel,
    DateTime? createdAt,
    DateTime? firstResponseAt,
    bool nullFirstResponseAt = false,
    DateTime? resolvedAt,
    bool nullResolvedAt = false,
    String? resolution,
    bool nullResolution = false,
    List<String>? labels,
    bool? slaBreached,
    int? satisfaction,
    bool nullSatisfaction = false,
  }) {
    final $data = this as SupportTicket;
    return SupportTicket(
      id: id ?? $data.id,
      ticketNumber: ticketNumber ?? $data.ticketNumber,
      subject: subject ?? $data.subject,
      body: body ?? $data.body,
      clientId: clientId ?? $data.clientId,
      contactId: nullContactId ? null : (contactId ?? $data.contactId),
      projectId: nullProjectId ? null : (projectId ?? $data.projectId),
      assigneeId: nullAssigneeId ? null : (assigneeId ?? $data.assigneeId),
      status: status ?? $data.status,
      priority: priority ?? $data.priority,
      channel: channel ?? $data.channel,
      createdAt: createdAt ?? $data.createdAt,
      firstResponseAt: nullFirstResponseAt
          ? null
          : (firstResponseAt ?? $data.firstResponseAt),
      resolvedAt: nullResolvedAt ? null : (resolvedAt ?? $data.resolvedAt),
      resolution: nullResolution ? null : (resolution ?? $data.resolution),
      labels: labels ?? $data.labels,
      slaBreached: slaBreached ?? $data.slaBreached,
      satisfaction: nullSatisfaction
          ? null
          : (satisfaction ?? $data.satisfaction),
    );
  }

  static SupportTicket fromValues(Map<String, dynamic> data) {
    return SupportTicket(
      id: data['id'] ?? 0,
      ticketNumber: data['ticketNumber'],
      subject: data['subject'],
      body: data['body'],
      clientId: data['clientId'],
      contactId: data['contactId'],
      projectId: data['projectId'],
      assigneeId: data['assigneeId'],
      status: data['status'] ?? TicketStatus.open,
      priority: data['priority'] ?? Priority.normal,
      channel: data['channel'] ?? TicketChannel.email,
      createdAt: data['createdAt'],
      firstResponseAt: data['firstResponseAt'],
      resolvedAt: data['resolvedAt'],
      resolution: data['resolution'],
      labels:
          data['labels']?.cast<String>().toList(growable: false) ?? const [],
      slaBreached: data['slaBreached'] ?? false,
      satisfaction: data['satisfaction'],
    );
  }

  static SupportTicket fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(SupportTicket, data.runtimeType, name);
    }
    return SupportTicket(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      ticketNumber: $ticketNumber.fromJson(
        data['ticketNumber'],
        name: DataCodec.childName(name, 'ticketNumber'),
      ),
      subject: $subject.fromJson(
        data['subject'],
        name: DataCodec.childName(name, 'subject'),
      ),
      body: $body.fromJson(
        data['body'],
        name: DataCodec.childName(name, 'body'),
      ),
      clientId: $clientId.fromJson(
        data['clientId'],
        name: DataCodec.childName(name, 'clientId'),
      ),
      contactId: $contactId.fromJson(
        data['contactId'],
        name: DataCodec.childName(name, 'contactId'),
      ),
      projectId: $projectId.fromJson(
        data['projectId'],
        name: DataCodec.childName(name, 'projectId'),
      ),
      assigneeId: $assigneeId.fromJson(
        data['assigneeId'],
        name: DataCodec.childName(name, 'assigneeId'),
      ),
      status: $status.fromJson(
        data['status'],
        name: DataCodec.childName(name, 'status'),
      ),
      priority: $priority.fromJson(
        data['priority'],
        name: DataCodec.childName(name, 'priority'),
      ),
      channel: $channel.fromJson(
        data['channel'],
        name: DataCodec.childName(name, 'channel'),
      ),
      createdAt: $createdAt.fromJson(
        data['createdAt'],
        name: DataCodec.childName(name, 'createdAt'),
      ),
      firstResponseAt: $firstResponseAt.fromJson(
        data['firstResponseAt'],
        name: DataCodec.childName(name, 'firstResponseAt'),
      ),
      resolvedAt: $resolvedAt.fromJson(
        data['resolvedAt'],
        name: DataCodec.childName(name, 'resolvedAt'),
      ),
      resolution: $resolution.fromJson(
        data['resolution'],
        name: DataCodec.childName(name, 'resolution'),
      ),
      labels: $labels.fromJson(
        data['labels'],
        name: DataCodec.childName(name, 'labels'),
      ),
      slaBreached: $slaBreached.fromJson(
        data['slaBreached'],
        name: DataCodec.childName(name, 'slaBreached'),
      ),
      satisfaction: $satisfaction.fromJson(
        data['satisfaction'],
        name: DataCodec.childName(name, 'satisfaction'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as SupportTicket;
    return {
      'id': $id.toJson($$data.id),
      'ticketNumber': $ticketNumber.toJson($$data.ticketNumber),
      'subject': $subject.toJson($$data.subject),
      'body': $body.toJson($$data.body),
      'clientId': $clientId.toJson($$data.clientId),
      'contactId': $contactId.toJson($$data.contactId),
      'projectId': $projectId.toJson($$data.projectId),
      'assigneeId': $assigneeId.toJson($$data.assigneeId),
      'status': $status.toJson($$data.status),
      'priority': $priority.toJson($$data.priority),
      'channel': $channel.toJson($$data.channel),
      'createdAt': $createdAt.toJson($$data.createdAt),
      'firstResponseAt': $firstResponseAt.toJson($$data.firstResponseAt),
      'resolvedAt': $resolvedAt.toJson($$data.resolvedAt),
      'resolution': $resolution.toJson($$data.resolution),
      'labels': $labels.toJson($$data.labels),
      'slaBreached': $slaBreached.toJson($$data.slaBreached),
      'satisfaction': $satisfaction.toJson($$data.satisfaction),
    }..removeWhere((k, v) => v == null);
  }
}
