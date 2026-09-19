import 'package:datahub_aperture_frontend/utils/theme.dart';
import 'package:flutter/material.dart';

class UserEntityView extends StatelessWidget {
  final String id;
  final String name;

  const UserEntityView({super.key, required this.id, required this.name});

  String get _initials => name
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .take(2)
      .map((e) => e.characters.first.toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final colors = ApertureColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.accentSubtle,
            foregroundColor: colors.link,
            child: Text(
              _initials,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colors.link,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.labelLarge),
              Text(id, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
