import 'dart:io';
import 'package:cloud/pages/main_page.dart';
import 'package:cloud/pages/desktop_main_page.dart';
import 'package:cloud/pages/tablet_main_page.dart';
import 'package:cloud/providers/csd_themes_provider.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'channels/app_method_channel.dart';
import 'channels/app_web_channel.dart';
import 'models/app_cache.dart';
import 'models/app_settings.dart';
import 'models/app_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'models/file_model.dart';

final mainScreenKey = GlobalKey<MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  await appCacheData.getData();
  await appStorage.initialize();
  appStorage.clearTemporaryFiles();
  await appSettings.getData();
  final filesState = await FilesNotifier.cachedData();
  final csdThemesState = await CsdThemesNotifier.initialized();

  if (Platform.isLinux) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: Size(appCacheData.data["windowWidth"] ?? 1280, appCacheData.data["windowHeight"] ?? 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: appSettings.prefersCustomTitleBar ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }


  runApp(ProviderScope(
      overrides: [
        filesProvider.overrideWithBuild((ref, notifier) => filesState),
        csdThemesProvider.overrideWithBuild((ref, notifier) => csdThemesState)
      ],
      child: MyApp(key: mainScreenKey)));

  if (Platform.isWindows || Platform.isMacOS) {
    doWhenWindowReady(() {
      appWindow.minSize = const Size(550, 300);
      appWindow.size =
          Size(appCacheData.windowWidth, appCacheData.windowHeight);
      appWindow.alignment = Alignment.center;
      appWindow.title = "Cloud";
      appWindow.show();
    });
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
        if (!appWebChannel.connected) {
          appWebChannel.connectWebSocket();
        }
        appStorage.syncDataFromEvents(ref);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    appWebChannel.onWebSocketEvent = (event) {
      appStorage.syncData(event, ref);
    };

      appWebChannel.connectWebSocket();
      appStorage.syncDataFromEvents(ref);

    appWebChannel.getDeviceInfo();
    if(Platform.isAndroid) {
      appMethodChannel.getSystemVersion();
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //ref.read(filesProvider.notifier).init();
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appSettings.appTheme.lightTheme.toThemeData(context),
      darkTheme: appSettings.appTheme.darkTheme.toThemeData(context),
      locale: appSettings.locale,
      localizationsDelegates: const [
        LocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: isDesktop() ? const DesktopMainPage() : isWideScreen(context) ? const TabletMainPage() : MainPage(folder: FileModel(id: "")),
    );
  }
}