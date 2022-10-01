/// Defines how the [SchedulerService] should behave when a task is
/// scheduled to run while a previous execution of the same task
/// has not completed yet.
enum OverlapBehaviour {
  /// Skip scheduled execution when previous has not completed yet.
  throttle,

  /// Execute task regardless of any previous executions.
  concurrent
}
