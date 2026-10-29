import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

import '../_utils/test_auth_service.dart';
import 'point_of_interest.dart';

/// A realistic backoffice for "ACME Digital", a fictional software
/// agency: clients, contacts, projects, timesheets, invoices, support tickets.
///
/// Invoices move through a workflow (see [_invoiceSteps]), which Aperture
/// shows on the invoices.
void main(List<String> args) => runApp([
  const KeyService(),
  MemoryRepositoryService(bean: $PointOfInterest.bean),
  const TestAuthService(),
  ApiService(
    routes: [
      CorsMiddleware(
        routes: [
          ApertureApi(
            title: const Config.value('Simple Resources'),
            oidcIssuer: const Config.value('http://localhost:8081/realms/local-oidc'),
            oidcClientId: const Config.value('aperture'),
            resources: [
              ApertureResource(
                repository: const Find<DataRepository<PointOfInterest>>(),
                defaultSortField: $PointOfInterest.$type,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
], arguments: args);
