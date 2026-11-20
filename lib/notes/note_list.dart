import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoteList extends StatelessWidget {
  NoteList({super.key});

  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  void _viewContent(String noteContent){
    final BuildContext? context = _navKey.currentContext;

    if(context != null && context.mounted){
      showDialog<void>(
        context: context, 
        builder:(context) {
          return AlertDialog(
            icon: Icon(Icons.content_copy),
            iconColor: Colors.white,
            title: Text('Note\'s Content'),
            content: Text(noteContent),
          );
        },
      );
    }
  }

  void _deleteNote(Note note){
    final BuildContext? context = _navKey.currentContext;
    
    if(context != null && context.mounted){
      try{
        context.read<NoteModel>().deleteEntry(note);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted Note')
          )
        );

      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error Deleting Note: $e')
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NoteModel>();
    return Scaffold(
      key: _navKey,
      body: model.entryList.isEmpty 
              ? const Center(child: Text('No Notes Available'),)
              : ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: model.entriesLength,
                itemBuilder:(context, index) {
                  final note = model.entryList[index];
                  return _buildSlidable(note);
                },
              ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new note',
        onPressed: () => model.setEntry(Note()),
        child: Icon(Icons.add)
      ),
    );
  }

  Widget _buildSlidable(Note note){
    final date = DateFormat.yMMMd().format(note.date ?? DateTime(2099,1,1));

    return Slidable(
      key: ValueKey(note.id),

      startActionPane: ActionPane(
        motion: DrawerMotion(), 
        children: [
          SlidableAction(
            onPressed:(context) {
              context.read<NoteModel>().setEntry(note);
            },
            label: 'Edit',
            icon: Icons.edit,
            backgroundColor: Colors.lightGreenAccent.shade400.withValues(alpha: .3),
            foregroundColor: Colors.white,
          )
        ]
      ),

      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed:() {
            _deleteNote(note);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context){},
            label: 'Delete',
            icon: Icons.delete,
            backgroundColor: Colors.redAccent.withValues(alpha: .3),
            foregroundColor: Colors.white,
          )
        ]
      ),

      child: Card(
        color: note.color?.withValues(alpha: .3),
        child: ListTile(
          leading: Icon(Icons.sticky_note_2),
          title: Text(note.title ?? 'Unknown Title'),
          subtitle: Text(note.description ?? 'Unknown'),
          trailing: Text(date),
          onTap:() => _viewContent(note.content ?? '')
        ),
      ),
    );
  }
}