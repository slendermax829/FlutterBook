import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/notes/notes_db.dart';

class Note extends Entry with DateMixin{
  String? title;
  String? description;
  Color? color;
  String? content;


  Note({
    this.title,
    this.description,
    this.color,
    this.content,
    int? dateUnix,
    super.id,
  }){
    dateInUnix = dateUnix;
  }

  int get colorInt{
    if(color == null){
      return Colors.red.toARGB32();
    }else{
      return color!.toARGB32();
    }
  }

}

class NoteModel extends BaseModel<Note>{
  NoteModel():super(NotesDbWorker()){
    worker.createTable().then((_) => loadData());
  }
}