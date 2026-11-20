import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:sqflite/sqflite.dart';

class NotesDbWorker extends SqfliteWorker<Note>{

  @override
  Future<void> createTable() async {
    final db = await database;
    await db.execute(sqlTable);

    // Tables created by an older schema lack newer columns; add them in place.
    final columns = await db.rawQuery('PRAGMA table_info($tableName)');
    final names = columns.map((c) => c['name']).toSet();
    if (!names.contains('description')) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN description TEXT');
    }

    // Older inserts stored the "new" sentinel id (-1); give that row a real id.
    await db.execute(
      'UPDATE $tableName SET id = (SELECT IFNULL(MAX(id), 0) + 1 FROM $tableName) '
      'WHERE id = ${Entry.noId}',
    );
    if(!names.contains('date')){
      await db.execute('ALTER TABLE $tableName ADD COLUMN date INTEGER');
    }
  }

  @override
  Future<int> create(Note entry) async{
    final db = await database;
    return await db.insert(
      tableName, 
      toMap(entry)
    );
  }

  @override
  Future<void> delete(Note entry) async{
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [entry.id]
    );
  }

  @override
  Note fromMap(Map<String, dynamic> map){
    return Note(
      id: map['id'],
      dateUnix: map['date'],
      title: map['title'],
      description: map['description'],
      color: Color(map['color']),
      content: map['content']
    );
  }

  @override
  Future<Note?> get(int id) async{
    final db = await database;
    final rows = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id]
    );
    return rows.isEmpty ? null : fromMap(rows.first);
  }

  @override
  Future<List<Note>> getAll() async{
    final db = await database;
    final rows = await db.query(
      tableName,
    );
    return rows.map(fromMap).toList();
  }

  @override
  String get sqlTable => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      color INTEGER,
      content TEXT,
      date INTEGER
    )''';

  @override
  String get tableName => 'notes';

  @override
  Map<String, dynamic> toMap(Note note) {
    return <String, dynamic>{
      if (!note.isNew) 'id': note.id,
      'title': note.title,
      'description': note.description,
      'color': note.colorInt,
      'content': note.content,
      'date' : note.dateInUnix
    };
  }

  @override
  String get showSqlTable => 'SHOW TABLES LIKE name=?';

  @override
  Future<void> update(Note entry) async{
    final db = await database;
    await db.update(
      tableName,
      toMap(entry),
      where: 'id = ?',
      whereArgs: [entry.id]
    );
  }
  
}