import 'package:datahub/datahub.dart';

part 'license_object.g.dart';

@Data()
class LicenseObject extends $LicenseObject {
  final String name;
  final String? url;

  const LicenseObject({required this.name, this.url});
}
