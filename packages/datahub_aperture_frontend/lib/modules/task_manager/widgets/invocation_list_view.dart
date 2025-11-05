import 'package:datahub_aperture_frontend/modules/task_manager/models/task_model.dart';
import 'package:datahub_aperture_frontend/modules/task_manager/widgets/invocation_list_item.dart';
import 'package:flutter/material.dart';

class InvocationTimeline extends StatelessWidget {
  final List<TaskModel> tasks;

  const InvocationTimeline({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, idx) =>
          InvocationListItem(task: tasks[idx]),
      separatorBuilder: (context, idx) => Divider(
        height: 16,
        thickness: 0.5,
      ),
      itemCount: tasks.length,
    );
  }
}
