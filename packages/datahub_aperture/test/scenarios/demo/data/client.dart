import 'package:datahub/data.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/icons.dart';
import 'package:datahub_aperture/src/data/meta/aperture_meta.dart';

import 'client_tier.dart';
import 'contact.dart';
import 'employee.dart';
import 'industry.dart';
import 'invoice.dart';
import 'product.dart';
import 'project.dart';
import 'support_ticket.dart';

part 'client.g.dart';

@Data()
@Meta(
  namePlural: 'Clients',
  icon: Icons.business,
  description: 'Companies we work for, including prospects.',
)
@ApertureMeta(titleTemplate: '{{ name }}')
@ApertureRelation<Contact>()
@ApertureRelation<Project>()
@ApertureRelation<Product>()
@ApertureRelation<Invoice>()
@ApertureRelation<SupportTicket>()
class Client extends $Client {
  const Client({
    this.id = 0,
    required this.customerNumber,
    required this.name,
    required this.legalName,
    required this.industry,
    this.tier = ClientTier.bronze,
    required this.website,
    required this.email,
    required this.phone,
    this.vatId,
    required this.addressStreet,
    required this.addressPostalCode,
    required this.addressCity,
    required this.addressCountry,
    required this.location,
    required this.onboarded,
    this.employeeCount,
    this.annualRevenue,
    this.paymentTermDays = 30,
    this.currency = 'EUR',
    this.tags = const [],
    this.notes,
    this.accountManagerId,
    this.active = true,
  });

  @Id(auto: true)
  final int id;

  @ApertureField(isDisplayField: true, readOnly: true)
  @Meta(name: 'Customer No.', description: 'Assigned on creation.')
  @RegExpConstraint(expression: r'^C-\d{5}$')
  final String customerNumber;

  @ApertureField(isDisplayField: true)
  @MinLengthConstraint(length: 2)
  @MaxLengthConstraint(length: 80)
  final String name;

  @Meta(
    name: 'Legal name',
    description: 'Registered company name as used on invoices.',
  )
  @MaxLengthConstraint(length: 160)
  final String legalName;

  @ApertureField(isDisplayField: true)
  final Industry industry;

  @Meta(description: 'Commercial tier. Drives discounts and support SLAs.')
  final ClientTier tier;

  @RegExpConstraint(expression: r'^https://[\w.-]+\.[a-z]{2,}(/.*)?$')
  final String website;

  @Meta(name: 'E-mail', description: 'General inbox, e.g. office@…')
  @RegExpConstraint(expression: r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$')
  final String email;

  @RegExpConstraint(expression: r'^\+[\d ]{7,20}$')
  final String phone;

  @Meta(name: 'VAT ID')
  @RegExpConstraint(expression: r'^[A-Z]{2}[A-Z0-9]{8,12}$')
  final String? vatId;

  @Meta(name: 'Street')
  final String addressStreet;

  @Meta(name: 'Postal code')
  @MaxLengthConstraint(length: 10)
  final String addressPostalCode;

  @ApertureField(isDisplayField: true)
  @Meta(name: 'City')
  final String addressCity;

  @Meta(name: 'Country', description: 'ISO 3166-1 alpha-2 country code.')
  @RegExpConstraint(expression: r'^[A-Z]{2}$')
  final String addressCountry;

  @ApertureField(allowFilter: false, allowSearch: false, allowSort: false)
  @Meta(description: 'Location of the head office.')
  final Geometry location;

  @ApertureField(isDisplayField: true)
  @Meta(name: 'Onboarded since')
  final DateTime onboarded;

  @Meta(name: 'Employees')
  @RangeConstraint(min: 1, max: 1000000)
  final int? employeeCount;

  @Meta(name: 'Annual revenue', description: 'In millions, client currency.')
  @RangeConstraint(min: 0, max: 1000000)
  final double? annualRevenue;

  @Meta(name: 'Payment terms (days)')
  @RangeConstraint(min: 0, max: 120)
  final int paymentTermDays;

  @RegExpConstraint(expression: r'^[A-Z]{3}$')
  final String currency;

  @ElementConstraint(constraint: RegExpConstraint(expression: r'^[a-z0-9-]+$'))
  final List<String> tags;

  @ApertureField(allowFilter: false, allowSort: false)
  @MaxLengthConstraint(length: 2000)
  final String? notes;

  @Meta(name: 'Account manager')
  @RelationId<Employee>()
  final int? accountManagerId;

  final bool active;
}
