import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'client.dart';
import 'price_unit_type.dart';
import 'product_category.dart';
import 'time_entry.dart';

part 'product.g.dart';

/// A billable service or item as agreed upon with a specific client.
@Data()
@Meta(
  name: 'Price agreement',
  namePlural: 'Price agreements',
  icon: Icons.request_quote,
  description: 'Client specific products and services with agreed prices.',
)
@ApertureMeta(titleTemplate: '{{ title }}')
@ApertureRelation<TimeEntry>()
class const Product({
  @Id(auto: true) final String id = '',
  @ApertureField(isDisplayField: true)
  @Meta(name: 'SKU')
  @RegExpConstraint(expression: r'^[A-Z]{3}-[A-Z0-9]{2,6}-\d{5}$')
  required final String sku,
  @ApertureField(isDisplayField: true)
  @MaxLengthConstraint(length: 120)
  required final String title,
  @ApertureField(allowFilter: false, allowSort: false)
  @MaxLengthConstraint(length: 1000)
  final String? description,
  required final ProductCategory category,
  @ApertureField(isDisplayField: true)
  @Meta(description: 'Net price per unit, before discount.')
  @RangeConstraint(min: 0, max: 1000000)
  required final double price,
  required final PriceUnitType unit,
  @Meta(name: 'Tax rate', description: 'Fraction, e.g. 0.19 for 19 %.')
  @RangeConstraint(min: 0, max: 0.3)
  final double taxRate = 0.19,
  @Meta(description: 'Negotiated discount as fraction, e.g. 0.1 for 10 %.')
  @RangeConstraint(min: 0, max: 0.5)
  final double discount = 0,
  @Meta(name: 'Valid from') required final DateTime validFrom,
  @Meta(name: 'Valid until') final DateTime? validUntil,
  @Meta(name: 'Client') @RelationId<Client>() required final int clientId,
  final bool active = true,
}) extends $Product;
