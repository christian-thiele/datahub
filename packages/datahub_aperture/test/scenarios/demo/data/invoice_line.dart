import 'package:datahub/data.dart';

import 'price_unit_type.dart';

part 'invoice_line.g.dart';

@Data()
class InvoiceLine extends $InvoiceLine {
  const InvoiceLine({
    required this.position,
    required this.description,
    this.sku,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.discount = 0,
    required this.taxRate,
  });

  @Meta(name: 'Pos.')
  final int position;

  final String description;

  @Meta(name: 'SKU')
  final String? sku;

  final double quantity;

  final PriceUnitType unit;

  @Meta(name: 'Unit price')
  final double unitPrice;

  @RangeConstraint(min: 0, max: 1)
  final double discount;

  @Meta(name: 'Tax rate')
  @RangeConstraint(min: 0, max: 0.3)
  final double taxRate;

  double get net => quantity * unitPrice * (1 - discount);

  double get tax => net * taxRate;
}
