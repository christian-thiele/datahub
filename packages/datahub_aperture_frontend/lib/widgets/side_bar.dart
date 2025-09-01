import 'package:datahub_aperture_frontend/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideBarEntry {
  final Widget icon;
  final String label;
  final String path;

  SideBarEntry({required this.icon, required this.label, required this.path});
}

class SideBar extends StatelessWidget {
  final List<SideBarEntry> entries;

  final VoidCallback? refreshPressed;

  const SideBar({super.key, required this.entries, this.refreshPressed});

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouter.of(context).state;
    final selected = entries.indexWhere(
      (e) => routerState.matchedLocation == e.path,
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: NavigationRail(
            destinations: [
              for (final entry in entries)
                NavigationRailDestination(
                  icon: entry.icon,
                  label: Text(entry.label),
                ),
            ],
            selectedIndex: (selected > -1) ? selected : null,
            onDestinationSelected: (index) {
              final entry = entries.elementAtOrNull(index);
              if (entry != null) {
                context.go(entry.path);
              }
            },
            extended: true,
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: TextButton.icon(
            onPressed: refreshPressed,
            label: Text(S.of(context).refresh),
            icon: Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }
}
