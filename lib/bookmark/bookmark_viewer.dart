import 'package:flutter/material.dart';
import 'package:flutter_book/bookmark/bookmark_model.dart';
import 'package:provider/provider.dart';

class BookmarkViewer extends StatelessWidget {
  BookmarkViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BookmarkModel>();
    return Scaffold(
      appBar: AppBar(
        shape: BoxBorder.all(color: Colors.white),
        title: const Text('Your Bookmarks'),
        centerTitle: false,
        actionsPadding: EdgeInsets.symmetric(horizontal: 25),
        actions: [
          Text('Total bookmarks: ${model.entriesLength}')
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a new bookmark',
        onPressed: () => model.setEntry(Bookmark()),
        child: Icon(Icons.add),
      ),
      body: model.entryList.isEmpty
            ? const Center(child: Text('No bookmarks available'),)
            : ListView.builder(
              itemCount: model.entriesLength,
              itemBuilder:(context, index) {
                final bookmark = model.entryList[index];
                return _createPanel(bookmark);
              },
            )
    );
  }

  Widget _createPanel(Bookmark bookmark){
    return ListTile(
      title: Text(bookmark.name ?? 'Unnamed bookmark'),
      subtitle: bookmark.url == null ? null : Text(bookmark.url!),
    );
  }
}