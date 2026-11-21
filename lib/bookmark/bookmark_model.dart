import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/bookmark/bookmark_db.dart';

/// A saved website with an name, URL, and date.
class Bookmark extends Entry with DateMixin{
  String? name;
  String? url;

  Bookmark({
    super.id,
    int? dateUnix,
    this.name,
    this.url,
  }){
    dateInUnix = dateUnix;
  }
}

/// Loads and manages bookmarks table stored in SQLite.
class BookmarkModel extends BaseModel<Bookmark>{
  BookmarkModel():super(BookmarkDbWorker()){
    worker.createTable().then((_) => loadData());
  }
}