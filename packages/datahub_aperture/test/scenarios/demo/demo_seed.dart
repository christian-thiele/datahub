import 'dart:math' as math;

import 'package:datahub/datahub.dart';

import 'data/address.dart';
import 'data/billing_type.dart';
import 'data/client.dart';
import 'data/client_tier.dart';
import 'data/contact.dart';
import 'data/contact_type.dart';
import 'data/department.dart';
import 'data/employee.dart';
import 'data/industry.dart';
import 'data/invoice.dart';
import 'data/invoice_line.dart';
import 'data/invoice_status.dart';
import 'data/price_unit_type.dart';
import 'data/priority.dart';
import 'data/product.dart';
import 'data/project.dart';
import 'data/project_status.dart';
import 'data/support_ticket.dart';
import 'data/ticket_channel.dart';
import 'data/ticket_status.dart';
import 'data/time_entry.dart';
import 'demo_fixtures.dart';

/// Fills all demo repositories with interconnected, plausible data.
///
/// The data is generated relative to the current date, so the demo always
/// shows active projects, fresh timesheets and open tickets. A fixed [seed]
/// keeps the generated data stable between restarts on the same day.
Future<void> seedDemoData({int seed = 42}) =>
    _DemoSeeder(math.Random(seed), DateTime.now().toUtc()).run();

const _euCountries = {'AT', 'SE', 'NL', 'IT', 'PT', 'FI'};
const _nonEuCountries = {'CH', 'GB'};

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class _ClientContext {
  final ClientFixture fixture;
  final Client client;
  final List<ProjectTemplate> templates;
  final DateTime? churnDate;
  final double paymentReliability;
  final contacts = <Contact>[];
  final products = <String, Product>{};
  final projects = <_ProjectPlan>[];

  _ClientContext(
    this.fixture,
    this.client,
    this.templates,
    this.churnDate,
    this.paymentReliability,
  );

  double get taxRate => client.addressCountry == 'DE' ? 0.19 : 0.0;

  /// Short project key prefix, e.g. "NOL" for "Nordwind Logistik".
  String get key {
    final words = client.name
        .replaceAll(RegExp('[^A-Za-z ]'), '')
        .split(' ')
        .where((e) => e.length > 1)
        .toList();
    final key = words.length > 1
        ? '${words[0].substring(0, 2)}${words[1][0]}'
        : words[0].substring(0, 3);
    return key.toUpperCase();
  }

  Contact? get financialContact =>
      contacts.where((c) => c.type == ContactType.financial).firstOrNull;
}

class _ProjectPlan {
  final _ClientContext ctx;
  final ProjectTemplate template;
  final BillingType billing;
  final DateTime start;
  final DateTime? end;
  final ProjectStatus status;
  final DateTime? pausedSince;
  final int hours;
  final double budget;
  final double? monthlyFee;
  final int lead;
  final List<int> team;
  final Priority priority;
  late final Project project;

  _ProjectPlan({
    required this.ctx,
    required this.template,
    required this.billing,
    required this.start,
    required this.end,
    required this.status,
    required this.pausedSince,
    required this.hours,
    required this.budget,
    required this.monthlyFee,
    required this.lead,
    required this.team,
    required this.priority,
  });

  bool get isBooking =>
      status == ProjectStatus.active ||
      status == ProjectStatus.onHold ||
      status == ProjectStatus.completed ||
      status == ProjectStatus.cancelled;
}

class _InvoicePlan {
  final _ClientContext ctx;
  final _ProjectPlan? project;
  final DateTime issuedAt;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final List<InvoiceLine> lines;

  _InvoicePlan(
    this.ctx,
    this.project,
    this.issuedAt,
    this.lines, {
    this.periodStart,
    this.periodEnd,
  });
}

class _DemoSeeder {
  final math.Random r;
  final DateTime now;
  final DateTime today;

  /// Time entries are generated in detail from this date on.
  /// Everything before is summarized (e.g. in invoices only).
  final DateTime windowStart;

  _DemoSeeder(this.r, this.now)
    : today = DateTime.utc(now.year, now.month, now.day),
      windowStart = DateTime.utc(now.year, now.month - 5, 1);

  final employees = <Employee>[];
  final clients = <_ClientContext>[];
  final projects = <_ProjectPlan>[];
  final timeEntries = <TimeEntry>[];

  Future<void> run() async {
    await _createEmployees();
    await _createClients();
    await _createContacts();
    _planProjects();
    await _createProducts();
    await _createProjects();
    _planTimeEntries();
    final invoices = _planInvoices();
    await _createTimeEntries();
    await _createInvoices(invoices);
    await _createTickets();
  }

  // --- employees -----------------------------------------------------------

  Future<void> _createEmployees() async {
    final repo = Find<DataRepository<Employee>>().find();
    for (final (i, f) in employeeFixtures.indexed) {
      employees.add(
        await repo.create(
          Employee(
            personnelNumber: 'E${1001 + i * 3}',
            firstName: f.firstName,
            lastName: f.lastName,
            email: '${_slug(f.firstName)}.${_slug(f.lastName)}@$agencyDomain',
            jobTitle: f.jobTitle,
            department: f.department,
            hiredAt: _parseDate(f.hired),
            hourlyCostRate: f.costRate,
            weeklyHours: f.weeklyHours,
            skills: f.skills,
            languages: f.languages,
            managerId: f.manager != null ? employees[f.manager!].id : null,
            remote: f.remote,
            active: f.active,
          ),
        ),
      );
    }
  }

  // --- clients -------------------------------------------------------------

  Future<void> _createClients() async {
    final repo = Find<DataRepository<Client>>().find();
    for (final (i, f) in clientFixtures.indexed) {
      final currency = countryCurrency[f.country] ?? 'EUR';
      final accountManager = switch (f.tier) {
        ClientTier.platinum => _pick([0, 4]),
        ClientTier.prospect => 17,
        _ => _pick(accountManagers),
      };
      final inbox = f.country == 'DE' || f.country == 'AT'
          ? _pick(['info', 'kontakt', 'office'])
          : _pick(['info', 'hello', 'office']);

      final client = await repo.create(
        Client(
          customerNumber: 'C-${10017 + i * 23}',
          name: f.name,
          legalName: f.legalName,
          industry: f.industry,
          tier: f.tier,
          website: 'https://www.${f.domain}',
          email: '$inbox@${f.domain}',
          phone: '${_phone(f.country, f.areaCode)}0',
          vatId: _vatId(f.country, f.industry),
          addressStreet: f.street,
          addressPostalCode: f.postalCode,
          addressCity: f.city,
          addressCountry: f.country,
          location: Point(wgs84, f.lon, f.lat),
          onboarded: _parseDate(f.onboarded),
          employeeCount: f.employees,
          annualRevenue: f.revenue,
          paymentTermDays: f.industry == Industry.publicSector
              ? 30
              : tierPaymentTerms[f.tier]!,
          currency: currency,
          tags: f.tags,
          notes: f.notes,
          accountManagerId: employees[accountManager].id,
          active: f.active,
        ),
      );

      final templates = _chooseTemplates(f);
      final churnDate = f.active
          ? null
          : DateTime.utc(today.year, today.month - 9, 1);
      final reliability = switch (f.industry) {
        Industry.publicSector => 0.75,
        _ when f.tier == ClientTier.bronze => _pick([0.8, 0.9, 0.95]),
        _ => _pick([0.9, 0.95, 0.98]),
      };

      clients.add(_ClientContext(f, client, templates, churnDate, reliability));
    }
  }

  List<ProjectTemplate> _chooseTemplates(ClientFixture f) {
    if (f.tier == ClientTier.prospect) {
      final matching = projectTemplates
          .where((t) => t.industries.contains(f.industry))
          .toList();
      return [
        _pick(
          matching.isNotEmpty
              ? matching
              : projectTemplates.where((t) => t.focus == 'design').toList(),
        ),
      ];
    }

    final (min, max) = tierProjectCount[f.tier]!;
    final count = _between(min, max);
    final pool = [
      for (final t in projectTemplates)
        if (t.industries.contains(f.industry))
          ...List.filled(5, t)
        else if (t.industries.isEmpty)
          t,
    ];

    final result = <ProjectTemplate>[];
    while (result.length < count && pool.isNotEmpty) {
      final t = _pick(pool);
      result.add(t);
      pool.removeWhere((e) => e == t);
    }
    return result;
  }

  // --- contacts ------------------------------------------------------------

  Future<void> _createContacts() async {
    final repo = Find<DataRepository<Contact>>().find();
    for (final ctx in clients) {
      final f = ctx.fixture;
      final count = switch (f.tier) {
        ClientTier.prospect => 2,
        ClientTier.bronze => _between(2, 3),
        ClientTier.silver => _between(3, 4),
        ClientTier.gold => _between(4, 5),
        ClientTier.platinum => _between(5, 7),
      };
      final types = [
        ContactType.executive,
        ContactType.technical,
        ContactType.financial,
        for (var i = 3; i < count; i++)
          _pick([
            ContactType.employee,
            ContactType.employee,
            ContactType.technical,
            ContactType.procurement,
            ContactType.legal,
          ]),
      ].take(count);

      final pool =
          namePools[switch (f.country) {
            'AT' => 'at',
            'CH' => 'fr',
            _ => countryLanguage[f.country]!,
          }]!;
      final nordic = f.country == 'SE' || f.country == 'FI';
      final shortMailFormat = _chance(0.3);
      final primaryType =
          f.tier == ClientTier.bronze || f.tier == ClientTier.prospect
          ? ContactType.executive
          : ContactType.technical;
      final usedNames = <String>{};

      for (final type in types) {
        String first, last;
        do {
          first = _pick(pool.first);
          last = _pick(pool.last);
        } while (!usedNames.add(last));

        final titleChance = f.industry == Industry.healthcare ? 0.3 : 0.1;
        final lastContacted = (switch (ctx.churnDate) {
          final churn? => churn.subtract(Duration(days: _between(10, 120))),
          null when f.tier == ClientTier.prospect => today.subtract(
            Duration(days: _between(0, 20)),
          ),
          null => today.subtract(Duration(days: _between(0, 90))),
        }).add(Duration(hours: _between(8, 17), minutes: _between(0, 59)));

        final localPart = shortMailFormat
            ? '${_slug(first, nordic: nordic)[0]}.${_slug(last, nordic: nordic)}'
            : '${_slug(first, nordic: nordic)}.${_slug(last, nordic: nordic)}';

        ctx.contacts.add(
          await repo.create(
            Contact(
              title: _chance(titleChance)
                  ? (_chance(0.15) ? 'Prof. Dr.' : 'Dr.')
                  : null,
              firstName: first,
              lastName: last,
              position: _pick(contactPositions[type.name]!),
              email: '$localPart@${f.domain}',
              phone: _phone(f.country, f.areaCode),
              mobile: _chance(0.65) ? _mobile(f.country) : null,
              clientId: ctx.client.id,
              type: type,
              primaryContact:
                  type == primaryType &&
                  !ctx.contacts.any((c) => c.primaryContact),
              language: _chance(0.15) ? 'en' : countryLanguage[f.country]!,
              birthday: _chance(0.45)
                  ? DateTime.utc(
                      _between(1962, 1997),
                      _between(1, 12),
                      _between(1, 28),
                    )
                  : null,
              lastContactedAt: lastContacted,
              newsletterOptIn: _chance(0.35),
            ),
          ),
        );
      }
    }
  }

  // --- projects ------------------------------------------------------------

  void _planProjects() {
    for (final ctx in clients) {
      final onboarded = ctx.client.onboarded;
      final latest = ctx.churnDate ?? today.add(const Duration(days: 75));
      final earliest = _maxDate(
        onboarded.add(const Duration(days: 14)),
        latest.subtract(const Duration(days: 3 * 365)),
      );

      for (final template in ctx.templates) {
        final billing = _pick(template.billing);
        final hours =
            (_between(template.minHours, template.maxHours) ~/ 10) * 10;
        final factor = currencyFactor[ctx.client.currency]!;

        DateTime start;
        if (ctx.client.tier == ClientTier.prospect) {
          start = today.add(Duration(days: _between(30, 70)));
        } else {
          final span = latest.difference(earliest).inDays;
          // bias towards recent projects, so the demo has plenty of activity
          start = earliest.add(
            Duration(days: (math.sqrt(r.nextDouble()) * span).round()),
          );
        }
        start = _nextWeekday(start, DateTime.monday);

        var durationDays = billing == BillingType.retainer
            ? 365
            : ((hours / 5.5) * (0.85 + r.nextDouble() * 0.3)).round().clamp(
                42,
                480,
              );
        var end = start.add(Duration(days: durationDays));

        if (ctx.churnDate case final churn?) {
          if (!start.isBefore(churn)) {
            start = churn.subtract(Duration(days: _between(120, 400)));
          }
          if (end.isAfter(churn)) {
            end = churn.subtract(Duration(days: _between(0, 20)));
          }
          if (end.difference(start).inDays < 42) {
            start = _nextWeekday(
              end.subtract(Duration(days: _between(90, 300))),
              DateTime.monday,
            );
          }
          durationDays = end.difference(start).inDays;
        }

        ProjectStatus status;
        DateTime? pausedSince;
        DateTime? endDate = end;
        if (start.isAfter(today)) {
          status = ProjectStatus.planned;
        } else if (end.isBefore(today)) {
          if (_chance(0.07)) {
            status = ProjectStatus.cancelled;
            endDate = start.add(Duration(days: (durationDays * 0.4).round()));
          } else {
            status = ProjectStatus.completed;
          }
        } else if (billing == BillingType.retainer) {
          status = ProjectStatus.active;
          endDate = null;
        } else if (_chance(0.1) && today.difference(start).inDays > 60) {
          status = ProjectStatus.onHold;
          pausedSince = today.subtract(Duration(days: _between(10, 50)));
        } else {
          status = ProjectStatus.active;
        }

        final double budget;
        final double? monthlyFee;
        if (billing == BillingType.retainer) {
          monthlyFee = _roundTo(hours / 12 * 125 * factor, 100);
          budget = monthlyFee * 12;
        } else {
          monthlyFee = null;
          budget = _roundTo(hours * 130 * factor, 500);
        }

        final lead = _pick(projectLeads);
        final pool = teamPools[template.focus]!;
        final team = <int>{
          lead,
          ..._sample(pool, _between(2, math.min(3, pool.length))),
          if ((template.focus == 'dev' || template.focus == 'mobile') &&
              _chance(0.5))
            _pick([12, 13]),
          if (template.focus != 'ops' && _chance(0.25)) 9,
        }.toList();

        final plan = _ProjectPlan(
          ctx: ctx,
          template: template,
          billing: billing,
          start: start,
          end: endDate,
          status: status,
          pausedSince: pausedSince,
          hours: hours,
          budget: budget,
          monthlyFee: monthlyFee,
          lead: lead,
          team: team,
          priority: _weighted({
            Priority.low: 1,
            Priority.normal: 5,
            Priority.high: 3,
            Priority.critical: 1,
          }),
        );
        ctx.projects.add(plan);
        projects.add(plan);
      }
    }
    projects.sort((a, b) => a.start.compareTo(b.start));
  }

  Future<void> _createProjects() async {
    final repo = Find<DataRepository<Project>>().find();
    final sequence = <int, int>{};
    for (final p in projects) {
      final year = p.start.year;
      final seq = sequence[year] = (sequence[year] ?? 0) + 1;
      final ctx = p.ctx;
      final projectSlug = _slug(p.template.name).replaceAll('.', '-');
      final clientSlug = _slug(ctx.client.name).replaceAll('.', '-');
      final key =
          ctx.key +
          p.template.name
              .split(' ')
              .where((w) => w.startsWith(RegExp('[A-Z]')))
              .map((w) => w[0])
              .take(2)
              .join();

      p.project = await repo.create(
        Project(
          code: 'P-$year-${seq.toString().padLeft(3, '0')}',
          name: p.template.name,
          description: p.template.description,
          clientId: ctx.client.id,
          projectLeadId: employees[p.lead].id,
          status: p.status,
          priority: p.priority,
          billingType: p.billing,
          startDate: p.start,
          endDate: p.end,
          budget: p.budget,
          estimatedHours: p.hours,
          technologies: p.template.technologies,
          links: {
            'board':
                'https://brightline.atlassian.net/jira/software/projects/$key',
            if (p.status != ProjectStatus.planned) ...{
              'repository':
                  'https://git.$agencyDomain/$clientSlug/$projectSlug',
              if (p.template.focus == 'design')
                'figma':
                    'https://www.figma.com/files/team/brightline/$projectSlug'
              else
                'staging': 'https://$projectSlug.staging.$agencyDomain',
            },
          },
        ),
      );
    }
  }

  // --- products ------------------------------------------------------------

  Future<void> _createProducts() async {
    final repo = Find<DataRepository<Product>>().find();
    final catalogByCode = {for (final c in catalog) c.code: c};

    for (final ctx in clients) {
      final client = ctx.client;
      final isProspect = client.tier == ClientTier.prospect;
      final codes = <String>{
        if (isProspect) ...['CON-STR', 'DEV-SEN'] else ...coreCatalogCodes,
        if (!isProspect)
          for (final t in ctx.templates) ...t.extraProducts,
      };

      final factor = currencyFactor[client.currency]!;
      final yearsWithUs = today.difference(client.onboarded).inDays / 365;
      // long-standing clients still enjoy slightly older price levels
      final legacyFactor = 1 - (yearsWithUs * 0.01).clamp(0, 0.06);
      final renewed = yearsWithUs > 1.5;

      for (final code in catalog.map((e) => e.code).where(codes.contains)) {
        final item = catalogByCode[code]!;
        var title = item.title;
        var listPrice = item.listPrice;
        if (code == 'SUP-SLA') {
          final (level, multiplier) = switch (client.tier) {
            ClientTier.platinum => ('Premium', 2.5),
            ClientTier.gold => ('Business', 1.6),
            _ => ('Basic', 1.0),
          };
          title = '$title ($level)';
          listPrice *= multiplier;
        }

        final validFrom = isProspect
            ? client.onboarded.add(Duration(days: _between(3, 20)))
            : renewed
            ? DateTime.utc(today.year, 1, 1)
            : client.onboarded.add(Duration(days: _between(0, 14)));
        final validUntil = isProspect
            ? validFrom.add(const Duration(days: 90))
            : ctx.churnDate ??
                  (_chance(0.6) ? DateTime.utc(today.year, 12, 31) : null);
        final isTimeBased =
            item.unit == PriceUnitType.hour || item.unit == PriceUnitType.day;

        ctx.products[code] = await repo.create(
          Product(
            sku: '$code-${client.customerNumber.substring(2)}',
            title: title,
            description: item.description,
            category: item.category,
            price: _roundPrice(
              listPrice * factor * legacyFactor,
              item.unit,
              client.currency,
            ),
            unit: item.unit,
            taxRate: ctx.taxRate,
            discount: isTimeBased ? tierDiscount[client.tier]! : 0,
            validFrom: validFrom,
            validUntil: validUntil,
            clientId: client.id,
            active: ctx.churnDate == null,
          ),
        );
      }
    }
  }

  // --- time entries --------------------------------------------------------

  void _planTimeEntries() {
    final load = <(int, DateTime), double>{};
    final vacations = {
      for (var i = 0; i < employeeFixtures.length; i++)
        i: () {
          final from = windowStart.add(Duration(days: _between(0, 130)));
          return (from, from.add(Duration(days: _between(7, 18))));
        }(),
    };

    for (
      var day = windowStart;
      day.isBefore(today);
      day = day.add(const Duration(days: 1))
    ) {
      if (day.weekday > DateTime.friday) {
        continue;
      }

      for (final p in projects.where((p) => p.isBooking)) {
        if (day.isBefore(p.start) ||
            day.isAfter(p.end ?? today) ||
            (p.pausedSince != null && !day.isBefore(p.pausedSince!))) {
          continue;
        }

        for (final member in p.team) {
          final f = employeeFixtures[member];
          final (vacationFrom, vacationTo) = vacations[member]!;
          if (!f.active ||
              _parseDate(f.hired).isAfter(day) ||
              (!day.isBefore(vacationFrom) && day.isBefore(vacationTo))) {
            continue;
          }

          final isPm = f.department == Department.projectManagement;
          final probability = isPm
              ? 0.3
              : f.weeklyHours < 40
              ? 0.3
              : 0.55;
          if (!_chance(probability)) {
            continue;
          }

          final booked = load[(member, day)] ?? 0;
          final capacity = f.weeklyHours / 5 + 0.5 - booked;
          final hours = math.min<double>(
            _pick(
              isPm
                  ? [0.5, 1.0, 1.0, 1.5, 2.0, 3.0]
                  : [
                      1.0,
                      1.5,
                      2.0,
                      2.5,
                      3.0,
                      4.0,
                      4.0,
                      5.0,
                      6.0,
                      6.5,
                      7.5,
                      8.0,
                    ],
            ),
            (capacity * 4).floor() / 4,
          );
          if (hours < 0.5) {
            continue;
          }
          load[(member, day)] = booked + hours;

          final internal = _chance(0.06);
          final entry = TimeEntry(
            date: day,
            hours: hours,
            description: internal
                ? _pick(nonBillableTasks)
                : _taskDescription(f),
            projectId: p.project.id,
            employeeId: employees[member].id,
            productId: internal ? null : _productFor(p.ctx, f)?.id,
            billable: !internal && p.billing != BillingType.fixedPrice,
          );
          timeEntries.add(entry);
        }
      }
    }
  }

  String _taskDescription(EmployeeFixture f) {
    final template = switch (f.department) {
      Department.design => _pick(designTasks),
      Department.projectManagement => _pick(managementTasks),
      _ when f.jobTitle.contains('DevOps') => _pick(devOpsTasks),
      _ => _pick(engineeringTasks),
    };
    return template
        .replaceAll('{feature}', _pick(features))
        .replaceAll('{component}', _pick(components))
        .replaceAll('{bug}', _pick(bugs));
  }

  Product? _productFor(_ClientContext ctx, EmployeeFixture f) {
    final candidates = switch (f.department) {
      Department.design when f.jobTitle.startsWith('UI') => [
        'DES-UI',
        'DES-UX',
      ],
      Department.design => ['DES-UX'],
      Department.projectManagement => ['PMG-SCR'],
      Department.management => ['DEV-ARC', 'DEV-SEN'],
      _ when f.jobTitle.contains('DevOps') => ['OPS-DEVOP', 'DEV-SEN'],
      _ when f.costRate >= 75 => ['DEV-SEN'],
      _ => ['DEV-JUN'],
    };
    return candidates.map((c) => ctx.products[c]).nonNulls.firstOrNull;
  }

  Future<void> _createTimeEntries() async {
    final repo = Find<DataRepository<TimeEntry>>().find();
    for (final entry in timeEntries) {
      await repo.create(entry);
    }
  }

  // --- invoices ------------------------------------------------------------

  List<_InvoicePlan> _planInvoices() {
    final invoices = <_InvoicePlan>[];
    final currentMonth = DateTime.utc(today.year, today.month);
    // recurring invoices for next month are already prepared as drafts
    final draftMonth = DateTime.utc(today.year, today.month + 1);

    for (final p in projects.where((p) => p.isBooking)) {
      final ctx = p.ctx;
      final lastDay = p.end ?? today;

      switch (p.billing) {
        case BillingType.timeAndMaterial:
          for (
            var month = DateTime.utc(p.start.year, p.start.month);
            month.isBefore(currentMonth) && !month.isAfter(lastDay);
            month = DateTime.utc(month.year, month.month + 1)
          ) {
            final nextMonth = DateTime.utc(month.year, month.month + 1);
            final issuedAt = _nextWorkday(
              nextMonth.add(const Duration(days: 1)),
            );
            if (issuedAt.isAfter(today)) {
              continue;
            }

            final lines = month.isBefore(windowStart)
                ? _estimatedLines(p, month, nextMonth)
                : _bookedLines(p, month, nextMonth);
            if (lines.isNotEmpty) {
              invoices.add(
                _InvoicePlan(
                  ctx,
                  p,
                  issuedAt,
                  lines,
                  periodStart: month,
                  periodEnd: nextMonth.subtract(const Duration(days: 1)),
                ),
              );
            }
          }

        case BillingType.fixedPrice:
          final duration = lastDay.difference(p.start);
          final milestones = [
            (
              0.3,
              'Milestone 1: Kick-off & concept',
              p.start.add(const Duration(days: 7)),
            ),
            (
              0.4,
              'Milestone 2: Implementation & beta',
              p.start.add(duration ~/ 2),
            ),
            if (p.status == ProjectStatus.completed)
              (
                0.3,
                'Milestone 3: Acceptance & go-live',
                lastDay.add(const Duration(days: 5)),
              ),
          ];
          for (final (share, label, date) in milestones) {
            final issuedAt = _nextWorkday(date);
            if (issuedAt.isAfter(today) ||
                (p.status == ProjectStatus.cancelled &&
                    issuedAt.isAfter(lastDay))) {
              continue;
            }
            invoices.add(
              _InvoicePlan(ctx, p, issuedAt, [
                InvoiceLine(
                  position: 1,
                  description: '$label – ${p.template.name}',
                  quantity: 1,
                  unit: PriceUnitType.flat,
                  unitPrice: _round2(p.budget * share),
                  taxRate: ctx.taxRate,
                ),
              ]),
            );
          }

        case BillingType.retainer:
          for (
            var month = DateTime.utc(p.start.year, p.start.month);
            !month.isAfter(draftMonth) && !month.isAfter(lastDay);
            month = DateTime.utc(month.year, month.month + 1)
          ) {
            final issuedAt = _nextWorkday(month);
            if (issuedAt.isAfter(today) && month != draftMonth) {
              continue;
            }
            final nextMonth = DateTime.utc(month.year, month.month + 1);
            invoices.add(
              _InvoicePlan(
                ctx,
                p,
                issuedAt,
                [
                  InvoiceLine(
                    position: 1,
                    description:
                        'Monthly retainer ${p.template.name} – ${_monthLabel(month)}',
                    quantity: 1,
                    unit: PriceUnitType.month,
                    unitPrice: p.monthlyFee!,
                    taxRate: ctx.taxRate,
                  ),
                ],
                periodStart: month,
                periodEnd: nextMonth.subtract(const Duration(days: 1)),
              ),
            );
            _markInvoiced(p, month, nextMonth);
          }
      }
    }

    // recurring hosting, SLA and license fees, independent of projects
    for (final ctx in clients) {
      final recurring = [
        'OPS-HOST',
        'SUP-SLA',
        'LIC-CMS',
      ].map((code) => ctx.products[code]).nonNulls.toList();
      final firstStart = ctx.projects
          .where((p) => p.isBooking)
          .map((p) => p.start)
          .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
      if (recurring.isEmpty || firstStart == null) {
        continue;
      }

      final goLive = firstStart.add(const Duration(days: 90));
      final until = ctx.churnDate ?? draftMonth;
      for (
        var month = _maxDate(
          DateTime.utc(goLive.year, goLive.month),
          DateTime.utc(today.year - 1, today.month),
        );
        !month.isAfter(until);
        month = DateTime.utc(month.year, month.month + 1)
      ) {
        final issuedAt = _nextWorkday(month);
        if (issuedAt.isAfter(today) && month != draftMonth) {
          continue;
        }
        final lines = [
          for (final product in recurring)
            if (product.unit != PriceUnitType.license ||
                month.month == ctx.client.onboarded.month)
              _line(product, 1, '${product.title} – ${_monthLabel(month)}'),
        ];
        if (lines.isNotEmpty) {
          invoices.add(
            _InvoicePlan(
              ctx,
              null,
              issuedAt,
              lines,
              periodStart: month,
              periodEnd: DateTime.utc(month.year, month.month + 1, 0),
            ),
          );
        }
      }
    }

    return invoices..sort((a, b) => a.issuedAt.compareTo(b.issuedAt));
  }

  List<InvoiceLine> _bookedLines(
    _ProjectPlan p,
    DateTime from,
    DateTime until,
  ) {
    final hoursByProduct = <String, double>{};
    for (final (i, e) in timeEntries.indexed) {
      if (e.projectId == p.project.id &&
          e.billable &&
          e.productId != null &&
          !e.date.isBefore(from) &&
          e.date.isBefore(until)) {
        hoursByProduct[e.productId!] =
            (hoursByProduct[e.productId!] ?? 0) + e.hours;
        timeEntries[i] = e.copyWith(invoiced: true);
      }
    }

    final products = {for (final p in p.ctx.products.values) p.id: p};
    return [
      for (final MapEntry(key: productId, value: hours)
          in hoursByProduct.entries)
        _line(
          products[productId]!,
          hours,
          '${products[productId]!.title} – ${_monthLabel(from)}',
        ),
    ];
  }

  /// Plausible invoice lines for months before the detailed time window.
  List<InvoiceLine> _estimatedLines(
    _ProjectPlan p,
    DateTime from,
    DateTime until,
  ) {
    final activeFrom = _maxDate(from, p.start);
    final activeUntil = _minDate(until, p.end ?? until);
    final share =
        activeUntil.difference(activeFrom).inDays /
        until.difference(from).inDays;
    if (share <= 0) {
      return [];
    }

    final ranges = switch (p.template.focus) {
      'design' => {'DES-UX': (40, 120), 'DES-UI': (20, 80), 'PMG-SCR': (5, 20)},
      'ops' => {
        'OPS-DEVOP': (60, 140),
        'DEV-SEN': (10, 40),
        'PMG-SCR': (5, 15),
      },
      'data' => {
        'DEV-SEN': (60, 150),
        'DEV-JUN': (40, 120),
        'DEV-ARC': (5, 20),
        'PMG-SCR': (10, 25),
      },
      _ => {
        'DEV-SEN': (60, 150),
        'DEV-JUN': (40, 140),
        'DES-UX': (0, 30),
        'PMG-SCR': (10, 30),
      },
    };

    return [
      for (final MapEntry(key: code, value: (min, max)) in ranges.entries)
        if (p.ctx.products[code] case final product?)
          if (((min + r.nextDouble() * (max - min)) * share * 4).round() / 4
              case final hours when hours >= 1)
            _line(product, hours, '${product.title} – ${_monthLabel(from)}'),
    ];
  }

  void _markInvoiced(_ProjectPlan p, DateTime from, DateTime until) {
    for (final (i, e) in timeEntries.indexed) {
      if (e.projectId == p.project.id &&
          e.billable &&
          !e.date.isBefore(from) &&
          e.date.isBefore(until)) {
        timeEntries[i] = e.copyWith(invoiced: true);
      }
    }
  }

  InvoiceLine _line(Product product, double quantity, String description) =>
      InvoiceLine(
        position: 0,
        description: description,
        sku: product.sku,
        quantity: quantity,
        unit: product.unit,
        unitPrice: product.price,
        discount: product.discount,
        taxRate: product.taxRate,
      );

  Future<void> _createInvoices(List<_InvoicePlan> plans) async {
    final repo = Find<DataRepository<Invoice>>().find();
    final sequence = <int, int>{};

    for (final plan in plans) {
      final ctx = plan.ctx;
      final client = ctx.client;
      final year = plan.issuedAt.year;
      final seq = sequence[year] = (sequence[year] ?? 0) + 1;
      final invoiceNumber = 'INV-$year-${seq.toString().padLeft(4, '0')}';
      final dueAt = plan.issuedAt.add(Duration(days: client.paymentTermDays));

      final lines = [
        for (final (i, line) in plan.lines.indexed)
          line.copyWith(position: i + 1),
      ];
      final net = _round2(lines.fold(0.0, (sum, l) => sum + l.net));
      final tax = _round2(lines.fold(0.0, (sum, l) => sum + l.tax));

      var status = InvoiceStatus.sent;
      DateTime? paidAt;
      var reminders = 0;
      final age = today.difference(plan.issuedAt).inDays;
      if (plan.issuedAt.isAfter(today)) {
        status = InvoiceStatus.draft;
      } else if (age > 10 && _chance(0.015)) {
        status = InvoiceStatus.cancelled;
      } else if (dueAt.isBefore(today)) {
        if (age > 120 || _chance(ctx.paymentReliability)) {
          status = InvoiceStatus.paid;
          final latePayer = ctx.paymentReliability < 0.9;
          paidAt = _minDate(
            plan.issuedAt.add(
              Duration(
                days: _between(
                  3,
                  client.paymentTermDays + (latePayer ? 25 : 2),
                ),
              ),
            ),
            today.subtract(const Duration(days: 1)),
          );
        } else {
          status = InvoiceStatus.overdue;
          reminders = math.min(3, today.difference(dueAt).inDays ~/ 14);
        }
      } else if (age <= 6 && _chance(0.35)) {
        status = InvoiceStatus.draft;
      } else if (age > 3 && _chance(0.3)) {
        status = InvoiceStatus.paid;
        paidAt = plan.issuedAt.add(Duration(days: _between(2, age - 1)));
      }

      final country = client.addressCountry;
      final notes = [
        if (_euCountries.contains(country))
          'Reverse charge – VAT liability of the recipient '
              '(Art. 196 EU VAT Directive).',
        if (_nonEuCountries.contains(country))
          'Not taxable in Germany – place of supply is the country of the '
              'recipient (§ 3a (2) UStG).',
        if (client.industry == Industry.publicSector)
          'Submitted as XRechnung via the central e-invoicing portal.',
        if (client.tags.contains('framework-contract'))
          'PO ${4500000000 + r.nextInt(99999999)}',
        if (status == InvoiceStatus.cancelled)
          'Cancelled – replaced due to incorrect service period.',
      ];

      final financial = ctx.financialContact;
      await repo.create(
        Invoice(
          invoiceNumber: invoiceNumber,
          clientId: client.id,
          projectId: plan.project?.project.id,
          status: status,
          issuedAt: plan.issuedAt,
          dueAt: dueAt,
          paidAt: paidAt,
          servicePeriodStart: plan.periodStart,
          servicePeriodEnd: plan.periodEnd,
          billingAddress: Address(
            recipient: client.legalName,
            attention: financial != null
                ? '${financial.firstName} ${financial.lastName}'
                : 'Accounts Payable',
            street: client.addressStreet,
            postalCode: client.addressPostalCode,
            city: client.addressCity,
            country: country,
          ),
          lines: lines,
          netTotal: net,
          taxTotal: tax,
          grossTotal: _round2(net + tax),
          currency: client.currency,
          paymentReference: status == InvoiceStatus.paid
              ? _weighted({
                  invoiceNumber: 6,
                  'SEPA ${_alphanumeric(12)}': 3,
                  'NOTPROVIDED': 1,
                })
              : null,
          remindersSent: reminders,
          notes: notes.isEmpty ? null : notes.join('\n'),
        ),
      );
    }
  }

  // --- tickets -------------------------------------------------------------

  Future<void> _createTickets() async {
    final repo = Find<DataRepository<SupportTicket>>().find();
    final tickets = <SupportTicket>[];

    for (final ctx in clients) {
      final tier = ctx.client.tier;
      final (min, max) = ctx.churnDate != null
          ? (2, 4)
          : tierTicketCount[tier]!;
      final count = _between(min, max);
      final latest = ctx.churnDate ?? now;
      final earliest = _maxDate(
        ctx.client.onboarded,
        latest.subtract(const Duration(days: 365)),
      );
      final slaHours = tierResponseSla[tier]!;

      for (var i = 0; i < count; i++) {
        final template = _pick(ticketTemplates);
        // keep the inbox busy: a quarter of all tickets is recent
        final from = ctx.churnDate == null && _chance(0.25)
            ? _maxDate(earliest, now.subtract(const Duration(days: 14)))
            : earliest;
        final createdAt = _businessTime(
          from.add(
            Duration(minutes: r.nextInt(latest.difference(from).inMinutes)),
          ),
          anyTime: template.priority == Priority.critical,
        );
        if (createdAt.isAfter(now)) {
          continue;
        }

        final priority = _chance(0.2)
            ? Priority.values[math.max(
                0,
                math.min(
                  Priority.values.length - 1,
                  template.priority.index + _pick([-1, 1]),
                ),
              )]
            : template.priority;

        final contact = template.labels.contains('billing')
            ? ctx.financialContact ?? _pick<Contact>(ctx.contacts)
            : _pick(
                ctx.contacts
                    .where((c) => c.type != ContactType.financial)
                    .toList(),
              );

        final projectCandidates = ctx.projects
            .where(
              (p) =>
                  p.isBooking &&
                  !p.start.isAfter(createdAt) &&
                  !(p.end ?? today)
                      .add(const Duration(days: 60))
                      .isBefore(createdAt),
            )
            .toList();
        final project = projectCandidates.isNotEmpty && _chance(0.7)
            ? _pick(projectCandidates)
            : null;

        final ageDays = now.difference(createdAt).inDays;
        final status = _weighted(switch (ageDays) {
          > 21 => {
            TicketStatus.closed: 75,
            TicketStatus.resolved: 22,
            TicketStatus.waitingForCustomer: 3,
          },
          >= 3 => {
            TicketStatus.closed: 35,
            TicketStatus.resolved: 35,
            TicketStatus.waitingForCustomer: 10,
            TicketStatus.inProgress: 15,
            TicketStatus.open: 5,
          },
          _ => {
            TicketStatus.open: 35,
            TicketStatus.inProgress: 35,
            TicketStatus.waitingForCustomer: 15,
            TicketStatus.resolved: 15,
          },
        });

        final unassigned = status == TicketStatus.open && _chance(0.5);
        final assignee = unassigned
            ? null
            : project != null && _chance(0.25)
            ? _pick(project.team)
            : _pick(supportStaff);

        final (minResponse, maxResponse) = switch (priority) {
          Priority.critical => (5, 45),
          Priority.high => (15, 300),
          Priority.normal => (30, 720),
          Priority.low => (60, 1800),
        };
        final firstResponseAt = unassigned
            ? null
            : _minDate(
                createdAt.add(
                  Duration(minutes: _between(minResponse, maxResponse)),
                ),
                now,
              );
        final responseTime = (firstResponseAt ?? now).difference(createdAt);
        final slaBreached = responseTime.inMinutes > slaHours * 60;

        final isDone =
            status == TicketStatus.resolved || status == TicketStatus.closed;
        final (minFix, maxFix) = switch (priority) {
          Priority.critical => (20, 240),
          Priority.high => (120, 2880),
          Priority.normal => (240, 7200),
          Priority.low => (1440, 20160),
        };
        final resolvedAt = isDone
            ? _minDate(
                firstResponseAt!.add(
                  Duration(minutes: _between(minFix, maxFix)),
                ),
                now.subtract(const Duration(minutes: 5)),
              )
            : null;

        tickets.add(
          SupportTicket(
            ticketNumber: '',
            subject: template.subject,
            body:
                '${template.body}\n\n'
                'Best regards\n${contact.firstName} ${contact.lastName}\n'
                '${ctx.client.name}',
            clientId: ctx.client.id,
            contactId: contact.id,
            projectId: project?.project.id,
            assigneeId: assignee != null ? employees[assignee].id : null,
            status: status,
            priority: priority,
            channel: priority == Priority.critical && _chance(0.7)
                ? TicketChannel.phone
                : _weighted(ticketChannelWeights),
            createdAt: createdAt,
            firstResponseAt: firstResponseAt,
            resolvedAt: resolvedAt,
            resolution: isDone ? template.resolution : null,
            labels: [
              ...template.labels,
              if (slaBreached && priority.index >= Priority.high.index)
                'escalated',
            ],
            slaBreached: slaBreached,
            satisfaction: status == TicketStatus.closed && _chance(0.7)
                ? _weighted(
                    slaBreached
                        ? {1: 2, 2: 3, 3: 3, 4: 2, 5: 1}
                        : {2: 1, 3: 2, 4: 5, 5: 7},
                  )
                : null,
          ),
        );
      }
    }

    tickets.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (final (i, ticket) in tickets.indexed) {
      await repo.create(ticket.copyWith(ticketNumber: '#${14211 + i}'));
    }
  }

  // --- helpers -------------------------------------------------------------

  T _pick<T>(List<T> list) => list[r.nextInt(list.length)];

  List<T> _sample<T>(List<T> list, int count) =>
      ([...list]..shuffle(r)).take(count).toList();

  int _between(int min, int max) => min + r.nextInt(max - min + 1);

  bool _chance(double probability) => r.nextDouble() < probability;

  T _weighted<T>(Map<T, int> weights) {
    var value = r.nextInt(weights.values.fold(0, (a, b) => a + b));
    for (final MapEntry(:key, value: weight) in weights.entries) {
      if (value < weight) {
        return key;
      }
      value -= weight;
    }
    throw StateError('unreachable');
  }

  String _digits(int count) => List.generate(
    count,
    (i) => i == 0 ? 1 + r.nextInt(9) : r.nextInt(10),
  ).join();

  String _alphanumeric(int count) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    return List.generate(count, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String _phone(String country, String areaCode) =>
      '+${countryPhonePrefix[country]} $areaCode ${_digits(_between(5, 7))}';

  String _mobile(String country) =>
      '+${countryPhonePrefix[country]} '
      '${_pick(countryMobilePrefixes[country]!)} ${_digits(7)}';

  String? _vatId(String country, Industry industry) {
    if (industry == Industry.publicSector) {
      return null;
    }
    return switch (country) {
      'DE' => 'DE${_digits(9)}',
      'AT' => 'ATU${_digits(8)}',
      'CH' => 'CHE${_digits(9)}',
      'SE' => 'SE${_digits(10)}01',
      'NL' => 'NL${_digits(9)}B01',
      'IT' => 'IT${_digits(11)}',
      'FI' => 'FI${_digits(8)}',
      _ => '$country${_digits(9)}',
    };
  }

  double _roundPrice(double price, PriceUnitType unit, String currency) {
    final step = switch (unit) {
      PriceUnitType.hour => 5,
      _ => 10,
    };
    return _roundTo(price, currency == 'SEK' ? step * 10 : step);
  }

  DateTime _businessTime(DateTime day, {bool anyTime = false}) {
    final date = DateTime.utc(day.year, day.month, day.day);
    final weekend = day.weekday > DateTime.friday;
    if (anyTime || (weekend && _chance(0.2))) {
      return date.add(Duration(minutes: r.nextInt(24 * 60)));
    }
    final workday = weekend ? _nextWorkday(date) : date;
    return workday.add(Duration(minutes: _between(6 * 60 + 30, 17 * 60)));
  }

  DateTime _nextWorkday(DateTime date) {
    var d = DateTime.utc(date.year, date.month, date.day);
    while (d.weekday > DateTime.friday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  DateTime _nextWeekday(DateTime date, int weekday) =>
      date.add(Duration(days: (weekday - date.weekday) % 7));
}

String _monthLabel(DateTime month) =>
    '${_monthNames[month.month - 1]} ${month.year}';

DateTime _parseDate(String date) => DateTime.parse('${date}T00:00:00Z');

DateTime _maxDate(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

DateTime _minDate(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

double _round2(double value) => (value * 100).round() / 100;

double _roundTo(double value, num step) =>
    ((value / step).round() * step).toDouble();

String _slug(String value, {bool nordic = false}) {
  final replacements = {
    'ä': nordic ? 'a' : 'ae',
    'ö': nordic ? 'o' : 'oe',
    'ü': 'ue',
    'ß': 'ss',
    'å': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'É': 'e',
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ó': 'o',
    'ô': 'o',
    'í': 'i',
    'ú': 'u',
    'ç': 'c',
    'ñ': 'n',
    'ı': 'i',
    'ş': 's',
    'ğ': 'g',
    'ć': 'c',
    'č': 'c',
    'š': 's',
    'ž': 'z',
    'ł': 'l',
  };
  return value
      .toLowerCase()
      .split('')
      .map((c) => replacements[c] ?? c)
      .join()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '.')
      .replaceAll(RegExp(r'^\.+|\.+$'), '');
}
