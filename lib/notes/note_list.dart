import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:provider/provider.dart';

extension FilePlayer on NoteModel{
  void playAudioFile(){

  }

  void playVideoFile(){

  }
}
class NoteList extends StatelessWidget {
  const NoteList({super.key});

  static const Map<String, Icon> _noteIcons = {
    'content' : Icon(Icons.description),
    'audio' : Icon(Icons.audio_file),
    'video' : Icon(Icons.video_camera_back)
  };

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
                      leading: _noteIcons[note.type.name.toLowerCase()],
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