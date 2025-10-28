import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:boost/boost.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';

import '../opentelemetry-dart/open_telemetry.dart' as otel;
import '../telemetry_scope.dart';

class OpenTelemetryTraceExporter extends TraceExporter {
  final _buffer = <LocalSpan>[];
  int _lastSendBufferSize = 0;

  final String host;
  final int port;
  final io.SecurityContext? securityContext;
  final Duration sendInterval;
  final Duration sendIntervalJitter;
  final int maxBatchSize;
  final int maxBufferSize;
  late final int warningBufferSize = (maxBufferSize * 0.9).toInt();
  final Map<String, dynamic> resourceAttributes;

  final _sendSemaphore = Semaphore();
  late final otel.TraceServiceClient _client;
  Timer? _timer;

  OpenTelemetryTraceExporter({
    required this.host,
    required this.port,
    required this.sendInterval,
    required this.sendIntervalJitter,
    this.securityContext,
    this.maxBatchSize = 500,
    this.maxBufferSize = 100000,
    this.resourceAttributes = const <String, dynamic>{},
  }) : assert(maxBatchSize > 0, 'maxBatchSize must be > 0'),
       assert(
         maxBufferSize > maxBatchSize,
         'maxBufferSize must be > maxBatchSize',
       ),
       assert(
         sendInterval > Duration.zero,
         'sendInterval must be > Duration.zero',
       );

  @override
  Future<void> initialize() async {
    _client = otel.TraceServiceClient(
      ClientChannel(
        host,
        port: port,
        options: ChannelOptions(credentials: ChannelCredentials.insecure()),
        channelShutdownHandler: () {
          log.warn('Trace client shut down...');
        },
      ),
    );
    _timer = Timer(sendInterval, _sendBatch);
  }

  @override
  Future<void> shutdown() async {
    _timer?.cancel();
    if (_buffer.isNotEmpty) {
      try {
        log('Flushing OTEL span buffer.');
        await _sendSemaphore.runLocked(() async {
          await _sendSpans(_buffer);
        });
      } catch (e, stack) {
        log.error('Could not send spans.', error: e, stack: stack);
      }
    }
  }

  @override
  void add(LocalSpan data) {
    _buffer.add(data);
    if (_buffer.length > maxBufferSize) {
      _buffer.removeAt(0);
    } else if (_buffer.length == warningBufferSize) {
      log.warn('Approaching trace buffer cap. Trace data may be dropped soon.');
    }
  }

  @override
  void close() {
    // ignored
  }

  void _sendBatch() async {
    if (_buffer.isEmpty) {
      return;
    }

    await _sendSemaphore.throttle(() async {
      if (_buffer.length - _lastSendBufferSize > maxBatchSize) {
        log.warn(
          'Trace buffer size is increasing faster than it is being sent. Consider increasing maxBatchSize or decreasing sendInterval.',
        );
      }

      final bufferSize = math.min(_buffer.length, maxBatchSize);
      final buffer = _buffer.sublist(0, bufferSize);
      _buffer.removeRange(0, bufferSize);

      try {
        await _sendSpans(buffer);
      } catch (e, stack) {
        log.warn('Could not send traces.', error: e, stack: stack);
        if ((_buffer.length + buffer.length) <= maxBufferSize) {
          // put back
          _buffer.insertAll(0, buffer);
        } else {
          log.warn('Trace buffer size exceeds maxBufferSize, dropping batch.');
        }
      }
      _lastSendBufferSize = _buffer.length;
    });

    _timer = Timer(sendInterval.jitter(sendIntervalJitter), _sendBatch);
  }

  otel.ScopeSpans _toOtelScopeSpans(
    TelemetryScope scope,
    List<LocalSpan> spans,
  ) {
    return otel.ScopeSpans(
      scope: _toOtelScope(scope),
      spans: spans.map(_toOtelSpan).toList(),
    );
  }

  otel.InstrumentationScope _toOtelScope(TelemetryScope scope) {
    return otel.InstrumentationScope(
      name: scope.name,
      version: scope.version,
      attributes: _toOtelKeyValues(scope.attributes),
      droppedAttributesCount: 0,
    );
  }

  otel.Span _toOtelSpan(LocalSpan span) {
    return otel.Span(
      name: span.name,
      traceId: span.traceId.bytes,
      parentSpanId: span.parent?.spanId.bytes,
      spanId: span.spanId.bytes,
      kind: _toOtelSpanKind(span.type),
      status: switch (span) {
        LocalSpan(hasError: true) => otel.Status(
          code: otel.Status_StatusCode.STATUS_CODE_ERROR,
        ),
        LocalSpan(endTimestamp: DateTime()) => otel.Status(
          code: otel.Status_StatusCode.STATUS_CODE_OK,
        ),
        _ => otel.Status(code: otel.Status_StatusCode.STATUS_CODE_UNSET),
      },
      //TODO error message
      startTimeUnixNano: span.startTimestamp?.nanosecondsSinceEpochInt64,
      endTimeUnixNano: span.endTimestamp?.nanosecondsSinceEpochInt64,
      attributes: _toOtelKeyValues(span.attributes),
      droppedAttributesCount: 0,
      events: _toOtelSpanEvents(span.events),
      droppedEventsCount: 0,
    );
  }

  List<otel.KeyValue> _toOtelKeyValues(Map<String, dynamic> map) {
    return map.entries
        .map((e) => otel.KeyValue(key: e.key, value: _toOtelAnyValue(e.value)))
        .toList();
  }

  List<otel.AnyValue> _toOtelArray(List<dynamic> list) {
    return list.map(_toOtelAnyValue).toList();
  }

  otel.AnyValue _toOtelAnyValue(dynamic value) {
    return switch (value) {
      null => otel.AnyValue(),
      String v => otel.AnyValue(stringValue: v),
      int v => otel.AnyValue(intValue: Int64(v)),
      Int64 v => otel.AnyValue(intValue: v),
      double v => otel.AnyValue(doubleValue: v),
      bool v => otel.AnyValue(boolValue: v),
      List<int> v => otel.AnyValue(bytesValue: v),
      List<dynamic> v => otel.AnyValue(
        arrayValue: otel.ArrayValue(values: _toOtelArray(v)),
      ),
      Map<String, dynamic> v => otel.AnyValue(
        kvlistValue: otel.KeyValueList(values: _toOtelKeyValues(v)),
      ),
      Object v => otel.AnyValue(stringValue: v.toString()),
    };
  }

  otel.Span_SpanKind _toOtelSpanKind(SpanType? type) {
    return switch (type) {
      SpanType.internal => otel.Span_SpanKind.SPAN_KIND_INTERNAL,
      SpanType.server => otel.Span_SpanKind.SPAN_KIND_SERVER,
      SpanType.client => otel.Span_SpanKind.SPAN_KIND_CLIENT,
      SpanType.producer => otel.Span_SpanKind.SPAN_KIND_PRODUCER,
      SpanType.consumer => otel.Span_SpanKind.SPAN_KIND_CONSUMER,
      null => otel.Span_SpanKind.SPAN_KIND_UNSPECIFIED,
    };
  }

  List<otel.Span_Event> _toOtelSpanEvents(Iterable<Event> events) {
    return events.map(_toOtelSpanEvent).toList();
  }

  otel.Span_Event _toOtelSpanEvent(Event event) {
    return otel.Span_Event(
      name: event.name,
      timeUnixNano: event.timestamp.nanosecondsSinceEpochInt64,
      attributes: _toOtelKeyValues(event.attributes),
      droppedAttributesCount: 0,
    );
  }

  Future<void> _sendSpans(List<LocalSpan> spans) async {
    final groups = spans.groupBy((e) => e.tracer.key);
    final request = otel.ExportTraceServiceRequest(
      resourceSpans: [
        otel.ResourceSpans(
          resource: otel.Resource(
            attributes: _toOtelKeyValues(resourceAttributes),
            droppedAttributesCount: 0,
          ),
          scopeSpans: [
            ...groups.values.map(
              (spans) => _toOtelScopeSpans(spans.first.tracer, spans),
            ),
          ],
        ),
      ],
    );

    await _client.export(request);
  }
}
