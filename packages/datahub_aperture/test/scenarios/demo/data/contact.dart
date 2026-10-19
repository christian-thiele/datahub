import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';

import 'client.dart';
import 'contact_type.dart';
import 'support_ticket.dart';

part 'contact.g.dart';

@Data()
@Meta(namePlural: 'Contacts', icon: Icons.contact_mail)
@ApertureMeta(titleTemplate: '{{ firstName }} {{ lastName }}')
@ApertureRelation<SupportTicket>()
class const Contact({
  @Id(auto: true) final int id = 0,
  @Meta(description: 'Academic title, e.g. Dr. or Prof.')
  @MaxLengthConstraint(length: 20)
  final String? title,
  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 1)
  @MaxLengthConstraint(length: 50)
  required final String firstName,
  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 1)
  @MaxLengthConstraint(length: 50)
  required final String lastName,
  @ApertureField(isDisplayField: true)
  @Meta(name: 'Job title')
  required final String position,
  @Meta(name: 'E-mail')
  @RegExpConstraint(expression: r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$')
  required final String email,
  @RegExpConstraint(expression: r'^\+[\d ]{7,20}$') required final String phone,
  @RegExpConstraint(expression: r'^\+[\d ]{7,20}$') final String? mobile,
  @Meta(name: 'Client') @RelationId<Client>() required final int clientId,
  @Meta(name: 'Role') final ContactType type = ContactType.employee,
  @Meta(
    name: 'Primary contact',
    description: 'Main point of contact for this client.',
  )
  final bool primaryContact = false,
  @Meta(description: 'Preferred language (ISO 639-1).')
  @RegExpConstraint(expression: r'^[a-z]{2}$')
  final String language = 'en',
  final DateTime? birthday,
  @Meta(name: 'Last contacted') final DateTime? lastContactedAt,
  @Meta(name: 'Newsletter opt-in') final bool newsletterOptIn = false,
}) extends $Contact;
