import 'package:datahub/data.dart';

@Data()
class ExtraEquipment extends _ExtraEquipment {
  final List<General> general;
  final List<Facility> facility;
  final List<Security> security;
  final List<Payment> payment;

  ExtraEquipment({
    required this.general,
    required this.facility,
    required this.security,
    required this.payment,
  });
}
