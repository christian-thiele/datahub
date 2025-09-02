import 'dart:typed_data';

import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'zone.dart';

part 'city.g.dart';

@Data()
@Meta(name: 'City', namePlural: 'Cities', icon: Icons.location_city)
@ApertureRelation<Zone>()
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

  @Meta(name: 'Coat of Arms')
  final Uint8List badge;

  @Meta(name: 'Location')
  @ApertureField(readOnly: true)
  final Geometry location;

  @Meta(name: 'Client IDs')
  final List<String> clientIds;

  const City({
    this.id = 0,
    required this.name,
    this.enabled = false,
    required this.badge,
    required this.location,
    required this.clientIds,
  });

  static DataBean<City> get bean => _City.bean;
}
