import 'package:flutter/material.dart';
import 'package:flutter_book/bookmark/bookmark_model.dart';
import 'package:flutter_book/bookmark/bookmark_viewer.dart';
import 'package:provider/provider.dart';

class Bookmarks extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BookmarkModel>();
    return IndexedStack(
      index: model.screen,
      children: [
        BookmarkViewer(),
        Placeholder()
      ],
    );
  }
}