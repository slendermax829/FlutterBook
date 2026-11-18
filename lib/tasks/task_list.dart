import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_book/tasks/task_model.dart';
import 'package:provider/provider.dart';

class TaskListViewer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TaskModel>();
    return Scaffold(
      body: model.entryList.isEmpty
            ? Center(child: const Text('No tasks listed yet'))
            : ListView.builder(
                itemCount: model.entryList.length,
                itemBuilder: (context, index) {
                  final list = model.entryList[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.checklist),
                      title: Text(list.title ?? ''),
                      subtitle: Text(
                        '${list.tasks.where((t) => t.isComplete).length}/${list.tasks.length} completed',
                      ),
                      onTap: () => model.setEntry(list),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.setEntry(TaskList()),
        tooltip: 'Add new task list',
        child: Icon(Icons.add),
      ),
    );
  }
}