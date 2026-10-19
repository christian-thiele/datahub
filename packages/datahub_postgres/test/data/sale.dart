import 'package:datahub/data.dart';

part 'sale.g.dart';

@Data()
class const Sale({
  @Id(auto: true) final int id = 0,
  required final String region,
  required final int quantity,
  required final double price,
}) extends $Sale;
