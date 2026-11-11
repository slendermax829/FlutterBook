import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/notes/notes_db.dart';

enum NoteType{
  Content,
  Audio,
  Video;
}

class Note extends Entry{
  String? title;
  String? description;
  Color? color;
  NoteType type;
  String? content;
  String? remoteUrl;
  String? localPath;


  Note({
    this.title,
    this.description,
    this.color,
    this.type = .Content,
    this.content,
    this.remoteUrl,
    this.localPath
  });

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