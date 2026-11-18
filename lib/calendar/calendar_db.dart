import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/calendar/calendar_model.dart';

class CalendarDbWorker extends SqfliteWorker<CalendarReminder> {
  @override
  Future<int> create(CalendarReminder entry) async{
    final db = await database;
    return await db.insert(
      tableName, 
      toMap(entry)
    );
  }

  @override
  Future<void> createTable() async {
    final db = await database;
    await db.execute(sqlTable);
  }

  @override
  Future<void> delete(CalendarReminder entry) async {
    final db = await database;
      await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [entry.id]
      );
  }

  static DateTime? _fromMillis(Object? millis) =>
    millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis as int);

  @override
  CalendarReminder fromMap(Map<String, dynamic> map) {
    return CalendarReminder(
      id: map['id'] as int,
      title: map['title'] as String?,
      notes: map['notes'] as String?,
      color: map['color'] == null ? null : Color(map['color'] as int),
      startTime: _fromMillis(map['startTime']),
      endDate: _fromMillis(map['endDate']),
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      reminderDate: _fromMillis(map['reminder_date']),
    );
  }

  @override
  Future<CalendarReminder?> get(int id) async{
    final db = await database;
    final rows = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id]
    );
    return rows.isEmpty ? null : fromMap(rows.first);
  }

  @override
  Future<List<CalendarReminder>> getAll() async{
    final db = await database;
    final rows = await db.query(
      tableName,
      orderBy: 'reminder_date, startTime'
    );
    return rows.map(fromMap).toList();
  }

  @override
  String get showSqlTable => "SELECT name FROM sqlite_master WHERE type='table' AND name=?";

  @override
  String get sqlTable => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      notes TEXT,
      color INTEGER,
      reminder_date INTEGER NOT NULL,
      startTime INTEGER,
      endDate INTEGER,
      isCompleted INTEGER NOT NULL DEFAULT 0
    )''';

  @override
  String get tableName => 'calendar_reminder';

  @override
  Map<String, dynamic> toMap(CalendarReminder entry) {
    final day = DateUtils.dateOnly(entry.date ?? DateTime.now());
    return <String, dynamic>{
      if (!entry.isNew) 'id' : entry.id,
      'title' : entry.title,
      'notes' : entry.notes,
      'color' : entry.colorInt,
      'reminder_date': day.millisecondsSinceEpoch,
      'startTime': entry.startTime?.millisecondsSinceEpoch,
      'endDate' : entry.endDate?.millisecondsSinceEpoch,
      'isCompleted' : entry.isCompleted ? 1 : 0
    };
  }

  @override
  Future<void> update(CalendarReminder entry) async{
    final db = await database;
    await db.update(
      tableName,
      toMap(entry),
      where: 'id = ?',
      whereArgs: [entry.id]
    );
  }
}