import 'package:flutter/material.dart';
import 'package:flutter_book/bookmark/bookmark_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BookmarkViewer extends StatelessWidget {
  BookmarkViewer({super.key});

  Future<void> _openWebSite(String? bookUrl) async{
    if(bookUrl == null) return;

    final Uri url = Uri.parse(bookUrl.substring(0, bookUrl.length-1));
    try{
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }catch(e){
      debugPrint('Could not visit site $e');
      return;
    }
  }

  Future<void> _deleteBookmark(Bookmark bookmark, BookmarkModel model, ScaffoldMessengerState messenger) async {
    try {
      await model.deleteEntry(bookmark);
      if (messenger.mounted) {
        messenger.showSnackBar(const SnackBar(content: Text('Deleted Bookmark')));
      }
    } catch (e) {
      debugPrint('Error deleting bookmark: $e');
      try {
        await model.loadData();
      } catch (reloadError) {
        debugPrint('Error reloading bookmarks: $reloadError');
      }
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error deleting bookmark: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BookmarkModel>();
    final messenger = ScaffoldMessenger.of(context);
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
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: model.entriesLength,
              itemBuilder:(context, index) {
                final bookmark = model.entryList[index];
                return _buildPanel(bookmark, model, messenger);
              },
            )
    );
  }

  Widget _buildPanel(
    Bookmark bookmark,
    BookmarkModel model,
    ScaffoldMessengerState messenger,
  ){
    final date = DateFormat.yMMMd().format(bookmark.date ?? DateTime(2099,1,1));
    return Slidable(
      key: ValueKey(bookmark.id),

      startActionPane: ActionPane(
        motion: DrawerMotion(), 
        children: [
          SlidableAction(
            onPressed:(context) {
              context.read<BookmarkModel>().setEntry(bookmark);
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
          onDismissed:() => _deleteBookmark(bookmark, model, messenger),
        ),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteBookmark(bookmark, model, messenger),
            label: 'Delete',
            icon: Icons.delete,
            backgroundColor: Colors.redAccent.withValues(alpha: .3),
            foregroundColor: Colors.white,
          )
        ]
      ),

      child: Card(
        shape: BoxBorder.all(color: Colors.white),
        color: Colors.blue.withValues(alpha: .3),
        child: ListTile(
          leading: Icon(Icons.public),
          title: Text(bookmark.name ?? 'Unknown: 404'),
          subtitle: Text(bookmark.url ?? '404'),
          trailing: Text(date),
          onTap: () => _openWebSite(bookmark.url)
        ),
      )
    );
  }
}