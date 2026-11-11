import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/task_model.dart';
import 'package:provider/provider.dart';

class TaskViewer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TaskModel>();
    return IndexedStack(
      index: model.screen,
      children: [
        Center(child: Text('Task_List'),),
        Center(child: Text('Task_Entry'))
      ],
    );
  }
}