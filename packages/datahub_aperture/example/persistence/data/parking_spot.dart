import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/icons.dart';

import 'zone.dart';

part 'parking_spot.g.dart';

@Data()
@Meta(name: 'Parking Spot', namePlural: 'Parking Spots', icon: Icons.pin_drop)
class ParkingSpot extends _ParkingSpot {
  @Id()
  @Meta(name: 'Poi ID')
  final String id;

  @RelationId<Zone>()
  @Meta(name: 'Zone ID')
  final String zoneId;

  @Meta(name: 'Name')
  final String name;

  @Meta(name: 'Adresse')
  final String address;

  const ParkingSpot({
    required this.id,
    required this.zoneId,
    required this.name,
    required this.address,
  });

  static DataBean<ParkingSpot> get bean => _ParkingSpot.bean;
}
