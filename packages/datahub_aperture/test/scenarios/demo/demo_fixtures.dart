// Hand-written reference data for the demo scenario.
//
// The fictional company "ACME Digital" is a software & design agency
// based in Berlin, working for clients all over Europe.

import 'data/billing_type.dart';
import 'data/client_tier.dart';
import 'data/department.dart';
import 'data/industry.dart';
import 'data/price_unit_type.dart';
import 'data/priority.dart';
import 'data/product_category.dart';
import 'data/ticket_channel.dart';

const agencyDomain = 'example.com';

typedef EmployeeFixture = ({
  String firstName,
  String lastName,
  String jobTitle,
  Department department,
  double costRate,
  List<String> skills,
  List<String> languages,
  String hired,
  int? manager,
  bool remote,
  int weeklyHours,
  bool active,
});

EmployeeFixture _employee(
  String firstName,
  String lastName,
  String jobTitle,
  Department department,
  double costRate,
  List<String> skills, {
  required String hired,
  int? manager,
  List<String> languages = const ['de', 'en'],
  bool remote = false,
  int weeklyHours = 40,
  bool active = true,
}) => (
  firstName: firstName,
  lastName: lastName,
  jobTitle: jobTitle,
  department: department,
  costRate: costRate,
  skills: skills,
  languages: languages,
  hired: hired,
  manager: manager,
  remote: remote,
  weeklyHours: weeklyHours,
  active: active,
);

/// Indices into this list are used as manager references and team members.
final employeeFixtures = <EmployeeFixture>[
  // 0
  _employee(
    'Katharina',
    'Vogel',
    'Managing Director',
    Department.management,
    120,
    ['strategy', 'sales', 'finance'],
    hired: '2014-03-01',
    languages: ['de', 'en', 'fr'],
  ),
  // 1
  _employee(
    'Tobias',
    'Brandt',
    'Chief Technology Officer',
    Department.management,
    115,
    ['architecture', 'kotlin', 'aws', 'dart'],
    hired: '2014-03-01',
    manager: 0,
  ),
  // 2
  _employee(
    'Amara',
    'Okafor',
    'Head of Design',
    Department.design,
    95,
    ['ux-research', 'figma', 'design-systems', 'workshops'],
    hired: '2016-09-01',
    manager: 0,
    languages: ['en', 'de'],
  ),
  // 3
  _employee(
    'Lukas',
    'Weber',
    'Head of Delivery',
    Department.projectManagement,
    95,
    ['scrum', 'safe', 'stakeholder-management', 'budgeting'],
    hired: '2015-06-15',
    manager: 0,
  ),
  // 4
  _employee(
    'Sofia',
    'Marchetti',
    'Head of Sales',
    Department.sales,
    100,
    ['key-accounts', 'negotiation', 'public-tenders'],
    hired: '2018-01-08',
    manager: 0,
    languages: ['it', 'en', 'de'],
  ),
  // 5
  _employee(
    'Jonas',
    'Hoffmann',
    'Senior Software Engineer',
    Department.engineering,
    85,
    ['dart', 'flutter', 'postgres', 'kotlin'],
    hired: '2017-04-01',
    manager: 1,
  ),
  // 6
  _employee(
    'Mei Lin',
    'Zhang',
    'Senior Software Engineer',
    Department.engineering,
    85,
    ['typescript', 'react', 'graphql', 'node'],
    hired: '2018-10-01',
    manager: 1,
    languages: ['zh', 'en', 'de'],
  ),
  // 7
  _employee(
    'Felix',
    'Krüger',
    'Software Engineer',
    Department.engineering,
    70,
    ['java', 'spring', 'kafka', 'camel'],
    hired: '2020-02-01',
    manager: 5,
  ),
  // 8
  _employee(
    'Aylin',
    'Demir',
    'Data Engineer',
    Department.engineering,
    75,
    ['python', 'dbt', 'airflow', 'snowflake'],
    hired: '2021-05-01',
    manager: 6,
    languages: ['tr', 'de', 'en'],
  ),
  // 9
  _employee(
    'Mateusz',
    'Nowak',
    'DevOps Engineer',
    Department.engineering,
    80,
    ['kubernetes', 'terraform', 'aws', 'gitlab-ci'],
    hired: '2019-08-15',
    manager: 1,
    languages: ['pl', 'en', 'de'],
    remote: true,
  ),
  // 10
  _employee(
    'Hannah',
    'Schulz',
    'Junior Software Engineer',
    Department.engineering,
    55,
    ['flutter', 'dart', 'firebase'],
    hired: '2024-09-01',
    manager: 5,
  ),
  // 11
  _employee(
    'Daniel',
    'Costa',
    'Mobile Engineer',
    Department.engineering,
    72,
    ['kotlin', 'android', 'swift', 'flutter'],
    hired: '2022-01-10',
    manager: 5,
    languages: ['pt', 'en', 'de'],
  ),
  // 12
  _employee(
    'Emma',
    'Lindqvist',
    'Senior UX Designer',
    Department.design,
    78,
    ['figma', 'prototyping', 'accessibility', 'user-interviews'],
    hired: '2019-03-01',
    manager: 2,
    languages: ['sv', 'en', 'de'],
  ),
  // 13
  _employee(
    'Noah',
    'Fischer',
    'UI Designer',
    Department.design,
    62,
    ['figma', 'illustration', 'motion-design'],
    hired: '2023-02-15',
    manager: 2,
  ),
  // 14
  _employee(
    'Leonie',
    'Wagner',
    'Project Manager',
    Department.projectManagement,
    75,
    ['scrum', 'jira', 'budgeting'],
    hired: '2019-11-01',
    manager: 3,
  ),
  // 15
  _employee(
    'Samuel',
    'Adeyemi',
    'Project Manager',
    Department.projectManagement,
    75,
    ['kanban', 'prince2', 'risk-management'],
    hired: '2021-07-01',
    manager: 3,
    languages: ['en', 'yo', 'de'],
  ),
  // 16
  _employee(
    'Clara',
    'Meier',
    'Product Owner',
    Department.projectManagement,
    78,
    ['product-discovery', 'okr', 'user-stories'],
    hired: '2020-04-01',
    manager: 3,
  ),
  // 17
  _employee(
    'Julian',
    'Becker',
    'Account Executive',
    Department.sales,
    70,
    ['crm', 'negotiation', 'pre-sales'],
    hired: '2022-03-01',
    manager: 4,
  ),
  // 18
  _employee(
    'Nina',
    'Popović',
    'Key Account Manager',
    Department.sales,
    72,
    ['key-accounts', 'contract-management'],
    hired: '2021-09-15',
    manager: 4,
    languages: ['sr', 'de', 'en'],
  ),
  // 19
  _employee(
    'Marco',
    'Rossi',
    'Support Lead',
    Department.support,
    62,
    ['itil', 'zendesk', 'sql', 'incident-management'],
    hired: '2018-05-01',
    manager: 1,
    languages: ['it', 'de', 'en'],
  ),
  // 20
  _employee(
    'Lea',
    'Hartmann',
    'Support Engineer',
    Department.support,
    52,
    ['linux', 'sql', 'monitoring'],
    hired: '2023-06-01',
    manager: 19,
  ),
  // 21
  _employee(
    'Omar',
    'Haddad',
    'Support Engineer',
    Department.support,
    52,
    ['networking', 'bash', 'postgres'],
    hired: '2024-02-01',
    manager: 19,
    languages: ['ar', 'en', 'de'],
    remote: true,
  ),
  // 22
  _employee(
    'Birgit',
    'Lange',
    'Finance Manager',
    Department.finance,
    70,
    ['datev', 'controlling', 'dunning'],
    hired: '2016-01-01',
    manager: 0,
  ),
  // 23
  _employee(
    'Selin',
    'Yılmaz',
    'People & Culture Manager',
    Department.people,
    65,
    ['recruiting', 'onboarding', 'employer-branding'],
    hired: '2020-10-01',
    manager: 0,
    languages: ['tr', 'de', 'en'],
  ),
  // 24
  _employee(
    'Paul',
    'Richter',
    'Working Student Engineering',
    Department.engineering,
    25,
    ['python', 'testing'],
    hired: '2025-10-01',
    manager: 6,
    weeklyHours: 20,
  ),
  // 25
  _employee(
    'Greta',
    'Neumann',
    'Software Engineer',
    Department.engineering,
    70,
    ['java', 'angular'],
    hired: '2017-08-01',
    manager: 5,
    active: false,
  ),
];

/// Employees available for project work, grouped by the focus of a project.
const teamPools = <String, List<int>>{
  'dev': [5, 6, 7, 11, 10, 24],
  'mobile': [5, 11, 10],
  'data': [8, 6, 7, 24],
  'design': [12, 13, 6],
  'ops': [9, 1, 7],
};

const projectLeads = [3, 14, 15, 16];
const supportStaff = [19, 20, 21];
const accountManagers = [4, 17, 18];

typedef ClientFixture = ({
  String name,
  String legalName,
  Industry industry,
  ClientTier tier,
  String domain,
  String street,
  String postalCode,
  String city,
  String country,
  String areaCode,
  double lat,
  double lon,
  int? employees,
  double? revenue,
  String onboarded,
  bool active,
  List<String> tags,
  String? notes,
});

ClientFixture _client(
  String name,
  String legalName,
  Industry industry,
  ClientTier tier,
  String domain, {
  required String street,
  required String postalCode,
  required String city,
  String country = 'DE',
  required String areaCode,
  required double lat,
  required double lon,
  int? employees,
  double? revenue,
  required String onboarded,
  bool active = true,
  List<String> tags = const [],
  String? notes,
}) => (
  name: name,
  legalName: legalName,
  industry: industry,
  tier: tier,
  domain: domain,
  street: street,
  postalCode: postalCode,
  city: city,
  country: country,
  areaCode: areaCode,
  lat: lat,
  lon: lon,
  employees: employees,
  revenue: revenue,
  onboarded: onboarded,
  active: active,
  tags: tags,
  notes: notes,
);

final clientFixtures = <ClientFixture>[
  _client(
    'Nordwind Logistik',
    'Nordwind Logistik GmbH & Co. KG',
    Industry.logistics,
    ClientTier.platinum,
    'nordwind-logistik.de',
    street: 'Am Sandtorkai 41',
    postalCode: '20457',
    city: 'Hamburg',
    areaCode: '40',
    lat: 53.5436,
    lon: 9.9885,
    employees: 2400,
    revenue: 610,
    onboarded: '2016-04-11',
    tags: ['key-account', 'sap', 'framework-contract'],
    notes:
        'Framework contract renewed until end of 2027. Purchase orders are '
        'mandatory for every invoice, PO number must be stated.',
  ),
  _client(
    'Alpenglanz Hotels',
    'Alpenglanz Hotels AG',
    Industry.hospitality,
    ClientTier.gold,
    'alpenglanz.at',
    street: 'Maria-Theresien-Straße 18',
    postalCode: '6020',
    city: 'Innsbruck',
    country: 'AT',
    areaCode: '512',
    lat: 47.2654,
    lon: 11.3940,
    employees: 850,
    revenue: 120,
    onboarded: '2019-02-18',
    tags: ['booking', 'seasonal'],
    notes: 'Code freeze during peak season (Dec 15 – Mar 31).',
  ),
  _client(
    'HelvetiaMed',
    'HelvetiaMed Technologies SA',
    Industry.healthcare,
    ClientTier.gold,
    'helvetiamed.ch',
    street: 'Avenue de la Gare 12',
    postalCode: '1003',
    city: 'Lausanne',
    country: 'CH',
    areaCode: '21',
    lat: 46.5170,
    lon: 6.6290,
    employees: 420,
    revenue: 95,
    onboarded: '2020-06-01',
    tags: ['medical-device', 'iso-13485', 'nda'],
  ),
  _client(
    'Stadtwerke Elbtal',
    'Stadtwerke Elbtal GmbH',
    Industry.energy,
    ClientTier.silver,
    'stadtwerke-elbtal.de',
    street: 'Rosenstraße 32',
    postalCode: '01067',
    city: 'Dresden',
    areaCode: '351',
    lat: 51.0504,
    lon: 13.7373,
    employees: 980,
    revenue: 410,
    onboarded: '2021-01-12',
    tags: ['kritis', 'public-tender'],
    notes: 'KRITIS operator – all changes need a documented security review.',
  ),
  _client(
    'Rheinkraft Maschinenbau',
    'Rheinkraft Maschinenbau AG',
    Industry.manufacturing,
    ClientTier.platinum,
    'rheinkraft.de',
    street: 'Speditionstraße 21',
    postalCode: '40221',
    city: 'Düsseldorf',
    areaCode: '211',
    lat: 51.2143,
    lon: 6.7520,
    employees: 5200,
    revenue: 1400,
    onboarded: '2015-09-01',
    tags: ['key-account', 'iot', 'sap'],
  ),
  _client(
    'Sonnenkorn',
    'Sonnenkorn Backwaren GmbH',
    Industry.retail,
    ClientTier.bronze,
    'sonnenkorn.de',
    street: 'Leopoldstraße 102',
    postalCode: '80802',
    city: 'München',
    areaCode: '89',
    lat: 48.1629,
    lon: 11.5866,
    employees: 180,
    revenue: 22,
    onboarded: '2023-05-08',
    tags: ['loyalty'],
  ),
  _client(
    'Lindgren Försäkring',
    'Lindgren Försäkring AB',
    Industry.insurance,
    ClientTier.gold,
    'lindgren-forsakring.se',
    street: 'Kungsgatan 44',
    postalCode: '111 35',
    city: 'Stockholm',
    country: 'SE',
    areaCode: '8',
    lat: 59.3363,
    lon: 18.0632,
    employees: 1100,
    revenue: 780,
    onboarded: '2022-03-21',
    tags: ['claims', 'english-only'],
    notes: 'All documentation and meetings in English.',
  ),
  _client(
    'Grachtenhuis Media',
    'Grachtenhuis Media B.V.',
    Industry.media,
    ClientTier.silver,
    'grachtenhuis.nl',
    street: 'Keizersgracht 312',
    postalCode: '1016 EZ',
    city: 'Amsterdam',
    country: 'NL',
    areaCode: '20',
    lat: 52.3713,
    lon: 4.8850,
    employees: 140,
    revenue: 18,
    onboarded: '2022-09-05',
    tags: ['video', 'streaming'],
  ),
  _client(
    'Voltara Mobility',
    'Voltara Mobility GmbH',
    Industry.automotive,
    ClientTier.gold,
    'voltara.io',
    street: 'Heilbronner Straße 150',
    postalCode: '70191',
    city: 'Stuttgart',
    areaCode: '711',
    lat: 48.7960,
    lon: 9.1860,
    employees: 650,
    revenue: 140,
    onboarded: '2021-10-04',
    tags: ['ev-charging', 'iot', 'startup'],
  ),
  _client(
    'Finovo Bank',
    'Finovo Bank AG',
    Industry.finance,
    ClientTier.platinum,
    'finovo.de',
    street: 'Mainzer Landstraße 50',
    postalCode: '60325',
    city: 'Frankfurt am Main',
    areaCode: '69',
    lat: 50.1125,
    lon: 8.6660,
    employees: 3100,
    revenue: 2200,
    onboarded: '2017-01-16',
    tags: ['key-account', 'bafin', 'dora', 'nda'],
    notes:
        'DORA register entry required for new subcontractors. Access to '
        'production only via bank-provided VDI.',
  ),
  _client(
    'Digitale Kommune Weserbergland',
    'Zweckverband Digitale Kommune Weserbergland',
    Industry.publicSector,
    ClientTier.silver,
    'dk-weserbergland.de',
    street: 'Deisterstraße 10',
    postalCode: '31785',
    city: 'Hameln',
    areaCode: '5151',
    lat: 52.1030,
    lon: 9.3570,
    employees: 95,
    onboarded: '2023-02-01',
    tags: ['public-tender', 'ozg', 'e-invoice'],
    notes: 'Invoices must be submitted as XRechnung via the ZRE portal.',
  ),
  _client(
    'Campus Nova',
    'Campus Nova Hochschule gGmbH',
    Industry.education,
    ClientTier.bronze,
    'campus-nova.de',
    street: 'Albert-Einstein-Straße 3',
    postalCode: '07745',
    city: 'Jena',
    areaCode: '3641',
    lat: 50.9110,
    lon: 11.5680,
    employees: 310,
    revenue: 28,
    onboarded: '2024-03-15',
    tags: ['e-learning'],
  ),
  _client(
    'Pixelforge Games',
    'Pixelforge Games GmbH',
    Industry.software,
    ClientTier.silver,
    'pixelforge.gg',
    street: 'Schanzenstraße 22',
    postalCode: '51063',
    city: 'Köln',
    areaCode: '221',
    lat: 50.9670,
    lon: 7.0100,
    employees: 85,
    revenue: 12,
    onboarded: '2022-11-14',
    tags: ['gaming', 'startup'],
  ),
  _client(
    'Quartier Immobilien',
    'Quartier Immobilien Management GmbH',
    Industry.realEstate,
    ClientTier.silver,
    'quartier-immo.de',
    street: 'Kurfürstendamm 195',
    postalCode: '10707',
    city: 'Berlin',
    areaCode: '30',
    lat: 52.5010,
    lon: 13.3150,
    employees: 260,
    revenue: 75,
    onboarded: '2023-08-28',
    tags: ['tenant-app'],
  ),
  _client(
    'Klinikverbund Havelland',
    'Klinikverbund Havelland gGmbH',
    Industry.healthcare,
    ClientTier.gold,
    'kv-havelland.de',
    street: 'Ketziner Straße 21',
    postalCode: '14641',
    city: 'Nauen',
    areaCode: '3321',
    lat: 52.6050,
    lon: 12.8740,
    employees: 1900,
    revenue: 230,
    onboarded: '2020-11-02',
    tags: ['kritis', 'fhir', 'khzg'],
  ),
  _client(
    'Fjord & Faden',
    'Fjord & Faden GmbH',
    Industry.retail,
    ClientTier.gold,
    'fjordundfaden.de',
    street: 'Großer Burstah 31',
    postalCode: '20457',
    city: 'Hamburg',
    areaCode: '40',
    lat: 53.5480,
    lon: 9.9910,
    employees: 320,
    revenue: 88,
    onboarded: '2019-07-22',
    tags: ['e-commerce', 'shopify-plus'],
  ),
  _client(
    'Transalpina Spedizioni',
    'Transalpina Spedizioni S.r.l.',
    Industry.logistics,
    ClientTier.silver,
    'transalpina.it',
    street: 'Via Brennero 55',
    postalCode: '39100',
    city: 'Bolzano',
    country: 'IT',
    areaCode: '0471',
    lat: 46.5070,
    lon: 11.3590,
    employees: 430,
    revenue: 96,
    onboarded: '2022-05-16',
    tags: ['telematics', 'bilingual'],
  ),
  _client(
    'SolarKamm Energie',
    'SolarKamm Energie eG',
    Industry.energy,
    ClientTier.bronze,
    'solarkamm.de',
    street: 'Schwarzwaldstraße 8',
    postalCode: '79117',
    city: 'Freiburg im Breisgau',
    areaCode: '761',
    lat: 47.9900,
    lon: 7.8700,
    employees: 40,
    revenue: 9.5,
    onboarded: '2024-06-03',
    tags: ['cooperative', 'smart-meter'],
  ),
  _client(
    'Präzisionswerk Albtal',
    'Präzisionswerk Albtal GmbH',
    Industry.manufacturing,
    ClientTier.silver,
    'pw-albtal.de',
    street: 'Industriestraße 14',
    postalCode: '76275',
    city: 'Ettlingen',
    areaCode: '7243',
    lat: 48.9380,
    lon: 8.4080,
    employees: 560,
    revenue: 115,
    onboarded: '2021-04-19',
    tags: ['iot', 'predictive-maintenance'],
  ),
  _client(
    'Wellenreiter Audio',
    'Wellenreiter Audio GmbH',
    Industry.media,
    ClientTier.bronze,
    'wellenreiter.fm',
    street: 'Torstraße 140',
    postalCode: '10119',
    city: 'Berlin',
    areaCode: '30',
    lat: 52.5290,
    lon: 13.4010,
    employees: 35,
    revenue: 4.2,
    onboarded: '2024-01-22',
    tags: ['podcast', 'startup'],
  ),
  _client(
    'Hanseatic Wealth Partners',
    'Hanseatic Wealth Partners GmbH',
    Industry.finance,
    ClientTier.gold,
    'hanseatic-wp.com',
    street: 'Ballindamm 17',
    postalCode: '20095',
    city: 'Hamburg',
    areaCode: '40',
    lat: 53.5530,
    lon: 9.9960,
    employees: 120,
    revenue: 64,
    onboarded: '2020-02-10',
    tags: ['nda', 'mifid'],
  ),
  _client(
    'Lisboa Surf Lodges',
    'Lisboa Surf Lodges, Lda.',
    Industry.hospitality,
    ClientTier.prospect,
    'lisboasurflodges.pt',
    street: 'Rua da Prata 80',
    postalCode: '1100-420',
    city: 'Lisboa',
    country: 'PT',
    areaCode: '21',
    lat: 38.7100,
    lon: -9.1370,
    employees: 60,
    revenue: 7.8,
    onboarded: '2026-07-06',
    tags: ['booking', 'lead-website'],
    notes: 'Inbound lead via website. Offer for booking engine sent in July.',
  ),
  _client(
    'Kessler Automobile',
    'Kessler Automobile GmbH',
    Industry.automotive,
    ClientTier.silver,
    'kessler-auto.de',
    street: 'Nürnberger Straße 88',
    postalCode: '90762',
    city: 'Fürth',
    areaCode: '911',
    lat: 49.4710,
    lon: 10.9890,
    employees: 390,
    revenue: 210,
    onboarded: '2022-07-11',
    tags: ['dealer-group', 'crm'],
  ),
  _client(
    'Tessellate Analytics',
    'Tessellate Analytics Ltd',
    Industry.software,
    ClientTier.silver,
    'tessellate.ai',
    street: '20 Shoreditch High Street',
    postalCode: 'E1 6PG',
    city: 'London',
    country: 'GB',
    areaCode: '20',
    lat: 51.5230,
    lon: -0.0770,
    employees: 70,
    revenue: 9,
    onboarded: '2023-10-09',
    tags: ['saas', 'white-label'],
  ),
  _client(
    'VitaPlus Apotheken',
    'VitaPlus Apotheken eG',
    Industry.healthcare,
    ClientTier.bronze,
    'vitaplus-apotheken.de',
    street: 'Königsallee 60',
    postalCode: '44789',
    city: 'Bochum',
    areaCode: '234',
    lat: 51.4700,
    lon: 7.2200,
    employees: 750,
    revenue: 180,
    onboarded: '2024-09-16',
    tags: ['e-rezept'],
  ),
  _client(
    'Mittelrhein Versicherung',
    'Mittelrhein Versicherung AG',
    Industry.insurance,
    ClientTier.gold,
    'mittelrhein-vers.de',
    street: 'Rheinstraße 45',
    postalCode: '56068',
    city: 'Koblenz',
    areaCode: '261',
    lat: 50.3560,
    lon: 7.5940,
    employees: 1450,
    revenue: 920,
    onboarded: '2018-03-05',
    tags: ['claims', 'bafin', 'vait'],
  ),
  _client(
    'Bohnenglück',
    'Bohnenglück Kaffeerösterei GmbH',
    Industry.retail,
    ClientTier.bronze,
    'bohnenglueck.de',
    street: 'Wiesenstraße 5',
    postalCode: '04229',
    city: 'Leipzig',
    areaCode: '341',
    lat: 51.3200,
    lon: 12.3500,
    employees: 28,
    revenue: 3.1,
    onboarded: '2025-01-13',
    tags: ['e-commerce', 'subscription'],
  ),
  _client(
    'Verkehrsverbund Mittelland',
    'Verkehrsverbund Mittelland GmbH',
    Industry.publicSector,
    ClientTier.gold,
    'vvm-mobil.de',
    street: 'Ernst-August-Platz 1',
    postalCode: '30159',
    city: 'Hannover',
    areaCode: '511',
    lat: 52.3760,
    lon: 9.7410,
    employees: 640,
    revenue: 350,
    onboarded: '2019-10-14',
    tags: ['public-tender', 'mobility', 'deutschlandticket'],
  ),
  _client(
    'LernWerk',
    'LernWerk Online GmbH',
    Industry.education,
    ClientTier.silver,
    'lernwerk.online',
    street: 'Karl-Liebknecht-Straße 29',
    postalCode: '10178',
    city: 'Berlin',
    areaCode: '30',
    lat: 52.5230,
    lon: 13.4080,
    employees: 110,
    revenue: 14,
    onboarded: '2021-08-30',
    tags: ['e-learning', 'video'],
  ),
  _client(
    'Pohjola Timber',
    'Pohjola Timber Oy',
    Industry.manufacturing,
    ClientTier.bronze,
    'pohjolatimber.fi',
    street: 'Hämeenkatu 10',
    postalCode: '33100',
    city: 'Tampere',
    country: 'FI',
    areaCode: '3',
    lat: 61.4980,
    lon: 23.7610,
    employees: 210,
    revenue: 58,
    onboarded: '2024-11-25',
    tags: ['english-only'],
  ),
  _client(
    'WPN Service',
    'Windpark Nordsee Service GmbH',
    Industry.energy,
    ClientTier.silver,
    'wpn-service.de',
    street: 'Am Alten Hafen 118',
    postalCode: '27568',
    city: 'Bremerhaven',
    areaCode: '471',
    lat: 53.5420,
    lon: 8.5790,
    employees: 180,
    revenue: 41,
    onboarded: '2020-05-18',
    active: false,
    tags: ['offshore', 'churned'],
    notes:
        'Acquired by a Danish group in 2025, IT was consolidated. Contract '
        'ended in good terms – possible re-activation via new parent company.',
  ),
  _client(
    'Loopline',
    'Loopline Software GmbH',
    Industry.software,
    ClientTier.prospect,
    'loopline.io',
    street: 'Hohenzollernring 72',
    postalCode: '50672',
    city: 'Köln',
    areaCode: '221',
    lat: 50.9410,
    lon: 6.9380,
    employees: 45,
    revenue: 5.5,
    onboarded: '2026-08-24',
    tags: ['saas', 'referral'],
    notes: 'Referral from Pixelforge. Intro call scheduled.',
  ),
];

const countryPhonePrefix = {
  'DE': '49',
  'AT': '43',
  'CH': '41',
  'SE': '46',
  'NL': '31',
  'IT': '39',
  'PT': '351',
  'GB': '44',
  'FI': '358',
};

const countryMobilePrefixes = {
  'DE': ['151', '160', '170', '176', '152'],
  'AT': ['660', '664', '676'],
  'CH': ['76', '78', '79'],
  'SE': ['70', '72', '73'],
  'NL': ['6'],
  'IT': ['333', '347', '320'],
  'PT': ['91', '93', '96'],
  'GB': ['7700', '7911', '7400'],
  'FI': ['40', '50'],
};

const countryCurrency = {'CH': 'CHF', 'SE': 'SEK', 'GB': 'GBP'};

/// Rough conversion factors from EUR list prices.
const currencyFactor = {'EUR': 1.0, 'CHF': 0.95, 'SEK': 11.4, 'GBP': 0.86};

/// Language of client contacts by country (+ city exceptions).
const countryLanguage = {
  'DE': 'de',
  'AT': 'de',
  'CH': 'fr',
  'SE': 'sv',
  'NL': 'nl',
  'IT': 'it',
  'PT': 'pt',
  'GB': 'en',
  'FI': 'fi',
};

const tierDiscount = {
  ClientTier.prospect: 0.0,
  ClientTier.bronze: 0.0,
  ClientTier.silver: 0.03,
  ClientTier.gold: 0.07,
  ClientTier.platinum: 0.12,
};

const tierProjectCount = {
  ClientTier.prospect: (0, 0),
  ClientTier.bronze: (1, 2),
  ClientTier.silver: (2, 3),
  ClientTier.gold: (3, 4),
  ClientTier.platinum: (4, 6),
};

const tierTicketCount = {
  ClientTier.prospect: (0, 0),
  ClientTier.bronze: (2, 6),
  ClientTier.silver: (5, 10),
  ClientTier.gold: (9, 15),
  ClientTier.platinum: (14, 22),
};

/// First response SLA in hours per tier.
const tierResponseSla = {
  ClientTier.prospect: 48,
  ClientTier.bronze: 24,
  ClientTier.silver: 8,
  ClientTier.gold: 4,
  ClientTier.platinum: 1,
};

const tierPaymentTerms = {
  ClientTier.prospect: 14,
  ClientTier.bronze: 14,
  ClientTier.silver: 30,
  ClientTier.gold: 30,
  ClientTier.platinum: 45,
};

typedef NamePool = ({List<String> first, List<String> last});

NamePool _names(String first, String last) =>
    (first: first.split(', '), last: last.split(', '));

final namePools = <String, NamePool>{
  'de': _names(
    'Anna, Lena, Julia, Sarah, Katrin, Sabine, Stefanie, Christina, '
        'Melanie, Nadine, Jana, Franziska, Miriam, Theresa, Thomas, '
        'Michael, Andreas, Stefan, Markus, Christian, Alexander, '
        'Sebastian, Martin, Florian, Matthias, Philipp, Benjamin, Tim, '
        'Oliver, Frank, Moritz, Kai, Deniz, Elif, Dragan, Agnieszka',
    'Müller, Schmidt, Schneider, Fischer, Meyer, Wagner, Becker, '
        'Schulz, Koch, Klein, Wolf, Schröder, Schwarz, Zimmermann, Braun, '
        'Hofmann, Lehmann, Köhler, Maier, Herrmann, König, Walter, Peters, '
        'Kaiser, Fuchs, Scholz, Özdemir, Kowalski, Nguyen, Petrović, '
        'Albrecht, Vogt',
  ),
  'at': _names(
    'Katharina, Magdalena, Verena, Elisabeth, Johanna, Barbara, Lukas, '
        'Florian, Georg, Andreas, Stefan, Maximilian, Matthias, Clemens',
    'Gruber, Huber, Wagner, Pichler, Steiner, Moser, Mayer, Hofer, '
        'Leitner, Berger, Eder, Wimmer, Egger, Aigner',
  ),
  'fr': _names(
    'Camille, Léa, Chloé, Manon, Élodie, Nathalie, Sophie, Aurélie, '
        'Nicolas, Julien, Olivier, Laurent, Mathieu, Luc, Pierre, Thierry',
    'Favre, Rochat, Morel, Bonvin, Pittet, Mercier, Blanc, Gerber, '
        'Dubois, Perrin, Chappuis, Rey, Jaquet, Monnier',
  ),
  'sv': _names(
    'Anna, Maja, Elin, Ingrid, Karin, Sara, Linnea, Astrid, Erik, '
        'Lars, Johan, Anders, Oskar, Nils, Henrik, Magnus',
    'Andersson, Johansson, Karlsson, Nilsson, Eriksson, Larsson, '
        'Olsson, Persson, Svensson, Gustafsson, Lindberg, Bergström, Holm, '
        'Sjöberg',
  ),
  'nl': _names(
    'Sanne, Lotte, Femke, Anouk, Eva, Marieke, Iris, Fleur, Daan, '
        'Bram, Joost, Thijs, Ruben, Pieter, Jeroen, Sander',
    'de Jong, Jansen, de Vries, van den Berg, Bakker, Visser, Smit, '
        'Meijer, de Boer, Mulder, Bos, Vos, Dekker, van Dijk',
  ),
  'it': _names(
    'Giulia, Francesca, Chiara, Elena, Martina, Valentina, Marco, '
        'Luca, Andrea, Matteo, Alessandro, Davide, Stefano, Paolo, Lukas, '
        'Maria',
    'Rossi, Ferrari, Esposito, Bianchi, Romano, Colombo, Ricci, '
        'Marino, Greco, Bruno, Conti, Gasser, Pircher, Mair, Kofler',
  ),
  'pt': _names(
    'Ana, Beatriz, Inês, Mariana, Catarina, Sofia, João, Tiago, Pedro, '
        'Rui, Miguel, Diogo',
    'Silva, Santos, Ferreira, Pereira, Oliveira, Costa, Rodrigues, '
        'Martins, Sousa, Fernandes',
  ),
  'en': _names(
    'Olivia, Amelia, Charlotte, Emily, Priya, Grace, Hannah, Chloe, '
        'Oliver, George, Harry, James, William, Thomas, Arjun, Samuel',
    'Smith, Jones, Taylor, Brown, Williams, Wilson, Evans, Patel, '
        'Walker, Wright, Robinson, Thompson, Khan, Hughes',
  ),
  'fi': _names(
    'Aino, Emma, Helmi, Laura, Johanna, Mikko, Juha, Antti, Ville, '
        'Janne, Eero, Sanna',
    'Korhonen, Virtanen, Mäkinen, Nieminen, Mäkelä, Hämäläinen, Laine, '
        'Heikkinen, Koskinen, Järvinen',
  ),
};

const contactPositions = {
  'executive': [
    'CEO',
    'Managing Director',
    'Chief Information Officer',
    'Chief Operating Officer',
    'Chief Digital Officer',
  ],
  'technical': [
    'Head of IT',
    'IT Project Lead',
    'Lead Developer',
    'Solution Architect',
    'IT Operations Manager',
    'Information Security Officer',
  ],
  'financial': [
    'CFO',
    'Head of Accounting',
    'Accounts Payable Specialist',
    'Controller',
  ],
  'procurement': ['Procurement Manager', 'Strategic Buyer', 'Vendor Manager'],
  'legal': ['Legal Counsel', 'Data Protection Officer', 'Compliance Manager'],
  'employee': [
    'Marketing Manager',
    'Product Manager',
    'E-Commerce Manager',
    'Team Assistant',
    'HR Business Partner',
    'Customer Service Lead',
    'Digital Transformation Manager',
  ],
};

typedef CatalogItem = ({
  String code,
  String title,
  String description,
  ProductCategory category,
  PriceUnitType unit,
  double listPrice,
  bool recurring,
});

CatalogItem _item(
  String code,
  String title,
  ProductCategory category,
  PriceUnitType unit,
  double listPrice,
  String description, {
  bool recurring = false,
}) => (
  code: code,
  title: title,
  description: description,
  category: category,
  unit: unit,
  listPrice: listPrice,
  recurring: recurring,
);

/// Codes that every active client gets a price agreement for.
const coreCatalogCodes = ['DEV-SEN', 'DEV-JUN', 'PMG-SCR', 'DES-UX'];

final catalog = <CatalogItem>[
  _item(
    'DEV-SEN',
    'Senior Software Engineering',
    ProductCategory.development,
    PriceUnitType.hour,
    145,
    'Senior engineer with 6+ years of experience. Includes code reviews '
        'and technical mentoring.',
  ),
  _item(
    'DEV-JUN',
    'Software Engineering',
    ProductCategory.development,
    PriceUnitType.hour,
    115,
    'Software engineering services (junior and professional level).',
  ),
  _item(
    'DEV-ARC',
    'Solution Architecture',
    ProductCategory.consulting,
    PriceUnitType.hour,
    175,
    'Architecture reviews, technology selection and target pictures.',
  ),
  _item(
    'CON-STR',
    'Digital Strategy Consulting',
    ProductCategory.consulting,
    PriceUnitType.day,
    1450,
    'Strategy workshops and roadmap consulting, 8 hours per day on site '
        'or remote.',
  ),
  _item(
    'DES-UX',
    'UX Research & Design',
    ProductCategory.design,
    PriceUnitType.hour,
    125,
    'User research, interaction design, prototyping and usability testing.',
  ),
  _item(
    'DES-UI',
    'UI Design',
    ProductCategory.design,
    PriceUnitType.hour,
    110,
    'Visual design, design system maintenance and asset production.',
  ),
  _item(
    'PMG-SCR',
    'Project Management',
    ProductCategory.projectManagement,
    PriceUnitType.hour,
    120,
    'Agile project management and Scrum Master services.',
  ),
  _item(
    'OPS-DEVOP',
    'DevOps & Cloud Engineering',
    ProductCategory.development,
    PriceUnitType.hour,
    140,
    'Infrastructure as code, CI/CD pipelines, cloud cost optimisation.',
  ),
  _item(
    'OPS-HOST',
    'Managed Kubernetes Hosting',
    ProductCategory.hosting,
    PriceUnitType.month,
    1890,
    'Managed Kubernetes cluster in Frankfurt (3 nodes), backups, '
        'monitoring and security patches. 99.9 % availability.',
    recurring: true,
  ),
  _item(
    'SUP-SLA',
    'Support & Maintenance SLA',
    ProductCategory.support,
    PriceUnitType.month,
    950,
    'Business-hours support, incident handling according to tier SLA, '
        'includes 6 hours of maintenance per month.',
    recurring: true,
  ),
  _item(
    'LIC-CMS',
    'Headless CMS License (annual)',
    ProductCategory.licensing,
    PriceUnitType.license,
    4800,
    'Annual enterprise license for the headless CMS incl. 10 editor seats.',
  ),
  _item(
    'TRN-WS',
    'Onsite Workshop',
    ProductCategory.training,
    PriceUnitType.day,
    1900,
    'Full-day training or workshop for up to 12 participants, '
        'excl. travel expenses.',
  ),
];

typedef ProjectTemplate = ({
  String name,
  String description,
  List<String> technologies,
  List<BillingType> billing,
  int minHours,
  int maxHours,
  String focus,
  List<Industry> industries,
  List<String> extraProducts,
});

ProjectTemplate _project(
  String name,
  String description,
  List<String> technologies, {
  required List<BillingType> billing,
  required int minHours,
  required int maxHours,
  required String focus,
  List<Industry> industries = const [],
  List<String> extraProducts = const [],
}) => (
  name: name,
  description: description,
  technologies: technologies,
  billing: billing,
  minHours: minHours,
  maxHours: maxHours,
  focus: focus,
  industries: industries,
  extraProducts: extraProducts,
);

const _tm = BillingType.timeAndMaterial;
const _fixed = BillingType.fixedPrice;
const _retainer = BillingType.retainer;

final projectTemplates = <ProjectTemplate>[
  _project(
    'Customer Portal Relaunch',
    'Complete relaunch of the customer self-service portal including SSO, '
        'document inbox and invoice history.',
    ['Flutter Web', 'Dart', 'PostgreSQL', 'Keycloak'],
    billing: [_tm, _tm, _fixed],
    minHours: 1200,
    maxHours: 3000,
    focus: 'dev',
    extraProducts: ['DEV-ARC', 'OPS-HOST', 'SUP-SLA'],
  ),
  _project(
    'B2B Online Shop',
    'Headless commerce platform with ERP-connected pricing and '
        'customer-specific catalogues.',
    ['Next.js', 'TypeScript', 'commercetools', 'SAP S/4HANA'],
    billing: [_tm, _fixed],
    minHours: 1500,
    maxHours: 4000,
    focus: 'dev',
    industries: [Industry.manufacturing, Industry.retail],
    extraProducts: ['DEV-ARC', 'OPS-HOST'],
  ),
  _project(
    'Field Service App',
    'Offline-capable mobile app for technicians: work orders, photo '
        'documentation and digital signatures.',
    ['Flutter', 'Dart', 'SQLite', 'REST'],
    billing: [_tm],
    minHours: 900,
    maxHours: 2200,
    focus: 'mobile',
    industries: [Industry.manufacturing, Industry.energy, Industry.logistics],
    extraProducts: ['SUP-SLA'],
  ),
  _project(
    'Data Warehouse Migration',
    'Migration of the on-premise data warehouse to a cloud lakehouse '
        'including dbt models and Power BI reports.',
    ['Python', 'dbt', 'Snowflake', 'Airflow', 'Power BI'],
    billing: [_tm],
    minHours: 800,
    maxHours: 2000,
    focus: 'data',
    extraProducts: ['DEV-ARC', 'OPS-DEVOP'],
  ),
  _project(
    'Design System',
    'Company-wide design system with Figma library, design tokens and '
        'accessible web components.',
    ['Figma', 'Storybook', 'Web Components', 'TypeScript'],
    billing: [_fixed],
    minHours: 400,
    maxHours: 900,
    focus: 'design',
    extraProducts: ['DES-UI', 'TRN-WS'],
  ),
  _project(
    'Cloud Migration',
    'Lift-and-improve of legacy workloads to AWS with infrastructure as code '
        'and zero-downtime cutover.',
    ['AWS', 'Terraform', 'Kubernetes', 'ArgoCD'],
    billing: [_tm],
    minHours: 700,
    maxHours: 1800,
    focus: 'ops',
    extraProducts: ['OPS-DEVOP', 'DEV-ARC', 'OPS-HOST'],
  ),
  _project(
    'Intranet Modernisation',
    'Replacement of the outdated intranet with a modern employee hub '
        'including news, people directory and Microsoft Teams integration.',
    ['React', 'TypeScript', 'Microsoft Graph', 'Entra ID'],
    billing: [_fixed, _tm],
    minHours: 600,
    maxHours: 1400,
    focus: 'dev',
    extraProducts: ['LIC-CMS', 'DES-UI'],
  ),
  _project(
    'Predictive Maintenance Dashboard',
    'Real-time dashboard for machine telemetry with anomaly detection and '
        'alerting to the service team.',
    ['Python', 'Kafka', 'TimescaleDB', 'Grafana'],
    billing: [_tm],
    minHours: 900,
    maxHours: 2400,
    focus: 'data',
    industries: [Industry.manufacturing, Industry.energy],
    extraProducts: ['OPS-HOST', 'DEV-ARC'],
  ),
  _project(
    'Direct Booking Engine',
    'Direct booking engine with channel manager integration, dynamic pricing '
        'and payment via Adyen.',
    ['Kotlin', 'Spring Boot', 'PostgreSQL', 'Adyen'],
    billing: [_fixed, _tm],
    minHours: 1100,
    maxHours: 2600,
    focus: 'dev',
    industries: [Industry.hospitality],
    extraProducts: ['OPS-HOST', 'SUP-SLA'],
  ),
  _project(
    'Patient App',
    'Appointment booking, secure messaging and document upload for patients. '
        'Hosted in Germany, BSI C5 compliant.',
    ['Flutter', 'Dart', 'HL7 FHIR', 'Keycloak'],
    billing: [_tm],
    minHours: 1400,
    maxHours: 3200,
    focus: 'mobile',
    industries: [Industry.healthcare],
    extraProducts: ['OPS-HOST', 'SUP-SLA', 'DEV-ARC'],
  ),
  _project(
    'Website Relaunch',
    'Relaunch of the corporate website on a headless CMS with multilingual '
        'content and SEO-safe URL migration.',
    ['Next.js', 'Headless CMS', 'Vercel'],
    billing: [_fixed],
    minHours: 350,
    maxHours: 800,
    focus: 'design',
    extraProducts: ['LIC-CMS', 'DES-UI', 'CON-STR'],
  ),
  _project(
    'Pentest Remediation',
    'Remediation of findings from the external penetration test and '
        'hardening of the CI/CD pipelines.',
    ['OWASP ZAP', 'GitLab CI', 'HashiCorp Vault'],
    billing: [_tm],
    minHours: 150,
    maxHours: 400,
    focus: 'ops',
    industries: [Industry.finance, Industry.insurance, Industry.energy],
    extraProducts: ['OPS-DEVOP'],
  ),
  _project(
    'ERP Integration Layer',
    'Event-driven integration between ERP, CRM and warehouse management '
        'based on a message broker.',
    ['Java', 'Apache Camel', 'RabbitMQ', 'SAP IDoc'],
    billing: [_tm],
    minHours: 800,
    maxHours: 2000,
    focus: 'dev',
    industries: [
      Industry.manufacturing,
      Industry.logistics,
      Industry.retail,
      Industry.automotive,
    ],
    extraProducts: ['DEV-ARC'],
  ),
  _project(
    'Claims Processing Automation',
    'Digitisation of the claims intake with AI-based document classification '
        'and a new case worker UI.',
    ['Python', 'FastAPI', 'Angular', 'Azure Document Intelligence'],
    billing: [_tm],
    minHours: 1500,
    maxHours: 3500,
    focus: 'data',
    industries: [Industry.insurance],
    extraProducts: ['DEV-ARC', 'CON-STR'],
  ),
  _project(
    'Fleet Telematics Platform',
    'Vehicle tracking, route history and driver scorecards for the fleet.',
    ['Go', 'PostGIS', 'MapLibre', 'MQTT'],
    billing: [_tm],
    minHours: 1200,
    maxHours: 2800,
    focus: 'dev',
    industries: [Industry.logistics, Industry.automotive],
    extraProducts: ['OPS-HOST', 'OPS-DEVOP'],
  ),
  _project(
    'Loyalty Programme App',
    'Customer loyalty app with digital stamp card, coupons and push '
        'campaigns.',
    ['Flutter', 'Firebase', 'Braze'],
    billing: [_fixed],
    minHours: 700,
    maxHours: 1500,
    focus: 'mobile',
    industries: [Industry.retail, Industry.hospitality],
    extraProducts: ['DES-UI', 'SUP-SLA'],
  ),
  _project(
    'Online Learning Platform',
    'Course platform with video streaming, quizzes and certificates, '
        'LTI 1.3 compatible.',
    ['Laravel', 'Vue.js', 'Mux', 'MySQL'],
    billing: [_tm],
    minHours: 1000,
    maxHours: 2400,
    focus: 'dev',
    industries: [Industry.education],
    extraProducts: ['OPS-HOST'],
  ),
  _project(
    'Smart Meter Portal',
    'Customer portal for smart meter readings, consumption forecasts and '
        'tariff switching.',
    ['Angular', 'Kotlin', 'TimescaleDB'],
    billing: [_tm],
    minHours: 1000,
    maxHours: 2500,
    focus: 'dev',
    industries: [Industry.energy],
    extraProducts: ['OPS-HOST', 'SUP-SLA'],
  ),
  _project(
    'Managed Platform Operations',
    'Ongoing operation, monitoring and patch management of all production '
        'systems built by ACME.',
    ['Kubernetes', 'Prometheus', 'Grafana', 'Loki'],
    billing: [_retainer],
    minHours: 300,
    maxHours: 900,
    focus: 'ops',
    extraProducts: ['OPS-HOST', 'SUP-SLA', 'OPS-DEVOP'],
  ),
  _project(
    'Continuous Development',
    'Monthly development contingent for smaller features, improvements '
        'and dependency updates.',
    ['Flutter', 'TypeScript', 'Kotlin'],
    billing: [_retainer],
    minHours: 400,
    maxHours: 1200,
    focus: 'dev',
    extraProducts: ['SUP-SLA'],
  ),
  _project(
    'Customer Journey Research',
    'Qualitative interviews, journey mapping and usability tests to '
        'prioritise the digital roadmap.',
    ['Dovetail', 'Figma', 'Maze'],
    billing: [_fixed],
    minHours: 120,
    maxHours: 350,
    focus: 'design',
    extraProducts: ['CON-STR', 'TRN-WS'],
  ),
  _project(
    'Accessibility Compliance (BFSG)',
    'Audit and remediation of web and app accessibility according to the '
        'German Accessibility Strengthening Act (BFSG) and WCAG 2.2 AA.',
    ['axe-core', 'WCAG 2.2', 'React'],
    billing: [_fixed, _tm],
    minHours: 200,
    maxHours: 600,
    focus: 'design',
    extraProducts: ['TRN-WS'],
  ),
  _project(
    'Tenant Service App',
    'Tenant app for damage reports, documents, appointments and community '
        'news.',
    ['Flutter', 'Dart', 'Supabase'],
    billing: [_tm],
    minHours: 800,
    maxHours: 1800,
    focus: 'mobile',
    industries: [Industry.realEstate],
    extraProducts: ['SUP-SLA'],
  ),
  _project(
    'Listener Analytics Platform',
    'Download statistics, audience insights and ad inventory forecasting '
        'for all shows of the network.',
    ['Python', 'ClickHouse', 'React'],
    billing: [_tm],
    minHours: 700,
    maxHours: 1500,
    focus: 'data',
    industries: [Industry.media],
    extraProducts: ['OPS-HOST'],
  ),
  _project(
    'AI Knowledge Assistant',
    'RAG-based assistant for internal policies and product documentation, '
        'integrated into Microsoft Teams.',
    ['Python', 'Claude API', 'pgvector', 'Azure'],
    billing: [_tm, _fixed],
    minHours: 400,
    maxHours: 1000,
    focus: 'data',
    extraProducts: ['DEV-ARC', 'TRN-WS'],
  ),
  _project(
    'Journey Planner App',
    'Multimodal journey planner with real-time departures, ticket purchase '
        'and Deutschlandticket integration.',
    ['Kotlin Multiplatform', 'SwiftUI', 'OpenTripPlanner'],
    billing: [_tm],
    minHours: 1600,
    maxHours: 3600,
    focus: 'mobile',
    industries: [Industry.publicSector],
    extraProducts: ['OPS-HOST', 'SUP-SLA', 'DEV-ARC'],
  ),
  _project(
    'Citizen Services Portal (OZG)',
    'Online access to administrative services according to the German '
        'Online Access Act, including BundID login and e-payment.',
    ['Java', 'Spring Boot', 'BundID', 'XÖV'],
    billing: [_fixed],
    minHours: 900,
    maxHours: 2200,
    focus: 'dev',
    industries: [Industry.publicSector],
    extraProducts: ['OPS-HOST', 'SUP-SLA'],
  ),
];

const features = [
  'login flow',
  'document upload',
  'search filters',
  'push notifications',
  'CSV export',
  'role management',
  'offline sync',
  'payment integration',
  'dashboard widgets',
  'multi-language support',
  'audit log',
  'PDF generation',
  'order history',
  'appointment booking',
  'onboarding wizard',
  'notification settings',
];

const components = [
  'user service',
  'billing module',
  'notification service',
  'import pipeline',
  'reporting API',
  'auth middleware',
  'checkout',
  'admin backend',
  'data model',
  'sync engine',
];

const bugs = [
  'session timeout not handled',
  'wrong currency rounding',
  'duplicate e-mails',
  'layout broken on iPad',
  'timezone offset in reports',
  'race condition in sync',
  'missing translations',
  'memory leak in image cache',
];

const engineeringTasks = [
  'Implemented {feature}',
  'Implemented {feature}',
  'Code review',
  'Bugfix: {bug}',
  'Refactoring {component}',
  'Sprint planning & estimation',
  'Daily stand-up & sync',
  'Pair programming on {feature}',
  'Integration tests for {component}',
  'Deployment to staging',
  'Investigated production issue',
  'API design for {component}',
  'Performance optimisation of {component}',
  'Database migration for {component}',
  'Dependency updates & security patches',
];

const devOpsTasks = [
  'Terraform: {component} infrastructure',
  'CI/CD pipeline improvements',
  'Kubernetes cluster upgrade',
  'Monitoring & alerting setup',
  'Backup & restore test',
  'Incident post-mortem',
  'Cloud cost review',
  'Secrets rotation',
];

const designTasks = [
  'Wireframes for {feature}',
  'High-fidelity mockups: {feature}',
  'Usability test preparation',
  'Conducted user interviews',
  'Design review with client',
  'Design system: component updates',
  'Clickable prototype for {feature}',
  'Icons & illustrations',
  'Accessibility review of {feature}',
];

const managementTasks = [
  'Sprint review & planning',
  'Steering committee meeting',
  'Backlog refinement',
  'Status report & budget tracking',
  'Stakeholder alignment call',
  'Release planning',
  'Requirements workshop',
  'Risk assessment',
  'Acceptance testing with client',
];

const nonBillableTasks = [
  'Internal knowledge transfer',
  'Onboarding into the codebase',
  'Estimation for change request',
  'Internal retro',
];

typedef TicketTemplate = ({
  String subject,
  String body,
  List<String> labels,
  Priority priority,
  String resolution,
});

TicketTemplate _ticket(
  String subject,
  String body,
  List<String> labels,
  Priority priority,
  String resolution,
) => (
  subject: subject,
  body: body,
  labels: labels,
  priority: priority,
  resolution: resolution,
);

final ticketTemplates = <TicketTemplate>[
  _ticket(
    'SSO login fails for some users',
    'Since this morning several colleagues cannot log in via Microsoft SSO. '
        'Error message: "AADSTS50011: The redirect URI does not match". '
        'Could you please have a look?',
    ['auth', 'sso'],
    Priority.high,
    'The redirect URI in the app registration was outdated after the domain '
        'change. Added the new URI and verified the login with two affected '
        'users.',
  ),
  _ticket(
    'Checkout page loads very slowly',
    'Our customers complain that the checkout takes 10+ seconds to load, '
        'especially in the evening. Conversion dropped noticeably.',
    ['performance', 'shop'],
    Priority.high,
    'A missing database index on the price table caused full scans. Index '
        'added, p95 load time is back at 800 ms.',
  ),
  _ticket(
    'PDF export shows wrong date format',
    'Dates in the exported PDF reports are shown as MM/DD/YYYY instead of '
        'DD.MM.YYYY.',
    ['bug', 'export'],
    Priority.low,
    'The locale was not passed to the PDF renderer. Fixed in release 2.14.1.',
  ),
  _ticket(
    'New user role for external auditors',
    'We need a read-only role for our external auditors who should only see '
        'the reports section. Is this possible?',
    ['feature-request', 'permissions'],
    Priority.low,
    'Created a new role "Auditor" with read-only access to reports. Estimated '
        'as 3 hours, booked on the maintenance contingent.',
  ),
  _ticket(
    'Production outage – 502 Bad Gateway',
    'The application is not reachable at all, all users get a 502 error. '
        'This is critical for us, please call back immediately!',
    ['outage', 'infrastructure'],
    Priority.critical,
    'A failed node pool upgrade left the ingress controller without healthy '
        'backends. Rolled back, service restored after 23 minutes. '
        'Post-mortem was shared via e-mail.',
  ),
  _ticket(
    'SSL certificate expires in 7 days',
    'Our monitoring reports that the certificate for the staging domain '
        'expires next week.',
    ['infrastructure', 'certificates'],
    Priority.normal,
    'Staging domain was missing in the cert-manager configuration. Switched '
        'to automated renewal via Let\'s Encrypt.',
  ),
  _ticket(
    'Newsletter sign-up does not send confirmation mails',
    'Customers sign up for the newsletter but never receive the double '
        'opt-in e-mail.',
    ['bug', 'email'],
    Priority.normal,
    'The API key for the mailing provider had expired. Rotated the key and '
        're-sent the pending confirmations (143 recipients).',
  ),
  _ticket(
    'Please add a new colleague to staging',
    'Our new product manager starts on Monday and needs access to the staging '
        'environment and the Jira board.',
    ['access'],
    Priority.low,
    'Account created and invitation sent.',
  ),
  _ticket(
    'Question about invoiced hours',
    'The hours on the last invoice seem higher than expected. Could you send '
        'us a breakdown per person and topic?',
    ['billing'],
    Priority.normal,
    'Sent a detailed timesheet export. The additional hours were caused by '
        'the change request approved in the last steering committee.',
  ),
  _ticket(
    'App crashes on Android 15 when opening the camera',
    'Several users report that the app closes immediately when they try to '
        'take a photo. Affected devices: Pixel 8, Galaxy S24.',
    ['bug', 'mobile', 'android'],
    Priority.high,
    'Missing permission handling for the new photo picker API. Hotfix 3.2.1 '
        'released to the Play Store.',
  ),
  _ticket(
    'ERP import stuck since last night',
    'No new orders have been imported from the ERP since 02:00. The queue '
        'seems to be growing.',
    ['integration', 'erp'],
    Priority.high,
    'A malformed IDoc blocked the queue. Moved it to the dead letter queue, '
        'processing resumed. Added an alert for queue age > 30 minutes.',
  ),
  _ticket(
    'Typo on the landing page',
    'There is a typo in the headline of the German landing page '
        '("Kundenservive").',
    ['content'],
    Priority.low,
    'Fixed.',
  ),
  _ticket(
    'Search returns no results for umlauts',
    'Searching for "Müller" returns nothing, searching for "Muller" works.',
    ['bug', 'search'],
    Priority.normal,
    'Search index analyzer changed to ASCII folding, index rebuilt.',
  ),
  _ticket(
    'GDPR deletion request',
    'We received a data deletion request according to Art. 17 GDPR for one '
        'of our customers. Details are in the attached (encrypted) file.',
    ['gdpr', 'privacy'],
    Priority.high,
    'Data deleted in all systems including backups rotation. Deletion '
        'protocol sent to the data protection officer.',
  ),
  _ticket(
    'Push notifications arrive twice on iOS',
    'Since the last update users on iOS get every push notification twice.',
    ['bug', 'mobile', 'ios'],
    Priority.normal,
    'Device tokens were registered twice after app updates. Deduplicated '
        'tokens and fixed the registration logic.',
  ),
  _ticket(
    'Monthly API usage report',
    'Can you provide a report of all API calls from last month grouped by '
        'partner?',
    ['reporting'],
    Priority.low,
    'Report generated and shared via the customer portal.',
  ),
  _ticket(
    'Password reset e-mails land in spam',
    'Many users say the password reset mail ends up in their spam folder.',
    ['email', 'deliverability'],
    Priority.normal,
    'DMARC policy was missing. Configured SPF, DKIM and DMARC together with '
        'the client\'s IT.',
  ),
  _ticket(
    'Dashboard numbers do not match Excel export',
    'The revenue figure on the dashboard differs from the Excel export by '
        'roughly 2 %.',
    ['bug', 'reporting'],
    Priority.normal,
    'Dashboard excluded cancelled orders while the export included them. '
        'Aligned both to exclude cancellations.',
  ),
  _ticket(
    'Quote request: dark mode',
    'Our users would love a dark mode for the portal. Could you send us an '
        'estimate?',
    ['feature-request'],
    Priority.low,
    'Estimate sent (approx. 40 hours incl. design).',
  ),
  _ticket(
    'CRM webhook returns 401 since key rotation',
    'After rotating our API keys yesterday, the webhook to the CRM fails '
        'with 401 Unauthorized.',
    ['integration', 'auth'],
    Priority.high,
    'Updated the webhook secret in the vault and re-triggered the failed '
        'deliveries.',
  ),
  _ticket(
    'Cookie banner not shown in Safari',
    'The consent banner does not appear in Safari on macOS, so tracking is '
        'disabled for those users.',
    ['bug', 'consent'],
    Priority.normal,
    'Intelligent Tracking Prevention blocked the consent script domain. '
        'Moved the script to first-party hosting.',
  ),
  _ticket(
    'Request for additional staging environment',
    'For the upcoming campaign we would need a second staging environment '
        'for the agency to test their content.',
    ['infrastructure', 'feature-request'],
    Priority.low,
    'Second staging environment provisioned via Terraform workspace.',
  ),
];

const ticketChannelWeights = {
  TicketChannel.email: 5,
  TicketChannel.portal: 4,
  TicketChannel.phone: 2,
  TicketChannel.chat: 2,
};
