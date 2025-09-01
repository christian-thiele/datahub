import 'package:datahub/data.dart';
import 'package:datahub_aperture/icons.dart';

part 'zone.g.dart';

@Data()
@Meta(name: 'Zone', namePlural: 'Zones', icon: Icons.location_searching)
class Zone extends _Zone {
  @Id()
  final String id;

  @Meta(name: 'City ID')
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
