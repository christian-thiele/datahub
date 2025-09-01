import 'package:datahub/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_display_field.dart';
import 'package:datahub_aperture/src/data/meta/aperture_field.dart';

part 'city.g.dart';

@Data()
@Meta(name: 'City', namePlural: 'Cities', icon: Icons.location_city)
class City extends _City {
  @Id()
  @Meta(name: 'ID')
  @ApertureField(readOnly: true)
  final int id;

  @ApertureDisplayField()
  @Meta(name: 'Name')
  final String name;

  @Meta(name: 'Enabled', description: 'Show in PARCO App')
  final bool enabled;

  const City({
    this.id = 0,
    required this.name,
    this.enabled = false,
  });

  static DataBean<City> get bean => _City.bean;
}
