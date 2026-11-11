import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/tasks/task_db.dart';

class Task extends Entry{
  String? name;
  String? description;
  bool isComplete;

  Task({
    super.id,
    this.name,
    this.description,
    this.isComplete = false
  });
}

class TaskList extends Entry{
  String? title;
  String? description;
  List<Task> tasks;

  TaskList({
    super.id,
    this.title,
    this.description,
    List<Task>? tasks
  }) : tasks = tasks ?? [];
}

class TaskModel extends BaseModel<TaskList>{
  TaskModel():super(TaskDBWorker()..createTable());
}
