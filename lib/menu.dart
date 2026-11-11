import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note.dart';
import 'package:flutter_book/tasks/tasks.dart';

class Menu extends StatelessWidget {
  const new({super.key});

  static const List<Tab> _tabs = [
    Tab(icon: Icon(Icons.notes), child: Text('Notes'),),
    Tab(icon: Icon(Icons.calendar_month), child: Text('Calendar')),
    Tab(icon: Icon(Icons.task_rounded), child: Text('Tasks'),),
    Tab(icon: Icon(Icons.contact_mail), child: Text('Contacts'),)
  ];

  static const List<Widget> _views = [
    NoteView(),
    Center(child: Text('Calendar'),),
    TaskViewer(),
    Center(child: Text('Contacts'),),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length, 
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('FlutterBook'),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () => _displayBottomSheet(context), 
              icon: const Icon(Icons.menu)
            )
          ],
          bottom: const TabBar(
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
            tabs: _tabs
            ),
        ),
        body: const TabBarView(
          children: _views
        ),
      )
    );
  }
}

void _displayBottomSheet(BuildContext context){
  final confirm = showModalBottomSheet<bool>(
    context: context, 
    builder:(context){
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
            leading: Icon(Icons.clear),
            title: Text('Clear all Data'),
            onTap: () {
              debugPrint('Clearing Data');
              Navigator.pop(context, false);
            },
          )
          ],
        ),
      );
    },
  );
}