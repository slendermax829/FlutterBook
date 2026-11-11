import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:sqflite/sqflite.dart';

class NotesDbWorker extends SqfliteWorker<Note>{

  @override
  Future<void> createTable() async {
    final db = await database;
    await db.execute(sqlTable);
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
  // TODO: implement fromMap
  Note fromMap(Map<String, dynamic> map){
    return Note(
      title: map['title'],
      description: map['description'],
      color: Color(map['color'])
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
      id INTEGER PRIMARY KEY,
      title TEXT,
      description TEXT,
      color INTEGER
    )''';

  @override
  String get tableName => 'notes';

  @override
  Map<String, dynamic> toMap(Note note) {
    return <String, dynamic>{
      'id': note.id,
      'title': note.title,
      'description': note.description,
      'color': note.colorInt
    };
  }

  @override
  String get showSqlTable => 'SHOW TABLES LIKE name=?';

  @override
  Future<void> update(Note entry) async{
    final db = await database;
    db.update(
      tableName,
      toMap(entry),
      where: 'id = ?',
      whereArgs: [entry.id]
    );
  }
}