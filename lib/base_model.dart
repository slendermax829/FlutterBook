import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

/// Screens used by entry-based sections of the app.
enum Screen{
  /// Displays the collection of entries.
  List,

  /// Displays the entry editor.
  Entry;
}

/// An object whose identifier distinguishes new and stored entries.
/// 
/// Must be extended with another object to be utilized
abstract class Entry{
  /// Identifier used before an entry is persisted.
  static const int noId = -1;

  /// The entry's database identifier, or [noId] for a new entry.
  int id;

  /// Creates an entry, defaulting to the unsaved identifier.
  Entry({this.id = noId});

  /// Whether this entry still has the unsaved identifier.
  bool get isNew => id == noId;
}

@Deprecated('Don\'t use this mixin, Firebase logic is not implemented yet')
mixin FireBaseUploader{
  UploadTask? uploadTask;

  Future<String> uploadFile(String localPath, {String folder = 'uploads'}) async{
    final file = File(localPath);

    debugPrint('Path of File: ${file.path}');

    if(!await file.exists()){
      throw Exception('Local file not found: $localPath');
    }

    final name = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(localPath)}';

    final ref = FirebaseStorage.instance
      .ref()
      .child(folder)
      .child(name);

    debugPrint('Bucket: ${ref.bucket}');
    debugPrint('Full path: ${ref.fullPath}');
    debugPrint('File size: ${await file.length()} bytes');
    debugPrint('Uploading to bucket ${ref.bucket}, path ${ref.fullPath}');

    try {
      // Start upload
      uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: lookupMimeType(localPath) ?? 'application/octet-stream',
        ),
      );

      // Wait for upload to finish
      final snapshot = await uploadTask!;

      debugPrint('Upload state: ${snapshot.state}');
      debugPrint('Uploaded bytes: ${snapshot.bytesTransferred}');
      debugPrint('Reference: ${snapshot.ref.fullPath}');

      if (snapshot.state != TaskState.success) {
        throw Exception(
          'Upload did not complete: ${snapshot.state}',
        );
      }

      debugPrint('Upload succeeded.');

      // Get URL separately
      try {
        final url = await snapshot.ref.getDownloadURL();

        debugPrint('Download URL: $url');

        return url;
      } on FirebaseException catch (e) {
        debugPrint(
          'getDownloadURL failed: ${e.code} - ${e.message}',
        );
        rethrow;
      }
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase upload failed: ${e.code} - ${e.message}',
      );
      rethrow;
    }
  }
}

@Deprecated('Don\'t use this mixin, File logic is not implemented yet')
mixin FileUploader{
  PlatformFile? _selectedFile;

  /// The selected file's name, or null if no file is selected.
  String? get selectedFileName => _selectedFile?.name;

  /// The selected file's local path, when available.
  String? get selectedFilePath => _selectedFile?.path;

  /// File extensions recognized as video.
  static const videoExtensions = ['mp4', 'avi', 'mov', 'mkv'];
  /// File extensions recognized as audio.
  static const audioExtensions = ['mp3', 'wav', 'm4a', 'aac'];

  /// The selected file's media type, or null for an unrecognized extension.
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

  /// Clears the selected file.
  void resetFile() => _selectedFile = null;
}

/// Adds an optional date and conversions used by entry models when declared.
mixin DateMixin{
  /// The stored date, if one has been selected.
  DateTime? date;

  /// Whether a date is present.
  bool get hasDate => date != null;

  /// The date as milliseconds since the Unix epoch, or null.
  int? get dateInUnix => date?.millisecondsSinceEpoch;

  /// Sets the date from milliseconds since the Unix epoch; null clears it.
  set dateInUnix(int? millis){
    date = millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// The date formatted with the current locale, or null.
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

/// Persistence operations required by an entry model.
/// 
/// Follows CRUD operations
abstract interface class EntryDBWorker<T extends Entry>{
  /// Creates the storage needed by this worker.
  Future<void> createTable();
  /// Persists an entry and returns its generated identifier.
  Future<int> create(T entry);
  /// Persists changes to an entry.
  Future<void> update(T entry);
  /// Returns an entry by identifier, or null if it is absent.
  Future<T?> get(int id);
  /// Returns all entries.
  Future<List<T>> getAll();
  /// Deletes an entry.
  Future<void> delete(T entry);

}

/// Base for SQLite-backed entry workers sharing the app's database.
abstract class SqfliteWorker<T extends Entry> implements EntryDBWorker<T>{
  static Database? _db;
  static const _dbName = 'flutterbook_db.db';

  /// Name of the worker's primary table.
  String get tableName;
  /// SQL used to create the worker's primary table.
  String get sqlTable;
  /// SQL intended to inspect whether a table exists.
  String get showSqlTable;

  /// Converts an entry to values suitable for a database row.
  Map<String, dynamic> toMap(T entry);
  /// Constructs an entry from a database row.
  T fromMap(Map<String, dynamic> map);

  /// Name of the shared database file.
  String get dbName => _dbName;

  /// Opens the shared database on first access and returns it.
  Future<Database> get database async{
    if(_db != null) return _db!;

    await _initDatabase();
    return _db!;
  }
  /// boots up the database if [_db] is `null`
  Future<void> _initDatabase() async{
    if(_db != null) return;

    final dbPath = path.join(await getDatabasesPath(), _dbName);
    final database = await openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async{
        await db.execute('PRAGMA foreign_keys = ON'); // allow database to access tables with foreign keys
      },
    );
    
    _db = database;
  }
}

/// Holds entry list and editing state backed by an [EntryDBWorker].
abstract class BaseModel<T extends Entry> extends ChangeNotifier{
  /// Persistence implementation used for all entries.
  final EntryDBWorker<T> worker;
  /// Entries currently loaded in memory.
  final List<T> entryList = [];

  Screen _screen = .List;

  /// The entry currently being edited, if any.
  T? entryBeingEdited;

  /// Creates a model using [worker] for persistence.
  BaseModel(this.worker);

  /// Index of the active [Screen], suitable for an indexed stack.
  int get screen => _screen.index;
  /// Number of entries currently loaded.
  int get entriesLength => entryList.length;

  /// Reloads the entries from storage and notifies listeners.
  Future<void> loadData() async{
    entryList
      ..clear()
      ..addAll(await worker.getAll());
    notifyListeners();
  }

  /// Opens a [entry] menu in the program by changing [Screen] and starts a refresh of the entry list.
  /// 
  /// Entering a new [entry] with no attributes will be classified as a new entry to the database
  void setEntry(T entry){
    entryBeingEdited = entry;
    _screen = .Entry;
    notifyListeners();
    loadData();
  }

  /// Closes the editor, optionally saving its entry and notifying listeners.
  ///
  /// Returns the saved entry's identifier, or null when saving was skipped.
  /// 
  /// [notify] lets the model know to switch back to [Screen.List] or not
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

  /// Removes [entry] from the visible list, deletes it, and reloads the list.
  ///
  /// Storage failures propagate to the caller.
  Future<void> deleteEntry(T entry) async{
  
    entryList.removeWhere((e) => e.id == entry.id);
    notifyListeners(); // for dismissible sliceable panels, since it can cause the program to crash
    await worker.delete(entry);
    await loadData();
  }
}
