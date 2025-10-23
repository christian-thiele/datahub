import 'package:datahub/datahub.dart';

import 'contact_object.dart';
import 'license_object.dart';

part 'info_object.g.dart';

@Data()
class InfoObject extends $InfoObject {
  final String title;
  final String? description;
  final String? termsOfService;
  final ContactObject? contact;
  final LicenseObject? license;
  final String version;

  const InfoObject({
    required this.title,
    this.description,
    this.termsOfService,
    this.contact,
    this.license,
    required this.version,
  });
}
