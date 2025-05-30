import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rssify/models/feed.dart';
import 'package:rssify/models/folder.dart';
import 'package:rssify/screens/main_screen.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemTheme.fallbackColor = const Color(0xFF865432);
  await SystemTheme.accentColor.load();
  await Window.hideWindowControls();
  await WindowManager.instance.ensureInitialized();

  windowManager
      .waitUntilReadyToShow(
        WindowOptions(
          center: true,
          title: "RssiFy",
          backgroundColor: Colors.transparent,
          titleBarStyle: TitleBarStyle.hidden,
          windowButtonVisibility: false,
          skipTaskbar: false,
        ),
      )
      .then((_) async {
        await Window.setEffect(effect: WindowEffect.mica, dark: true);

        await windowManager.setPreventClose(false);
        windowManager.show();

        windowManager.focus();
      });
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open([FolderSchema, FeedSchema], directory: dir.path);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder: (context, accent) {
        return FluentApp(
          debugShowCheckedModeBanner: false,
          theme: FluentThemeData(
            brightness: Brightness.light,
            accentColor: accent.accent.toAccentColor(),
            scaffoldBackgroundColor: Colors.transparent,
          ),
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: accent.accent.toAccentColor(),
            scaffoldBackgroundColor: Colors.transparent,
          ),
          color: accent.accent,
          home: MainScreen(),
        );
      },
    );
  }
}
