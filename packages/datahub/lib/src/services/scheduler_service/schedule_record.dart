import 'package:datahub/data.dart';

part 'schedule_record.g.dart';

/// The state of a `Schedule`, shared by all instances of an application.
///
/// The scheduler claims a run by moving [nextRunAt] forward with a conditional
/// update, so each time is run by exactly one instance.
@Data()
class ScheduleRecord extends $ScheduleRecord {
  /// The name of the schedule.
  @Id()
  final String id;

  /// When the schedule runs next (UTC).
  final DateTime nextRunAt;

  /// The time the last run was scheduled for.
  final DateTime? lastScheduledFor;

  final DateTime? lastStartedAt;
  final DateTime? lastFinishedAt;

  /// The error of the last run, null if it succeeded.
  final String? lastError;

  /// What the last run logged, one JSON object per line (see
  /// `LogMessage.toJsonLine`).
  final List<String> lastMessages;

  const ScheduleRecord({
    required this.id,
    required this.nextRunAt,
    this.lastScheduledFor,
    this.lastStartedAt,
    this.lastFinishedAt,
    this.lastError,
    this.lastMessages = const [],
  });
}
