import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:rssify/models/feed.dart';
import 'package:rssify/services/rss.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedScreen extends StatefulWidget {
  final Feed feed;
  const FeedScreen({super.key, required this.feed});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ScaffoldPage(
      content: FutureBuilder(
        future: fetchArticlesFromFeed(widget.feed.url),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            final articles = snapshot.data!;
            return GridView.builder(
              itemCount: articles.length,
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisExtent: 270,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final article = articles[index];
                return GestureDetector(
                  onTap: () async {
                    await launchUrl(Uri.parse(article.url));
                  },
                  child: Card(
                    padding: EdgeInsetsGeometry.zero,

                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),

                          child: CachedNetworkImage(
                            imageUrl:
                                article.thumbnails.firstOrNull?.url ??
                                'https://placehold.co/300x150',
                            width: 300,
                            height: 150,
                            memCacheWidth: (300 * dpr).round(),
                            memCacheHeight: (150 * dpr).round(),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            article.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(article.source),
                              DropDownButton(
                                title: Text("More"),
                                items: [
                                  MenuFlyoutItem(
                                    leading: Icon(FluentIcons.edge_logo),

                                    text: Text("Open in Browser"),
                                    onPressed: () async {
                                      await launchUrl(Uri.parse(article.url));
                                    },
                                  ),
                                  MenuFlyoutItem(
                                    leading: Icon(FluentIcons.share),

                                    text: Text("Share"),
                                    onPressed: () async {
                                      await SharePlus.instance.share(
                                        ShareParams(
                                          uri: Uri.parse(article.url),
                                        ),
                                      );
                                    },
                                  ),
                                  MenuFlyoutItem(
                                    leading: Icon(FluentIcons.copy),
                                    text: Text("Copy to clipboard"),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: article.url),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: ProgressRing());
        },
      ),
    );
  }
}

showSnackbar(String text) {}
