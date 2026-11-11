import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

enum Screen{
  List,
  Entry;
}

abstract class Entry{
  static const int noId = -1;

  int id;

  Entry({this.id = noId});

  bool get isNew => id == noId;
}

mixin DateDBProvider on EntryDBWorker{
  
}

abstract interface class EntryDBWorker<T extends Entry>{
  Future<void> createTable();
  Future<int> create(T entry);
  Future<void> update(T entry);
  Future<T?> get(int id);
  Future<List<T>> getAll();
  Future<void> delete(T entry);

}

abstract class SqfliteWorker<T extends Entry> implements EntryDBWorker<T>{
  static const _dbName = 'flutterbook_db.db';
  static Database? _db;

  String get tableName;
  String get sqlTable;
  String get showSqlTable;

  Map<String, dynamic> toMap(T entry);
  T fromMap(Map<String, dynamic> map);

  String get dbName => _dbName;

  Future<Database> get database async{
    if(_db != null) return _db!;

    await _initDatabase();
    return _db!;
  }

  Future<void> _initDatabase() async{
    if(_db != null) return;

    final dbPath = path.join(await getDatabasesPath(), _dbName);
    final database = await openDatabase(
      dbPath,
      version: 1,  
    );

    _db = database;
  }
}

abstract class BaseModel<T extends Entry> extends ChangeNotifier{
  final EntryDBWorker<T> worker;
  final List<T> entryList = [];

  Screen _screen = .List;

  T? entryBeingEdited;

  BaseModel(this.worker);

  int get screen => _screen.index;
  int get entriesLength => entryList.length;

  Future<void> loadData() async{
    entryList
      ..clear()
      ..addAll(await worker.getAll());
    notifyListeners();
  }

  void setEntry(T entry){
    entryBeingEdited = entry;
    _screen = .Entry;
    loadData();
  }

  Future<int?> stopEntry({required bool save, bool notify = true}) async{
    int? id;
    if(save){
      final item = entryBeingEdited!;
      if(item.isNew){
        id = await worker.create(item);
      }else{
        await worker.update(item);
        id = item.id;
      }
      await loadData();
    }

    _screen = .List;
    entryBeingEdited = null;
    if(notify) notifyListeners();

    return id;
  }
}
