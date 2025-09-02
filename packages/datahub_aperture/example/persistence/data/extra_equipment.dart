import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';

import 'facility.dart';
import 'general.dart';
import 'payment.dart';
import 'security.dart';

part 'extra_equipment.g.dart';

@Data()
class ExtraEquipment extends _ExtraEquipment {
  @ApertureField(enumValues: General.values)
  final List<General> general;

  @ApertureField(enumValues: Facility.values)
  final List<Facility> facility;

  @ApertureField(enumValues: Security.values)
  final List<Security> security;

  @ApertureField(enumValues: Payment.values)
  final List<Payment> payment;

  const ExtraEquipment({
    required this.general,
    required this.facility,
    required this.security,
    required this.payment,
  });

  static DataBean<ExtraEquipment> get bean => _ExtraEquipment.bean;
}
