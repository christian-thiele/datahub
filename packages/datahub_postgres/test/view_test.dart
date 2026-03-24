import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

void main() {
  declareTest(
    'Postgresql View Repository',
    [
      PostgresqlService(
        database: Config.value('datahub_postgres'),
        username: Config.value('postgres'),
        password: Config.value('postgres'),
        useSsl: Config.value(false),
      ),
    ],
    () async {
      final postgres = Find<Postgresql>().find();
      await postgres.useConnection((connection) async {
        await connection.runTransaction((context) async {
          final result = await postgres.useConnection((connection) async {
            return await connection.runTransaction((context) async {
              return await context.execute(
                SqlSelect(SqlQualifiedRelation('view_test', 'specials'), [
                  const SqlWildcard(),
                ]),
              );
            });
          });

          print('${result.length} results');
          for (final row in result) {
            print(row);
          }
        });
      });
    },
  );
}
