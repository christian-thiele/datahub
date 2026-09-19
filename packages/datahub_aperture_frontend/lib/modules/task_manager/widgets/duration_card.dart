import 'dart:async';

import 'package:datahub_aperture_frontend/utils/utils.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import 'invocation_overview.dart';

class DurationCard extends StatefulWidget {
  final TaskModel task;

  const DurationCard({super.key, required this.task});

  @override
  State<DurationCard> createState() => _DurationCardState();
}

class _DurationCardState extends State<DurationCard> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), _update);
  }

  void _update(Timer t) {
    if (!mounted || widget.task.finishedAt != null) {
      t.cancel();
      return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: Icons.timer_outlined,
      label: 'Duration',
      value: taskDuration(widget.task),
    );
  }

  String taskDuration(TaskModel task) {
    return switch (task) {
      TaskModel(startedAt: null) => '-',
      TaskModel(:final startedAt?, :final finishedAt?) => formatDuration(
        finishedAt.difference(startedAt),
      ),
      TaskModel(:final startedAt?) => formatDuration(
        DateTime.timestamp().difference(startedAt),
      ),
    };
  }
}
