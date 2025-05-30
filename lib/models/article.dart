class Article {
  String title;
  String url;
  List<Thumbnail> thumbnails;
  String source;
  Article({
    required this.title,
    required this.url,
    required this.thumbnails,
    required this.source,
  });
}

class Thumbnail {
  String url;
  int width;
  Thumbnail({required this.url, required this.width});
}
