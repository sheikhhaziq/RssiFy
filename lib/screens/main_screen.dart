import 'package:fluent_ui/fluent_ui.dart';
import 'package:isar/isar.dart';
import 'package:rssify/main.dart';
import 'package:rssify/models/folder.dart';
import 'package:rssify/screens/feed_screen.dart';
import 'package:rssify/widgets/add_item.dart';
import 'package:window_manager/window_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Folder> rootFolders = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await isar.folders.where().findAll();
    for (var folder in folders) {
      await folder.feeds.load();
    }

    setState(() {
      rootFolders = folders;
      _selectedIndex = 0;
    });
  }

  void _showAddDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AddItem(rootFolders: rootFolders);
      },
    );
    await _loadFolders();
  }

  List<NavigationPaneItem> _buildFolderItems(List<Folder> folders) {
    List<NavigationPaneItem> items = [];

    for (var folder in folders) {
      List<PaneItem> subItems = [];

      for (var feed in folder.feeds) {
        final feedItem = PaneItem(
          icon: const Icon(FluentIcons.content_feed),
          title: Text(feed.title),
          body: FeedScreen(feed: feed),
        );
        subItems.add(feedItem);
      }

      items.add(
        PaneItemExpander(
          icon: const Icon(FluentIcons.folder),
          title: Text(folder.name),
          items: subItems,
          body: const SizedBox.shrink(),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final hasFolders = rootFolders.isNotEmpty;

    return NavigationView(
      appBar: NavigationAppBar(
        title: DragToMoveArea(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: const Text("RssiFy"),
          ),
        ),
        actions: const WindowButtons(),
      ),
      pane: hasFolders
          ? NavigationPane(
              displayMode: PaneDisplayMode.auto,
              selected: _selectedIndex,
              onChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: _buildFolderItems(rootFolders),

              footerItems: [
                PaneItem(
                  icon: const Icon(FluentIcons.add),
                  title: const Text('Add'),
                  body: const SizedBox.shrink(),
                  onTap: _showAddDialog,
                ),
                PaneItem(
                  icon: const Icon(FluentIcons.settings),
                  title: const Text("Settings"),
                  body: const Center(child: Text("Settings")),
                ),
              ],
            )
          : null,

      content: hasFolders
          ? null
          : Center(
              child: FilledButton(
                onPressed: _showAddDialog,
                child: const Text("Create a Folder"),
              ),
            ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
