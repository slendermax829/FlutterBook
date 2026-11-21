import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/bookmark/bookmark_model.dart';

/// SQLite worker for bookmarks.
/// 
/// See [SqfliteWorker] for inner functionality
class BookmarkDbWorker extends SqfliteWorker<Bookmark>{
  @override
  Future<int> create(Bookmark entry) async{
    final db = await database;
    return await db.insert(
      tableName,
      toMap(entry)
    );
  }

  @override
  Future<void> createTable() async{
    final db = await database;
    await db.execute(sqlTable);
  }

  @override
  Future<void> delete(Bookmark entry) async{
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [entry.id]
    );
  }

  @override
  Bookmark fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'],
      dateUnix: map['date'],
      name: map['name'],
      url: map['url'],
    );
  }

  @override
  Future<Bookmark?> get(int id) async{
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
    );

    if (result.isEmpty) return null;

    return fromMap(result.first);
  }

  @override
  Future<List<Bookmark>> getAll() async{
    final db = await database;
    final rows = await db.query(
      tableName
    );

    return rows.map(fromMap).toList();
  }

  @override
  String get showSqlTable => "SELECT name FROM sqlite_master WHERE type='table' AND name=?";

  @override
  // TODO: implement sqlTable
  String get sqlTable => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      url TEXT,
      date INTEGER
    )''';

  @override
  // TODO: implement tableName
  String get tableName => 'bookmarks';

  @override
  Map<String, dynamic> toMap(Bookmark entry) {
    return <String, dynamic>{
      if(!entry.isNew) 'id' : entry.id,
      'name' : entry.name,
      'url' : entry.url,
      'date' : entry.dateInUnix
    };
  }

  @override
  Future<void> update(Bookmark entry) async{
    final db = await database;
    await db.update(
      tableName, 
      toMap(entry)
    );
  }
}