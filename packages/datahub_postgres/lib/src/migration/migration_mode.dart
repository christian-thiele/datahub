/// What a service does about migrations when the application starts.
enum MigrationMode {
  /// Do nothing.
  ///
  /// Use this when migrations are applied by a separate step - a deploy job or
  /// an init container running `datahub migrate apply` - and the application
  /// itself should never touch the schema.
  none,

  /// Verify that the database is at the head of the migration history and fail
  /// startup if it is not.
  ///
  /// This is the default: an application that starts against a database it was
  /// not built for fails loudly instead of failing later, one query at a time.
  validate,

  /// Apply every pending migration before the application starts.
  ///
  /// Migrations run under an advisory lock, so only one instance migrates even
  /// when several start at once.
  apply,
}
