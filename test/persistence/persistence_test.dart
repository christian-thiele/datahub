import 'package:cl_datahub/src/persistence/postgresql/postgresql_database_adapter.dart';
import 'package:test/test.dart';

void main() {
  test('Persistence', _testPersistence);
}

Future _testPersistence() async {
  final adapter = PostgreSQLDatabaseAdapter('127.0.0.1', 5432, 'postgres',
      username: 'postgres', password: 'mysecretpassword');

  final connection = await adapter.openConnection();

  expect(connection.isOpen, isTrue);

}
