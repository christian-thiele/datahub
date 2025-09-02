import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'capacity.dart';
import 'parking_spot_type.dart';
import 'zone.dart';

part 'parking_spot.g.dart';

@Data()
@Meta(name: 'Parking Spot', namePlural: 'Parking Spots', icon: Icons.pin_drop)
class ParkingSpot extends _ParkingSpot {
  @Id()
  @Meta(name: 'Poi ID')
  final String id;

  @ApertureDisplayField()
  final String name;

  @ApertureField(enumValues: ParkingSpotType.values)
  final ParkingSpotType type;


  final String clientId;

  @RelationId<Zone>()
  final String zoneId;
  final String address;
  final List<Capacity> capacity;
  final ExtraEquipment extraEquipment;

  final List<String> context;

  @Meta(name: 'Location')
  final Geometry geometry;

  const ParkingSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.clientId,
    required this.zoneId,
    required this.address,
    required this.capacity,
    required this.extraEquipment,
    required this.context,
    required this.geometry,
  });

  static DataBean<ParkingSpot> get bean => _ParkingSpot.bean;
}
