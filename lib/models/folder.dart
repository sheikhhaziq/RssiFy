import 'package:isar/isar.dart';
import 'package:rssify/models/feed.dart';

part 'folder.g.dart';

@collection
class Folder {
  Id id = Isar.autoIncrement;

  late String name;

  final feeds = IsarLinks<Feed>();
}
