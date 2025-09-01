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

  @Meta(name: 'City ID')
  @RelationId<City>()
  final int cityId;

  @Meta(name: 'State Code')
  final String stateCode;

  @Meta(name: 'Country Code')
  final String countryCode;

  const Zone({
    required this.id,
    required this.cityId,
    required this.stateCode,
    required this.countryCode,
  });

  static DataBean<Zone> get bean => _Zone.bean;
}
