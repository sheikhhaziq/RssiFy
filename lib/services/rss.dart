import 'package:dio/dio.dart';
import 'package:rss_dart/domain/atom_feed.dart';
import 'package:rss_dart/domain/atom_item.dart';
import 'package:rss_dart/domain/rss1_feed.dart';
import 'package:rss_dart/domain/rss_feed.dart';
import 'package:rss_dart/domain/rss_item.dart';
import 'package:rssify/models/article.dart';

Future<List<Article>> fetchArticlesFromFeed(String feedUrl) async {
  final dio = Dio();
  final response = await dio.get(feedUrl);
  final xml = response.data.toString();

  final List<Article> articles = [];

  try {
    final feed = RssFeed.parse(xml);
    print("RssFeed");
    for (var item in feed.items) {
      articles.add(
        Article(
          title: item.title ?? "No title",
          url: item.link ?? "",
          source: item.dc?.creator ?? 'Unknown',
          thumbnails: _extractThumbnails(item),
        ),
      );
    }
  } catch (_) {
    try {
      final feed = AtomFeed.parse(xml);

      for (var entry in feed.items) {
        articles.add(
          Article(
            title: entry.title ?? "No title",
            url: entry.links.firstOrNull?.href ?? "",
            source:
                entry.source?.title ?? entry.authors.first.name ?? 'Unknown',
            thumbnails: _extractThumbnailsFromAtom(entry),
          ),
        );
      }
    } catch (_) {
      try {
        final feed = Rss1Feed.parse(xml);
        print("Rss1Feed");

        for (var item in feed.items) {
          articles.add(
            Article(
              title: item.title ?? "No title",
              url: item.link ?? "",
              source: item.dc?.publisher ?? 'Unknown',
              thumbnails:
                  item.content?.images
                      .map((e) => Thumbnail(url: e, width: 0))
                      .toList() ??
                  [], // RSS 1.0 usually lacks media
            ),
          );
        }
      } catch (e) {
        print("Unsupported or invalid feed: $e");
      }
    }
  }

  return articles;
}

List<Thumbnail> _extractThumbnails(RssItem item) {
  final List<Thumbnail> thumbnails = [];

  // Enclosure-based image (common for RSS 2.0)
  if (item.enclosure?.type?.startsWith("image/") == true) {
    thumbnails.add(Thumbnail(url: item.enclosure!.url ?? "", width: 0));
  }

  // Media RSS namespace support
  for (final media in item.media?.thumbnails ?? []) {
    if (media.url != null) {
      thumbnails.add(Thumbnail(url: media.url!, width: media.width ?? 0));
    }
  }
  if (thumbnails.isEmpty) {
    if (item.media != null) {
      final thumbs = item.media!.contents
          .where((e) => e.medium == 'image' && e.url != null)
          .toList();
      for (final thumbnail in thumbs) {
        thumbnails.add(Thumbnail(url: thumbnail.url!, width: thumbnail.width));
      }
    }
  }

  return thumbnails;
}

List<Thumbnail> _extractThumbnailsFromAtom(AtomItem item) {
  final List<Thumbnail> thumbnails = [];

  for (final link in item.links) {
    if (link.rel == "enclosure" && link.type?.startsWith("image/") == true) {
      thumbnails.add(Thumbnail(url: link.href ?? "", width: 0));
    }
  }
  if (thumbnails.isEmpty) {
    if (item.media != null && item.media!.thumbnails.isNotEmpty) {
      for (final thumbnail in item.media!.thumbnails) {
        if (thumbnail.url != null && thumbnail.width != null) {
          thumbnails.add(
            Thumbnail(url: thumbnail.url!, width: int.parse(thumbnail.width!)),
          );
        }
      }
    }
  }
  if (thumbnails.isEmpty) {
    if (item.media?.group != null && item.media!.group!.thumbnails.isNotEmpty) {
      for (final thumbnail in item.media!.group!.thumbnails) {
        if (thumbnail.url != null && thumbnail.width != null) {
          thumbnails.add(
            Thumbnail(url: thumbnail.url!, width: int.parse(thumbnail.width!)),
          );
        }
      }
    }
  }
  if (thumbnails.isEmpty) {
    if (item.media != null) {
      final thumbs = item.media!.contents
          .where((e) => e.medium == 'image' && e.url != null)
          .toList();
      for (final thumbnail in thumbs) {
        thumbnails.add(Thumbnail(url: thumbnail.url!, width: thumbnail.width));
      }
    }
  }

  return thumbnails;
}

extension FirstOrNull<E> on List<E> {
  E? get firstOrNull => isNotEmpty ? this[0] : null;
}
