import 'package:datahub_aperture/api.dart';
import 'package:datahub_aperture/services.dart';

import 'aperture_data_action.dart';
import 'aperture_data_repository_adapter.dart';
import 'aperture_data_resource.dart';

class ApertureConfigDataDelegate implements ApertureConfigDelegate {
  @override
  final String title;

  @override
  final ApertureTheme theme;

  @override
  late final List<ApertureResource> resources;

  @override
  late final List<ApertureAction> actions;

  @override
  final String baseUrl;

  ApertureConfigDataDelegate({
    this.title = 'Aperture',
    this.theme = const ApertureTheme(),
    List<ApertureDataResource> dataResources = const [],
    List<ApertureDataAction> dataActions = const [],
    required this.baseUrl,
  }) {
    final allBeans = dataResources.map((e) => e.bean);

    resources = [
      for (final res in dataResources)
        ApertureResource(
          description: res.buildDescription(allBeans),
          repository: ApertureDataRepositoryAdapter(repository: res.repository),
          actions: [
            for (final action in res.actions)
              ApertureAction(
                description: action.buildDescription(allBeans),
                handler: action.handle,
              ),
          ],
        ),
    ];

    actions = [
      for (final action in dataActions)
        ApertureAction(
          description: action.buildDescription(allBeans),
          handler: action.handle,
        ),
    ];
  }
}
