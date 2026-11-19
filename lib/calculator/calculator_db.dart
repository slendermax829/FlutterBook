import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/calculator/calculator_model.dart';

mixin CalHistoryHelper on SqfliteWorker<SavedCalculator> {
  String get refTableName => 'calculation_history';

  String get refsqlTable =>
      '''
  CREATE TABLE IF NOT EXISTS $refTableName (
    calculation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    cal_id INTEGER NOT NULL,
    expression TEXT,
    result TEXT,
    operation_type TEXT,
    FOREIGN KEY (cal_id) REFERENCES $tableName (cal_id)
      ON DELETE CASCADE
  )''';

  Map<String, dynamic> mapHistory(int calculatorId, CalculationHistory entry) {
    return <String, dynamic>{
      'cal_id': calculatorId, // parent id must match with child id
      'expression': entry.expression,
      'result': entry.result,
      'operation_type': entry.operationType,
    };
  }

  Future<int> createHistory(int calculatorId, CalculationHistory entry) async {
    if (calculatorId == Entry.noId) {
      throw ArgumentError.value(
        calculatorId,
        'calculatorId',
        'Must be the same ID of a saved calculator.',
      );
    }

    final db = await database;
    return db.insert(refTableName, mapHistory(calculatorId, entry));
  }

  CalculationHistory getHistory(Map<String, dynamic> map) {
    return CalculationHistory(
      id: map['calculation_id'] as int,
      expression: map['expression'] as String?,
      result: map['result'] as String?,
      operationType: map['operation_type'] as String?,
      calculatorId: map['cal_id'] as int,
    );
  }

  Future<int> deleteHistory(int calculatorId) async{
    if (calculatorId == Entry.noId) {
      throw ArgumentError.value(
        calculatorId,
        'calculatorId',
        'Must be the same ID of a saved calculator.',
      );
    }

    final db = await database;
    return await db.delete(
      refTableName,
      where: 'cal_id = ?',
      whereArgs: [calculatorId]
    );
  }

  Future<List<CalculationHistory>> getCalculationHistory(
    SavedCalculator entry,
  ) async {
    final db = await database;
    final results = await db.query(
      refTableName,
      where: 'cal_id = ?',
      whereArgs: [entry.id],
      orderBy: 'calculation_id DESC',
    );

    return results.map(getHistory).toList();
  }
}

class CalculatorDbWorker extends SqfliteWorker<SavedCalculator>
    with CalHistoryHelper {
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
  String get showSqlTable =>
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?";

  @override
  String get tableName => 'saved_calculators';

  @override
  String get sqlTable =>
      '''
    CREATE TABLE IF NOT EXISTS $tableName (
      cal_id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date INTEGER
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
