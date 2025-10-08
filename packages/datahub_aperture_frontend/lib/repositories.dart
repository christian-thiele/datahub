import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
