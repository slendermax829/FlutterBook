import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:provider/provider.dart';

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NoteModel>();
    return Scaffold(
      body: model.entryList.isEmpty 
              ? const Center(child: Text('No Notes Available'),)
              : ListView.builder(
                itemCount: model.entriesLength,
                itemBuilder:(context, index) {
                  final note = model.entryList[index];
                  return Card(
                    color: note.color?.withValues(alpha: .3),
                    child: ListTile(
                      leading: Icon(Icons.note_rounded),
                      title: Text(note.title ?? ''),
                      subtitle: Text(note.description ?? ''),
                      onTap:() => debugPrint('Reviewing note ${note.title}'),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new note',
        onPressed: () => model.setEntry(Note()),
        child: Icon(Icons.add)
      ),
    );
  }
}