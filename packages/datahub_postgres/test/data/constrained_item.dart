import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

part 'constrained_item.g.dart';

@Data()
class ConstrainedItem extends $ConstrainedItem {
  /// Explicit primary key constraint overrides the one derived from [Id].
  @Id(auto: true)
  @PrimaryKeyConstraint(auto: false)
  final int id;

  @UniqueConstraint()
  final String code;

  @DefaultConstraint(RawSql('now()'))
  final DateTime? createdAt;

  /// Explicit not null on a nullable field type.
  @NotNullConstraint()
  @DefaultConstraint(RawSql('0'))
  final int? counter;

  final String? note;

  const ConstrainedItem({
    required this.id,
    required this.code,
    this.createdAt,
    this.counter,
    this.note,
  });
}
