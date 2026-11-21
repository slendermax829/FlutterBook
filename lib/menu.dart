import 'package:flutter/material.dart';
import 'package:flutter_book/bookmark/bookmark.dart';
import 'package:flutter_book/calculator/calculator.dart';
import 'package:flutter_book/calculator/calculator_view.dart';
import 'package:flutter_book/calendar/calendar.dart';
import 'package:flutter_book/calendar/calendar_view.dart';
import 'package:flutter_book/notes/note.dart';

/// The app's tabbed sections and tabbed menus.
class Menu extends StatelessWidget {
  const new({super.key});

  /// The tabs to be present through out the app's lifecycle
  static const List<Tab> _tabs = [
    Tab(icon: Icon(Icons.notes), child: Text('Notes'),),
    Tab(icon: Icon(Icons.calendar_month), child: Text('Calendar')),
    Tab(icon: Icon(Icons.bookmark), child: Text('Bookmarks'),),
    Tab(icon: Icon(Icons.calculate), child: Text('Calculator'),)
  ];

  /// The views that are associated by the indices from [_tabs]
  static const List<Widget> _views = [
    NoteView(),
    Calendar(),
    Bookmarks(),
    Calculator()
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length, 
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('FlutterBook', style: TextStyle(decoration: TextDecoration.underline),),
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
              debugPrint('Clearing Data'); // does not have any functionality
              Navigator.pop(context, false);
            },
          )
          ],
        ),
      );
    },
  );
}