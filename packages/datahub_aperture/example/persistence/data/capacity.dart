import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/data.dart';

import 'parking_space_type.dart';

part 'capacity.g.dart';

@Data()
class Capacity extends _Capacity {
  @Meta(name: 'Type')
  @ApertureField(enumValues: ParkingSpaceType.values)
  final ParkingSpaceType parkingSpaceType;

  final int? capacity;

  const Capacity({
    required this.parkingSpaceType,
    required this.capacity,
  });
}
