// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_workflow.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceWorkflow with DataObject<ResourceWorkflow> {
  const $ResourceWorkflow();
  static const $$codec = JsonDataCodec();
  static final $stateField = DataField<ResourceWorkflow, String>(
    name: 'stateField',
    valueOf: (p) => p.stateField,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $states = DataField<ResourceWorkflow, List<String>>(
    name: 'states',
    valueOf: (p) => p.states,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $writesHistory = DataField<ResourceWorkflow, bool>(
    name: 'writesHistory',
    valueOf: (p) => p.writesHistory,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $steps = DataField<ResourceWorkflow, List<ResourceWorkflowStep>>(
    name: 'steps',
    valueOf: (p) => p.steps,
    dataBean: () => $ResourceWorkflowStep.bean,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<ResourceWorkflowStep>(
          value,
          $ResourceWorkflowStep.bean.fromJson,
          name: name,
        ),
    toJson: (value) =>
        $$codec.encodeList<ResourceWorkflowStep>(value, (v) => v.toJson()),
  );

  static final $signals =
      DataField<ResourceWorkflow, List<ResourceWorkflowSignal>>(
        name: 'signals',
        valueOf: (p) => p.signals,
        dataBean: () => $ResourceWorkflowSignal.bean,
        fromJson: (value, {String? name}) =>
            $$codec.decodeList<ResourceWorkflowSignal>(
              value,
              $ResourceWorkflowSignal.bean.fromJson,
              name: name,
            ),
        toJson: (value) => $$codec.encodeList<ResourceWorkflowSignal>(
          value,
          (v) => v.toJson(),
        ),
      );

  static final DataBean<ResourceWorkflow> bean = DataBean<ResourceWorkflow>(
    name: 'ResourceWorkflow',
    fields: List<DataField<ResourceWorkflow, dynamic>>.unmodifiable([
      $stateField,
      $states,
      $writesHistory,
      $steps,
      $signals,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceWorkflow, dynamic>> get $$fields => bean.fields;
  ResourceWorkflow copyWith({
    String? stateField,
    List<String>? states,
    bool? writesHistory,
    List<ResourceWorkflowStep>? steps,
    List<ResourceWorkflowSignal>? signals,
  }) {
    final $data = this as ResourceWorkflow;
    return ResourceWorkflow(
      stateField: stateField ?? $data.stateField,
      states: states ?? $data.states,
      writesHistory: writesHistory ?? $data.writesHistory,
      steps: steps ?? $data.steps,
      signals: signals ?? $data.signals,
    );
  }

  static ResourceWorkflow fromValues(Map<String, dynamic> data) {
    return ResourceWorkflow(
      stateField: data['stateField'],
      states: data['states']?.cast<String>().toList(growable: false),
      writesHistory: data['writesHistory'],
      steps: data['steps']?.cast<ResourceWorkflowStep>().toList(
        growable: false,
      ),
      signals: data['signals']?.cast<ResourceWorkflowSignal>().toList(
        growable: false,
      ),
    );
  }

  static ResourceWorkflow fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceWorkflow,
        data.runtimeType,
        name,
      );
    }
    return ResourceWorkflow(
      stateField: $stateField.fromJson(
        data['stateField'],
        name: DataCodec.childName(name, 'stateField'),
      ),
      states: $states.fromJson(
        data['states'],
        name: DataCodec.childName(name, 'states'),
      ),
      writesHistory: $writesHistory.fromJson(
        data['writesHistory'],
        name: DataCodec.childName(name, 'writesHistory'),
      ),
      steps: $steps.fromJson(
        data['steps'],
        name: DataCodec.childName(name, 'steps'),
      ),
      signals: $signals.fromJson(
        data['signals'],
        name: DataCodec.childName(name, 'signals'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceWorkflow;
    return {
      'stateField': $stateField.toJson($$data.stateField),
      'states': $states.toJson($$data.states),
      'writesHistory': $writesHistory.toJson($$data.writesHistory),
      'steps': $steps.toJson($$data.steps),
      'signals': $signals.toJson($$data.signals),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $ResourceWorkflowStep
    with DataObject<ResourceWorkflowStep> {
  const $ResourceWorkflowStep();
  static const $$codec = JsonDataCodec();
  static final $name = DataField<ResourceWorkflowStep, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $kind = DataField<ResourceWorkflowStep, WorkflowStepKind>(
    name: 'kind',
    valueOf: (p) => p.kind,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, WorkflowStepKind.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: WorkflowStepKind.values)],
  );

  static final $state = DataField<ResourceWorkflowStep, String?>(
    name: 'state',
    valueOf: (p) => p.state,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $after = DataField<ResourceWorkflowStep, Duration?>(
    name: 'after',
    valueOf: (p) => p.after,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDuration, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDuration),
  );

  static final $scheduled = DataField<ResourceWorkflowStep, bool>(
    name: 'scheduled',
    valueOf: (p) => p.scheduled,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $accept = DataField<ResourceWorkflowStep, List<String>>(
    name: 'accept',
    valueOf: (p) => p.accept,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $signal = DataField<ResourceWorkflowStep, String?>(
    name: 'signal',
    valueOf: (p) => p.signal,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $failureState = DataField<ResourceWorkflowStep, String?>(
    name: 'failureState',
    valueOf: (p) => p.failureState,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<ResourceWorkflowStep> bean =
      DataBean<ResourceWorkflowStep>(
        name: 'ResourceWorkflowStep',
        fields: List<DataField<ResourceWorkflowStep, dynamic>>.unmodifiable([
          $name,
          $kind,
          $state,
          $after,
          $scheduled,
          $accept,
          $signal,
          $failureState,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceWorkflowStep, dynamic>> get $$fields => bean.fields;
  ResourceWorkflowStep copyWith({
    String? name,
    WorkflowStepKind? kind,
    String? state,
    bool nullState = false,
    Duration? after,
    bool nullAfter = false,
    bool? scheduled,
    List<String>? accept,
    String? signal,
    bool nullSignal = false,
    String? failureState,
    bool nullFailureState = false,
  }) {
    final $data = this as ResourceWorkflowStep;
    return ResourceWorkflowStep(
      name: name ?? $data.name,
      kind: kind ?? $data.kind,
      state: nullState ? null : (state ?? $data.state),
      after: nullAfter ? null : (after ?? $data.after),
      scheduled: scheduled ?? $data.scheduled,
      accept: accept ?? $data.accept,
      signal: nullSignal ? null : (signal ?? $data.signal),
      failureState: nullFailureState
          ? null
          : (failureState ?? $data.failureState),
    );
  }

  static ResourceWorkflowStep fromValues(Map<String, dynamic> data) {
    return ResourceWorkflowStep(
      name: data['name'],
      kind: data['kind'],
      state: data['state'],
      after: data['after'],
      scheduled: data['scheduled'] ?? false,
      accept:
          data['accept']?.cast<String>().toList(growable: false) ?? const [],
      signal: data['signal'],
      failureState: data['failureState'],
    );
  }

  static ResourceWorkflowStep fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceWorkflowStep,
        data.runtimeType,
        name,
      );
    }
    return ResourceWorkflowStep(
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      kind: $kind.fromJson(
        data['kind'],
        name: DataCodec.childName(name, 'kind'),
      ),
      state: $state.fromJson(
        data['state'],
        name: DataCodec.childName(name, 'state'),
      ),
      after: $after.fromJson(
        data['after'],
        name: DataCodec.childName(name, 'after'),
      ),
      scheduled: $scheduled.fromJson(
        data['scheduled'],
        name: DataCodec.childName(name, 'scheduled'),
      ),
      accept: $accept.fromJson(
        data['accept'],
        name: DataCodec.childName(name, 'accept'),
      ),
      signal: $signal.fromJson(
        data['signal'],
        name: DataCodec.childName(name, 'signal'),
      ),
      failureState: $failureState.fromJson(
        data['failureState'],
        name: DataCodec.childName(name, 'failureState'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceWorkflowStep;
    return {
      'name': $name.toJson($$data.name),
      'kind': $kind.toJson($$data.kind),
      'state': $state.toJson($$data.state),
      'after': $after.toJson($$data.after),
      'scheduled': $scheduled.toJson($$data.scheduled),
      'accept': $accept.toJson($$data.accept),
      'signal': $signal.toJson($$data.signal),
      'failureState': $failureState.toJson($$data.failureState),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $ResourceWorkflowSignal
    with DataObject<ResourceWorkflowSignal> {
  const $ResourceWorkflowSignal();
  static const $$codec = JsonDataCodec();
  static final $action = DataField<ResourceWorkflowSignal, ResourceAction>(
    name: 'action',
    valueOf: (p) => p.action,
    dataBean: () => $ResourceAction.bean,
    fromJson: (value, {String? name}) =>
        $ResourceAction.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final $accept = DataField<ResourceWorkflowSignal, List<String>>(
    name: 'accept',
    valueOf: (p) => p.accept,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final DataBean<ResourceWorkflowSignal> bean =
      DataBean<ResourceWorkflowSignal>(
        name: 'ResourceWorkflowSignal',
        fields: List<DataField<ResourceWorkflowSignal, dynamic>>.unmodifiable([
          $action,
          $accept,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceWorkflowSignal, dynamic>> get $$fields => bean.fields;
  ResourceWorkflowSignal copyWith({
    ResourceAction? action,
    List<String>? accept,
  }) {
    final $data = this as ResourceWorkflowSignal;
    return ResourceWorkflowSignal(
      action: action ?? $data.action,
      accept: accept ?? $data.accept,
    );
  }

  static ResourceWorkflowSignal fromValues(Map<String, dynamic> data) {
    return ResourceWorkflowSignal(
      action: data['action'],
      accept: data['accept']?.cast<String>().toList(growable: false),
    );
  }

  static ResourceWorkflowSignal fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceWorkflowSignal,
        data.runtimeType,
        name,
      );
    }
    return ResourceWorkflowSignal(
      action: $action.fromJson(
        data['action'],
        name: DataCodec.childName(name, 'action'),
      ),
      accept: $accept.fromJson(
        data['accept'],
        name: DataCodec.childName(name, 'accept'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceWorkflowSignal;
    return {
      'action': $action.toJson($$data.action),
      'accept': $accept.toJson($$data.accept),
    }..removeWhere((k, v) => v == null);
  }
}
