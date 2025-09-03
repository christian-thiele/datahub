import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/auth_repository/auth_repository.dart';
import 'repositories/auth_repository/mock_auth_repository.dart';
import 'repositories/resources_repository/api_resources_repository.dart';
import 'repositories/resources_repository/resources_repository.dart';
import 'repositories/storage_repository/shared_prefs_storage_repository.dart';
import 'repositories/storage_repository/storage_repository.dart';

class Repositories extends StatelessWidget {
  final Widget child;

  const Repositories({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageRepository>(
          create: (context) => SharedPrefsStorageRepository()..initialize(),
          dispose: (repository) => repository.close(),
          lazy: false,
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => MockAuthRepository()..initialize(),
          lazy: false,
          dispose: (repository) => repository.close(),
        ),
        RepositoryProvider<ResourcesRepository>(
          create: (context) => ApiResourcesRepository()..initialize(),
          lazy: false,
          dispose: (repository) => repository.close(),
        ),
      ],
      child: child,
    );
  }
}
