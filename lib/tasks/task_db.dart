import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/tasks/task_model.dart';
import 'package:sqflite/sqflite.dart';

class TaskDBWorker extends SqfliteWorker<TaskList>{
  @override
  Future<void> createTable() async {
    final db = await database;
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute(sqlTable);
    await db.execute(taskRefTable);
  }

  @override
  Future<int> create(TaskList entry) async {
    final db = await database;
    return db.transaction((txn) async {
      final listId = await txn.insert(tableName, toMap(entry));
      await _insertTasks(txn, listId, entry.tasks);
      return listId;
    });
  }

  @override
  Future<void> update(TaskList entry) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        tableName,
        toMap(entry),
        where: 'list_id = ?',
        whereArgs: [entry.id]
      );
      await txn.delete(taskRefName, where: 'list_id = ?', whereArgs: [entry.id]);
      await _insertTasks(txn, entry.id, entry.tasks);
    });
  }

  @override
  Future<void> delete(TaskList entry) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(taskRefName, where: 'list_id = ?', whereArgs: [entry.id]);
      await txn.delete(tableName, where: 'list_id = ?', whereArgs: [entry.id]);
    });
  }

  @override
  Future<TaskList?> get(int id) async {
    final db = await database;
    final rows = await db.query(
      tableName,
      where: 'list_id = ?',
      whereArgs: [id]
    );
    if (rows.isEmpty) return null;
    final list = fromMap(rows.first);
    list.tasks = await _tasksFor(db, id);
    return list;
  }

  @override
  Future<List<TaskList>> getAll() async {
    final db = await database;
    final rows = await db.query(tableName);
    final lists = rows.map(fromMap).toList();
    for (final list in lists) {
      list.tasks = await _tasksFor(db, list.id);
    }
    return lists;
  }

  @override
  TaskList fromMap(Map<String, dynamic> map) {
    return TaskList(
      id: map['list_id'] as int,
      title: map['title'] as String?,
      description: map['description'] as String?,
    );
  }

  @override
  Map<String, dynamic> toMap(TaskList entry) {
    return <String, dynamic>{
      if (!entry.isNew) 'list_id': entry.id,
      'title': entry.title,
      'description': entry.description,
    };
  }

  Task _taskFromMap(Map<String, dynamic> map) {
    return Task(
      id: map['task_id'] as int,
      name: map['task_name'] as String?,
      description: map['task_description'] as String?,
      isComplete: (map['is_completed'] as int) == 1,
    );
  }

  Future<List<Task>> _tasksFor(DatabaseExecutor db, int listId) async {
    final rows = await db.query(
      taskRefName,
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'task_id'
    );
    return rows.map(_taskFromMap).toList();
  }

  Future<void> _insertTasks(
    DatabaseExecutor db, int listId, List<Task> tasks
  ) async {
    for (final task in tasks) {
      await db.insert(taskRefName, {
        'list_id': listId,
        'task_name': task.name,
        'task_description': task.description,
        'is_completed': task.isComplete ? 1 : 0,
      });
    }
  }

  @override
  String get tableName => 'task_list';

  @override
  String get showSqlTable => "SELECT name FROM sqlite_master WHERE type='table' AND name=?";

  @override
  String get sqlTable => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      list_id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT
    )''';

  String get taskRefName => 'task';

  String get taskRefTable => '''
    CREATE TABLE IF NOT EXISTS $taskRefName (
      task_id INTEGER PRIMARY KEY AUTOINCREMENT,
      list_id INTEGER NOT NULL,
      task_name TEXT,
      task_description TEXT,
      is_completed INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (list_id)
        REFERENCES $tableName (list_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
    )''';
}
