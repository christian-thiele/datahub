import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';

/// A [Service] whose relations are managed by a [PostgresqlMigrationService].
///
/// The migration service reads the declarations of the services it owns to
/// derive the schema the application expects, which is why this describes the
/// relations without building or initializing anything.
abstract interface class PostgresqlSchemaOwner implements Service {
  /// The schema the relations live in.
  Config<String> get schemaName;

  /// An override for the relation name, if any.
  Config<String?> get relationName;

  /// The relations this service expects to exist, in creation order.
  List<PostgresqlRelation> buildRelations(
    String schemaName,
    String? relationName,
  );
}

/// Access to the migration system from services whose schema it manages.
abstract interface class PostgresqlMigrations {
  /// Whether [qualifiedName] (`schema.relation`) is created and kept up to
  /// date by migrations.
  ///
  /// A repository whose relation is managed does not create it at startup -
  /// doing so would silently produce a table that no migration describes.
  bool manages(String qualifiedName);
}
