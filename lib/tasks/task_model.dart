import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/tasks/task_db.dart';

class Task{
  int id;
  String? name;
  String? description;
  bool isComplete;

  Task({
    this.id = Entry.noId,
    this.name,
    this.description,
    this.isComplete = false
  });
}

class TaskList extends Entry with DateMixin{
  String? title;
  String? description;
  List<Task> tasks;

  TaskList({
    super.id,
    this.title,
    this.description,
    List<Task>? tasks,
    int? dateUnix
  }) : tasks = tasks ?? [] {
    dateInUnix = dateUnix;
  }
}

class TaskModel extends BaseModel<TaskList>{
  TaskModel():super(TaskDBWorker()..createTable());

  List<Task> get entryTasks => entryBeingEdited?.tasks ?? <Task>[];

  /// Updates the list being edited; new (unsaved) lists are only changed in memory.
  Future<void> updateListDetails({
    required String title,
    required String description,
  }) async{
    final list = entryBeingEdited;
    if(list == null) return;
    list.title = title;
    list.description = description;
    notifyListeners();
    if(!list.isNew) await worker.update(list);
  }

  Future<void> toggleTask(Task task) async{
    final list = entryBeingEdited;
    if(list == null) return;
    task.isComplete = !task.isComplete;
    notifyListeners();
    await worker.update(list);
  }
}
