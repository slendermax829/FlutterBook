import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/bookmark/bookmark_db.dart';

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

class BookmarkModel extends BaseModel<Bookmark>{
  BookmarkModel():super(BookmarkDbWorker()){
    worker.createTable().then((_) => loadData());
  }
}