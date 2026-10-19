import 'package:datahub/data.dart';

import 'price_unit_type.dart';

part 'invoice_line.g.dart';

@Data()
class const InvoiceLine({
  @Meta(name: 'Pos.') required final int position,
  required final String description,
  @Meta(name: 'SKU') final String? sku,
  required final double quantity,
  required final PriceUnitType unit,
  @Meta(name: 'Unit price') required final double unitPrice,
  @RangeConstraint(min: 0, max: 1) final double discount = 0,
  @Meta(name: 'Tax rate')
  @RangeConstraint(min: 0, max: 0.3)
  required final double taxRate,
}) extends $InvoiceLine {
  double get net => quantity * unitPrice * (1 - discount);

  double get tax => net * taxRate;
}
