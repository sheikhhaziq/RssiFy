import 'package:fluent_ui/fluent_ui.dart';
import 'package:rssify/main.dart';
import 'package:rssify/models/feed.dart';
import 'package:rssify/models/folder.dart';

class AddItem extends StatefulWidget {
  final List<Folder> rootFolders;
  const AddItem({super.key, required this.rootFolders});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  String folderName = '';
  String feedTitle = '';
  String feedUrl = '';
  Folder? selectedFolder;
  int tabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add Folder or RSS Feed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select what you want to add:'),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: TabView(
              currentIndex: tabIndex,
              onChanged: (i) => setState(() => tabIndex = i),
              tabs: [
                Tab(
                  text: Text('Folder'),
                  body: TextBox(
                    placeholder: 'Folder Name',
                    onChanged: (val) => folderName = val,
                  ),
                ),
                Tab(
                  text: Text('RSS Feed'),
                  body: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      TextBox(
                        placeholder: 'RSS Title',
                        onChanged: (val) => feedTitle = val,
                      ),
                      const SizedBox(height: 8),
                      TextBox(
                        placeholder: 'RSS URL',
                        onChanged: (val) => feedUrl = val,
                      ),
                      const SizedBox(height: 8),
                      ComboBox<Folder>(
                        placeholder: Text('Add to Folder'),
                        items: widget.rootFolders
                            .map(
                              (f) =>
                                  ComboBoxItem(value: f, child: Text(f.name)),
                            )
                            .toList(),
                        value: selectedFolder,
                        onChanged: (f) => setState(() => selectedFolder = f),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('Add'),
          onPressed: () async {
            if (tabIndex == 0 && folderName.trim().isNotEmpty) {
              final folder = Folder()..name = folderName.trim();
              await isar.writeTxn(() => isar.folders.put(folder));
            } else if (tabIndex == 1 &&
                feedTitle.trim().isNotEmpty &&
                feedUrl.trim().isNotEmpty &&
                selectedFolder != null) {
              final feed = Feed()
                ..title = feedTitle.trim()
                ..url = feedUrl.trim();

              await isar.writeTxn(() async {
                final id = await isar.feeds.put(feed); // Assign ID
                final savedFeed = await isar.feeds.get(
                  id,
                ); // Fetch back with ID

                if (savedFeed != null) {
                  selectedFolder!.feeds.add(savedFeed); // Link with ID
                  await selectedFolder!.feeds.save(); // Save the link
                }
              });
            }
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
