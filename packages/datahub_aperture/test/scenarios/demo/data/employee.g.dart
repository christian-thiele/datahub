// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Employee with DataObject<Employee> {
  const $Employee();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Employee, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $personnelNumber = DataField<Employee, String>(
    name: 'personnelNumber',
    valueOf: (p) => p.personnelNumber,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(isDisplayField: true, readOnly: true),
      const Meta(name: 'Personnel No.'),
    ],
    constraints: [const RegExpConstraint<String?>(expression: '^E\\d{4}\$')],
  );

  static final $firstName = DataField<Employee, String>(
    name: 'firstName',
    valueOf: (p) => p.firstName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [const MaxLengthConstraint<String?>(length: 50)],
  );

  static final $lastName = DataField<Employee, String>(
    name: 'lastName',
    valueOf: (p) => p.lastName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [const MaxLengthConstraint<String?>(length: 50)],
  );

  static final $email = DataField<Employee, String>(
    name: 'email',
    valueOf: (p) => p.email,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Meta(name: 'E-mail')],
    constraints: [
      const RegExpConstraint<String?>(
        expression: '^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+\$',
      ),
    ],
  );

  static final $jobTitle = DataField<Employee, String>(
    name: 'jobTitle',
    valueOf: (p) => p.jobTitle,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(isDisplayField: true),
      const Meta(name: 'Job title'),
    ],
  );

  static final $department = DataField<Employee, Department>(
    name: 'department',
    valueOf: (p) => p.department,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, Department.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: Department.values)],
  );

  static final $hiredAt = DataField<Employee, DateTime>(
    name: 'hiredAt',
    valueOf: (p) => p.hiredAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [const Meta(name: 'Hired')],
  );

  static final $hourlyCostRate = DataField<Employee, double>(
    name: 'hourlyCostRate',
    valueOf: (p) => p.hourlyCostRate,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDouble(value, name: name),
    toJson: (value) => $$codec.encodeDouble(value),
    meta: [
      const Meta(
        name: 'Hourly cost rate',
        description: 'Internal cost per hour in EUR, used for margin reports.',
      ),
    ],
    constraints: [const RangeConstraint<num?>(min: 0, max: 500)],
  );

  static final $weeklyHours = DataField<Employee, int>(
    name: 'weeklyHours',
    valueOf: (p) => p.weeklyHours,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 40), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Meta(name: 'Weekly hours')],
    constraints: [const RangeConstraint<num?>(min: 0, max: 48)],
  );

  static final $skills = DataField<Employee, List<String>>(
    name: 'skills',
    valueOf: (p) => p.skills,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $languages = DataField<Employee, List<String>>(
    name: 'languages',
    valueOf: (p) => p.languages,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const ['en']),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
    meta: [const Meta(description: 'Spoken languages (ISO 639-1).')],
    constraints: [
      const ElementConstraint<String?>(
        constraint: const RegExpConstraint<String?>(expression: '^[a-z]{2}\$'),
      ),
    ],
  );

  static final $managerId = DataField<Employee, int?>(
    name: 'managerId',
    valueOf: (p) => p.managerId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [
      const Meta(name: 'Reports to'),
      const RelationId<Employee>(),
    ],
  );

  static final $remote = DataField<Employee, bool>(
    name: 'remote',
    valueOf: (p) => p.remote,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
    meta: [const Meta(name: 'Fully remote')],
  );

  static final $active = DataField<Employee, bool>(
    name: 'active',
    valueOf: (p) => p.active,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? true), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final DataBean<Employee> bean = DataBean<Employee>(
    name: 'Employee',
    fields: List<DataField<Employee, dynamic>>.unmodifiable([
      $id,
      $personnelNumber,
      $firstName,
      $lastName,
      $email,
      $jobTitle,
      $department,
      $hiredAt,
      $hourlyCostRate,
      $weeklyHours,
      $skills,
      $languages,
      $managerId,
      $remote,
      $active,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(
        namePlural: 'Employees',
        description: 'Our own staff.',
        icon: 57544,
      ),
      const ApertureMeta(titleTemplate: '{{ firstName }} {{ lastName }}'),
      const ApertureRelation<Employee>(),
      const ApertureRelation<Client>(),
      const ApertureRelation<Project>(),
      const ApertureRelation<TimeEntry>(),
      const ApertureRelation<SupportTicket>(),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Employee, dynamic>> get $$fields => bean.fields;
  Employee copyWith({
    int? id,
    String? personnelNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? jobTitle,
    Department? department,
    DateTime? hiredAt,
    double? hourlyCostRate,
    int? weeklyHours,
    List<String>? skills,
    List<String>? languages,
    int? managerId,
    bool nullManagerId = false,
    bool? remote,
    bool? active,
  }) {
    final $data = this as Employee;
    return Employee(
      id: id ?? $data.id,
      personnelNumber: personnelNumber ?? $data.personnelNumber,
      firstName: firstName ?? $data.firstName,
      lastName: lastName ?? $data.lastName,
      email: email ?? $data.email,
      jobTitle: jobTitle ?? $data.jobTitle,
      department: department ?? $data.department,
      hiredAt: hiredAt ?? $data.hiredAt,
      hourlyCostRate: hourlyCostRate ?? $data.hourlyCostRate,
      weeklyHours: weeklyHours ?? $data.weeklyHours,
      skills: skills ?? $data.skills,
      languages: languages ?? $data.languages,
      managerId: nullManagerId ? null : (managerId ?? $data.managerId),
      remote: remote ?? $data.remote,
      active: active ?? $data.active,
    );
  }

  static Employee fromValues(Map<String, dynamic> data) {
    return Employee(
      id: data['id'] ?? 0,
      personnelNumber: data['personnelNumber'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      jobTitle: data['jobTitle'],
      department: data['department'],
      hiredAt: data['hiredAt'],
      hourlyCostRate: data['hourlyCostRate'],
      weeklyHours: data['weeklyHours'] ?? 40,
      skills:
          data['skills']?.cast<String>().toList(growable: false) ?? const [],
      languages:
          data['languages']?.cast<String>().toList(growable: false) ??
          const ['en'],
      managerId: data['managerId'],
      remote: data['remote'] ?? false,
      active: data['active'] ?? true,
    );
  }

  static Employee fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Employee, data.runtimeType, name);
    }
    return Employee(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      personnelNumber: $personnelNumber.fromJson(
        data['personnelNumber'],
        name: DataCodec.childName(name, 'personnelNumber'),
      ),
      firstName: $firstName.fromJson(
        data['firstName'],
        name: DataCodec.childName(name, 'firstName'),
      ),
      lastName: $lastName.fromJson(
        data['lastName'],
        name: DataCodec.childName(name, 'lastName'),
      ),
      email: $email.fromJson(
        data['email'],
        name: DataCodec.childName(name, 'email'),
      ),
      jobTitle: $jobTitle.fromJson(
        data['jobTitle'],
        name: DataCodec.childName(name, 'jobTitle'),
      ),
      department: $department.fromJson(
        data['department'],
        name: DataCodec.childName(name, 'department'),
      ),
      hiredAt: $hiredAt.fromJson(
        data['hiredAt'],
        name: DataCodec.childName(name, 'hiredAt'),
      ),
      hourlyCostRate: $hourlyCostRate.fromJson(
        data['hourlyCostRate'],
        name: DataCodec.childName(name, 'hourlyCostRate'),
      ),
      weeklyHours: $weeklyHours.fromJson(
        data['weeklyHours'],
        name: DataCodec.childName(name, 'weeklyHours'),
      ),
      skills: $skills.fromJson(
        data['skills'],
        name: DataCodec.childName(name, 'skills'),
      ),
      languages: $languages.fromJson(
        data['languages'],
        name: DataCodec.childName(name, 'languages'),
      ),
      managerId: $managerId.fromJson(
        data['managerId'],
        name: DataCodec.childName(name, 'managerId'),
      ),
      remote: $remote.fromJson(
        data['remote'],
        name: DataCodec.childName(name, 'remote'),
      ),
      active: $active.fromJson(
        data['active'],
        name: DataCodec.childName(name, 'active'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Employee;
    return {
      'id': $id.toJson($$data.id),
      'personnelNumber': $personnelNumber.toJson($$data.personnelNumber),
      'firstName': $firstName.toJson($$data.firstName),
      'lastName': $lastName.toJson($$data.lastName),
      'email': $email.toJson($$data.email),
      'jobTitle': $jobTitle.toJson($$data.jobTitle),
      'department': $department.toJson($$data.department),
      'hiredAt': $hiredAt.toJson($$data.hiredAt),
      'hourlyCostRate': $hourlyCostRate.toJson($$data.hourlyCostRate),
      'weeklyHours': $weeklyHours.toJson($$data.weeklyHours),
      'skills': $skills.toJson($$data.skills),
      'languages': $languages.toJson($$data.languages),
      'managerId': $managerId.toJson($$data.managerId),
      'remote': $remote.toJson($$data.remote),
      'active': $active.toJson($$data.active),
    }..removeWhere((k, v) => v == null);
  }
}
