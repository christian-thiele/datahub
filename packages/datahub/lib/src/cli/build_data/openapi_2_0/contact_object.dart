import 'package:datahub/datahub.dart';

part 'contact_object.g.dart';

@Data()
class ContactObject extends $ContactObject {
  final String? name;
  final String? url;
  final String? email;

  const ContactObject({
    this.name,
    this.url,
    this.email,
  });
}
