import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/bookmark/bookmark_db.dart';

class FaviconIcon extends StatelessWidget{
  final String websiteUrl;
  final double size;

  const FaviconIcon({
    super.key,
    required this.websiteUrl,
    this.size = 24.0
  });

  String? get faviconUrl {
    final url = websiteUrl.trim();
    if (url.isEmpty) return null;

    final formattedUrl = url.startsWith('//')
        ? 'https:$url'
        : url.contains('://') ? url : 'https://$url';
    final uri = Uri.tryParse(formattedUrl);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty) {
      return null;
    }

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/favicon.ico',
    ).toString();
  }

  @override
  Widget build(BuildContext context) {
    final url = faviconUrl;
    if (url == null) return Icon(Icons.public, size: size);
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Fallback icon if the image fails to load or there is no internet
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.public, size: size);
      },
    );
  }
}

class Bookmark extends Entry with DateMixin{
  String? name;
  String? url;

  Bookmark({
    super.id,
    int? dateUnix,
    this.name,
    this.url,
  }){
    dateInUnix = dateUnix;
  }
}

class BookmarkModel extends BaseModel<Bookmark>{
  BookmarkModel():super(BookmarkDbWorker()){
    worker.createTable().then((_) => loadData());
  }
}