import 'package:flutter/material.dart';

import 'icon_text.dart';

class SidePanelTab {
  final String label;
  final IconData icon;
  final Widget child;

  const SidePanelTab({
    required this.label,
    required this.icon,
    required this.child,
  });
}

/// Several views sharing a side panel, switched with tabs.
class SidePanelTabs extends StatelessWidget {
  final List<SidePanelTab> tabs;

  const SidePanelTabs({super.key, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          TabBar(
            tabs: [
              for (final tab in tabs)
                Tab(height: 40, child: IconText(tab.icon, tab.label)),
            ],
          ),
          Expanded(
            child: TabBarView(children: [for (final tab in tabs) tab.child]),
          ),
        ],
      ),
    );
  }
}
