import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
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

mixin FileUploader{
  PlatformFile? _selectedFile;

  String? get selectedFileName => _selectedFile?.name;

  static const videoExtensions = ['mp4', 'avi', 'mov', 'mkv'];
  static const audioExtensions = ['mp3', 'wav', 'm4a', 'aac'];

  FileType? get selectedFileType {
    final extension = _selectedFile?.extension?.toLowerCase();
    if (extension == null) return null;
    if (videoExtensions.contains(extension)) return FileType.video;
    if (audioExtensions.contains(extension)) return FileType.audio;
    return null;
  }

  // allowedExtensions is only honored with FileType.custom.
  Future<bool> _pick(String label, List<String> extensions) async{
    final PlatformFile? file = await FilePicker.pickFile(
      dialogTitle: 'Select $label file',
      type: FileType.custom,
      allowedExtensions: extensions,
    );
    if(file == null){
      debugPrint('No $label file selected');
      return false;
    }
    debugPrint('$label file selected: ${file.name}');
    _selectedFile = file;
    return true;
  }

  /// Returns true if a file was picked, false if the user cancelled.
  Future<bool> pickVideoFile() => _pick('video', videoExtensions);

  /// Returns true if a file was picked, false if the user cancelled.
  Future<bool> pickAudioFile() => _pick('audio', audioExtensions);

  void resetFile() => _selectedFile = null;
}

mixin DateMixin{
  DateTime? date;

  bool get hasDate => date != null;

  int? get dateInUnix => date?.millisecondsSinceEpoch;

  set dateInUnix(int? millis){
    date = millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  String? get formattedDate => date == null ? null : DateFormat.yMMMd().format(date!);

  /// Shows a date picker, stores the result in [date] and returns it.
  /// Returns null (and leaves [date] untouched) if the user cancels.
  Future<DateTime?> pickDate(BuildContext context) async{
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if(picked != null) date = picked;
    return picked;
  }
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
