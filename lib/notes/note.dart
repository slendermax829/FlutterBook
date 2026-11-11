import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_entry.dart';
import 'package:flutter_book/notes/note_list.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:provider/provider.dart';

class NoteView extends StatelessWidget {
  const NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NoteModel>();
    return IndexedStack(
        index: model.screen,
        children: [
          NoteList(),
          NoteEntry()
        ],
    );
  }
}