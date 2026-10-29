import 'package:datahub/datahub.dart';

part 'point_of_interest.g.dart';

enum PointOfInterestType() {
  generic,
  restaurant,
  gasStation,
  shop,
}

@Data()
class const PointOfInterest({
  @Id(auto: true) final int id = 0,
  required final String name,
  final PointOfInterestType type = PointOfInterestType.generic,
  final Geometry location = const GeometryCollection.empty(),
}) extends $PointOfInterest;
