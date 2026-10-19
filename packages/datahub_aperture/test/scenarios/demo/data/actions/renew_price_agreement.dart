import 'package:datahub/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'renew_price_agreement.g.dart';

@Data()
@Meta(name: 'Renew price agreement', icon: Icons.autorenew)
class const RenewPriceAgreement({
  @Meta(
    name: 'Valid from',
    description: 'The current agreement ends when the new one starts.',
  )
  required final DateTime validFrom,
  @Meta(description: 'Net price per unit of the new agreement.')
  @RangeConstraint(min: 0, max: 1000000)
  required final double price,
}) extends $RenewPriceAgreement;
