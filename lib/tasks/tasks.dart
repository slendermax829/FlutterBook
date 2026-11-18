import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/task_list.dart';
import 'package:flutter_book/tasks/task_model.dart';
import 'package:flutter_book/tasks/task_viewer.dart';
import 'package:provider/provider.dart';

class TaskViewer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TaskModel>();
    return IndexedStack(
      index: model.screen,
      children: [
        TaskListViewer(),
        TaskEntryViewer(key: ObjectKey(model.entryBeingEdited)),
      ],
    );
  }
}