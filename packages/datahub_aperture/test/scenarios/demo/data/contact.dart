import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_meta.dart';

import 'client.dart';
import 'contact_type.dart';
import 'support_ticket.dart';

part 'contact.g.dart';

@Data()
@Meta(namePlural: 'Contacts', icon: Icons.contact_mail)
@ApertureMeta(titleTemplate: '{{ firstName }} {{ lastName }}')
@ApertureRelation<SupportTicket>()
class Contact extends $Contact {
  const Contact({
    this.id = 0,
    this.title,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.email,
    required this.phone,
    this.mobile,
    required this.clientId,
    this.type = ContactType.employee,
    this.primaryContact = false,
    this.language = 'en',
    this.birthday,
    this.lastContactedAt,
    this.newsletterOptIn = false,
  });

  @Id(auto: true)
  final int id;

  @Meta(description: 'Academic title, e.g. Dr. or Prof.')
  @MaxLengthConstraint(length: 20)
  final String? title;

  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 1)
  @MaxLengthConstraint(length: 50)
  final String firstName;

  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 1)
  @MaxLengthConstraint(length: 50)
  final String lastName;

  @ApertureField(isDisplayField: true)
  @Meta(name: 'Job title')
  final String position;

  @Meta(name: 'E-mail')
  @RegExpConstraint(expression: r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$')
  final String email;

  @RegExpConstraint(expression: r'^\+[\d ]{7,20}$')
  final String phone;

  @RegExpConstraint(expression: r'^\+[\d ]{7,20}$')
  final String? mobile;

  @Meta(name: 'Role')
  final ContactType type;

  @Meta(
    name: 'Primary contact',
    description: 'Main point of contact for this client.',
  )
  final bool primaryContact;

  @Meta(description: 'Preferred language (ISO 639-1).')
  @RegExpConstraint(expression: r'^[a-z]{2}$')
  final String language;

  final DateTime? birthday;

  @Meta(name: 'Last contacted')
  final DateTime? lastContactedAt;

  @Meta(name: 'Newsletter opt-in')
  final bool newsletterOptIn;

  @Meta(name: 'Client')
  @RelationId<Client>()
  final int clientId;
}
