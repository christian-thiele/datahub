import 'package:datahub_aperture_frontend/modules/task_manager/repositories/api_task_manager_repository.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/repositories/task_manager_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/api_repository.dart';
import 'repositories/resources_repository/api_resources_repository.dart';
import 'repositories/resources_repository/resources_repository.dart';
import 'utils/bootstrap.dart';

class Repositories extends StatelessWidget {
  final Widget child;

  const Repositories({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ResourcesRepository>(
          create: (context) =>
              ApiResourcesRepository(baseUrl: Bootstrap.of(context).baseUrl),
          dispose: (repo) => (repo as ApiRepository).close(),
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
