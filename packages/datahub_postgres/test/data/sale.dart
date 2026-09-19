import 'package:datahub/data.dart';

part 'sale.g.dart';

@Data()
class Sale extends $Sale {
  @Id(auto: true)
  final int id;
  final String region;
  final int quantity;
  final double price;

  const Sale({
    this.id = 0,
    required this.region,
    required this.quantity,
    required this.price,
  });
}
