import 'package:grpc/grpc.dart';
import 'package:meta/meta.dart';

import '../opentelemetry-dart/open_telemetry.dart' as otel;
import '../otlp/otlp_batch_exporter.dart';
import '../otlp/otlp_mapping.dart';
import '../telemetry_scope.dart';
import 'log_exporter.dart';
import 'log_message.dart';

/// Exports log messages to an OpenTelemetry collector via OTLP/gRPC.
///
/// Labels are exported as attributes, the error and stack trace as
/// `exception.*` attributes, and the span of the message as trace context.
class OpenTelemetryLogExporter extends OtlpBatchExporter<LogMessage>
    implements LogExporter {
  final Map<String, Object?> resourceAttributes;
  final TelemetryScope scope;
  final otel.LogsServiceClient _client;

  OpenTelemetryLogExporter({
    required ClientChannel channel,
    required super.exportInterval,
    required super.exportIntervalJitter,
    required this.scope,
    super.exportTimeout,
    super.maxBatchSize,
    super.maxBufferSize,
    this.resourceAttributes = const {},
  }) : _client = otel.LogsServiceClient(channel),
       super(signal: 'logs');

  @override
  Future<void> initialize() async => start();

  @override
  void add(LogMessage message) => enqueue(message);

  @override
  Future<void> export(List<LogMessage> batch) =>
      send(otlpLogsRequest(resourceAttributes, scope, batch));

  /// Sends [request] to the collector.
  @protected
  Future<void> send(otel.ExportLogsServiceRequest request) =>
      _client.export(request);
}
