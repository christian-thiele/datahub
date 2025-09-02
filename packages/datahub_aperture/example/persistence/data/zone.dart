import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'city.dart';
import 'parking_spot.dart';

part 'zone.g.dart';

@Data()
@Meta(name: 'Zone', namePlural: 'Zones', icon: Icons.location_searching)
@ApertureRelation<ParkingSpot>()
class Zone extends _Zone {
  @Id()
  @Meta(name: 'Zone ID')
  final String id;

  @Meta(name: 'Client ID')
  final String clientId;

  @Meta(name: 'City ID')
  @RelationId<City>()
  final int cityId;

  @Meta(name: 'Payable per App')
  final bool payablePerApp;

  @Meta(name: 'Service Fee')
  final bool withParcoServiceFee;

  @Meta(name: 'Country Code')
  @Validation(length: 2)
  final String countryCode;

  @Meta(name: 'State Code')
  @Validation(length: 2)
  final String stateCode;

  @Meta(name: 'Vignette Required')
  final bool vignette;

  const Zone({
    required this.id,
    required this.clientId,
    required this.cityId,
    required this.payablePerApp,
    required this.withParcoServiceFee,
    required this.countryCode,
    required this.stateCode,
    required this.vignette,
  });

  static DataBean<Zone> get bean => _Zone.bean;
}
