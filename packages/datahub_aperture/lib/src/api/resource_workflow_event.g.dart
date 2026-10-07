// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_workflow_event.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ResourceWorkflowEvent
    with DataObject<ResourceWorkflowEvent> {
  const $ResourceWorkflowEvent();
  static const $$codec = JsonDataCodec();
  static final $event = DataField<ResourceWorkflowEvent, WorkflowEvent>(
    name: 'event',
    valueOf: (p) => p.event,
    dataBean: () => $WorkflowEvent.bean,
    fromJson: (value, {String? name}) =>
        $WorkflowEvent.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final $running = DataField<ResourceWorkflowEvent, bool>(
    name: 'running',
    valueOf: (p) => p.running,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final DataBean<ResourceWorkflowEvent> bean =
      DataBean<ResourceWorkflowEvent>(
        name: 'ResourceWorkflowEvent',
        fields: List<DataField<ResourceWorkflowEvent, dynamic>>.unmodifiable([
          $event,
          $running,
        ]),
        fromValues: fromValues,
        fromJson: fromJson,
      );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceWorkflowEvent, dynamic>> get $$fields => bean.fields;
  ResourceWorkflowEvent copyWith({WorkflowEvent? event, bool? running}) {
    final $data = this as ResourceWorkflowEvent;
    return ResourceWorkflowEvent(
      event: event ?? $data.event,
      running: running ?? $data.running,
    );
  }

  static ResourceWorkflowEvent fromValues(Map<String, dynamic> data) {
    return ResourceWorkflowEvent(
      event: data['event'],
      running: data['running'],
    );
  }

  static ResourceWorkflowEvent fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceWorkflowEvent,
        data.runtimeType,
        name,
      );
    }
    return ResourceWorkflowEvent(
      event: $event.fromJson(
        data['event'],
        name: DataCodec.childName(name, 'event'),
      ),
      running: $running.fromJson(
        data['running'],
        name: DataCodec.childName(name, 'running'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceWorkflowEvent;
    return {
      'event': $event.toJson($$data.event),
      'running': $running.toJson($$data.running),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $ResourceWorkflowEventsResponse
    with DataObject<ResourceWorkflowEventsResponse> {
  const $ResourceWorkflowEventsResponse();
  static const $$codec = JsonDataCodec();
  static final $hasNextPage = DataField<ResourceWorkflowEventsResponse, bool>(
    name: 'hasNextPage',
    valueOf: (p) => p.hasNextPage,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $data =
      DataField<ResourceWorkflowEventsResponse, List<ResourceWorkflowEvent>>(
        name: 'data',
        valueOf: (p) => p.data,
        dataBean: () => $ResourceWorkflowEvent.bean,
        fromJson: (value, {String? name}) =>
            $$codec.decodeList<ResourceWorkflowEvent>(
              value,
              $ResourceWorkflowEvent.bean.fromJson,
              name: name,
            ),
        toJson: (value) =>
            $$codec.encodeList<ResourceWorkflowEvent>(value, (v) => v.toJson()),
      );

  static final DataBean<ResourceWorkflowEventsResponse>
  bean = DataBean<ResourceWorkflowEventsResponse>(
    name: 'ResourceWorkflowEventsResponse',
    fields:
        List<DataField<ResourceWorkflowEventsResponse, dynamic>>.unmodifiable([
          $hasNextPage,
          $data,
        ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ResourceWorkflowEventsResponse, dynamic>> get $$fields =>
      bean.fields;
  ResourceWorkflowEventsResponse copyWith({
    bool? hasNextPage,
    List<ResourceWorkflowEvent>? data,
  }) {
    final $data = this as ResourceWorkflowEventsResponse;
    return ResourceWorkflowEventsResponse(
      hasNextPage: hasNextPage ?? $data.hasNextPage,
      data: data ?? $data.data,
    );
  }

  static ResourceWorkflowEventsResponse fromValues(Map<String, dynamic> data) {
    return ResourceWorkflowEventsResponse(
      hasNextPage: data['hasNextPage'],
      data: data['data']?.cast<ResourceWorkflowEvent>().toList(growable: false),
    );
  }

  static ResourceWorkflowEventsResponse fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ResourceWorkflowEventsResponse,
        data.runtimeType,
        name,
      );
    }
    return ResourceWorkflowEventsResponse(
      hasNextPage: $hasNextPage.fromJson(
        data['hasNextPage'],
        name: DataCodec.childName(name, 'hasNextPage'),
      ),
      data: $data.fromJson(
        data['data'],
        name: DataCodec.childName(name, 'data'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ResourceWorkflowEventsResponse;
    return {
      'hasNextPage': $hasNextPage.toJson($$data.hasNextPage),
      'data': $data.toJson($$data.data),
    }..removeWhere((k, v) => v == null);
  }
}
