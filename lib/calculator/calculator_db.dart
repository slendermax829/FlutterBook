import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/calculator/calulator_model.dart';

class CalculatorDbWorker extends SqfliteWorker<SavedCalculator> {
  @override
  Future<int> create(SavedCalculator entry) async {
    final db = await database;
    return await db.insert(tableName, toMap(entry));
  }

  @override
  Future<void> createTable() async {
    final db = await database;
    await db.execute(sqlTable);
    await db.execute(refsqlTable);
  }

  @override
  Future<void> delete(SavedCalculator entry) async {
    final db = await database;
    await db.delete(tableName, where: 'cal_id = ?', whereArgs: [entry.id]);
  }

  @override
  SavedCalculator fromMap(Map<String, dynamic> map) {
    return SavedCalculator(
      id: map['cal_id'] as int,
      name: map['name'] as String?,
      dateUnix: map['date'] as int?,
    );
  }

  @override
  Future<SavedCalculator?> get(int id) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'cal_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return fromMap(result.first);
  }

  @override
  Future<List<SavedCalculator>> getAll() async {
    final db = await database;
    final rows = await db.query(tableName);

    return rows.map(fromMap).toList();
  }

  @override
  String get showSqlTable => "SELECT name FROM sqlite_master WHERE type='table' AND name=?";

  @override
  String get tableName => 'saved_calculators';

  @override
  String get sqlTable => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      cal_id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date INTEGER
    )''';

  String get refTableName => 'calculation_history';

  String get refsqlTable => '''
  CREATE TABLE IF NOT EXISTS $refTableName (
    calculation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    cal_id INTEGER NOT NULL,
    expression TEXT,
    result TEXT,
    operation_type TEXT,
    FOREIGN KEY (cal_id) REFERENCES $tableName (cal_id)
      ON DELETE CASCADE
  )''';

  @override
  Map<String, dynamic> toMap(SavedCalculator entry) {
    return {
      if (!entry.isNew) 'cal_id': entry.id,
      'name': entry.name,
      'date': entry.dateInUnix,
    };
  }

  @override
  Future<void> update(SavedCalculator entry) async {
    final db = await database;
    final data = toMap(entry)..remove('cal_id');

    await db.update(
      tableName,
      data,
      where: 'cal_id = ?',
      whereArgs: [entry.id],
    );
  }
}
