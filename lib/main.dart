import 'dart:developer';
import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shonenx/data/hive/boxes/settings_box.dart';
import 'package:shonenx/data/hive/models/continue_watching_model.dart';
import 'package:shonenx/data/hive/models/settings_offline_model.dart';
import 'package:shonenx/router/router.dart';
import 'package:window_manager/window_manager.dart';

bool windowManagerInitialized = false;

class AppInitializer {
  static Future<void> initialize() async {
    log("🚀 Main() Called");

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      log("⚠️ Running in test mode, exiting main.");
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();
    log("✅ Flutter bindings initialized.");

    await _initializeMediaKit();
    await _initializeHive();
    await _initializeWindowManager();
  }

  static Future<void> _initializeMediaKit() async {
    MediaKit.ensureInitialized();
    log("✅ MediaKit initialized.");
  }

  static Future<void> _initializeHive() async {
    String customPath;

    if (Platform.isWindows) {
      // Custom folder inside the user's Documents directory (or any path you prefer)
      customPath = '${Directory.current.path}\\hive_data'; // Or any other path
    } else {
      // Default for other platforms
      customPath = (await getApplicationDocumentsDirectory()).path;
    }

    Hive.init(customPath);
    log("✅ Hive initialized at: $customPath");

    // Register your adapters as usual
    Hive.registerAdapter(SettingsModelAdapter());
    Hive.registerAdapter(ProviderSettingsModelAdapter());
    Hive.registerAdapter(AppearanceSettingsModelAdapter());
    Hive.registerAdapter(PlayerSettingsModelAdapter());
    Hive.registerAdapter(ContinueWatchingEntryAdapter());

    log("✅ Hive adapters registered.");
  }

  static Future<void> _initializeWindowManager() async {
    if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
      try {
        if (!windowManagerInitialized) {
          await windowManager.ensureInitialized();
          windowManagerInitialized = true;

          WindowOptions windowOptions = WindowOptions(
            center: true,
            backgroundColor: Colors.black,
            skipTaskbar: false,
            title: "ShonenX Beta",
          );

          await windowManager.waitUntilReadyToShow(windowOptions, () async {
            await windowManager.show();
            await windowManager.focus();
          });

          log("✅ Window Manager Initialized");
        }
      } catch (e) {
        log("❌ Window Manager Initialization Error: $e");
      }
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      log("✅ System UI Mode set to edge-to-edge.");
    }
  }
}

void main(List<String> args) async {
  await AppInitializer.initialize();
  log("🏃 Running App");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isBoxInitialized = false;
  late SettingsBox? _settingsBox;
  @override
  void initState() {
    super.initState();
    _initializeSettingsBox();
  }

  Future<void> _initializeSettingsBox() async {
    _settingsBox = SettingsBox();
    await _settingsBox?.init();
    setState(() {
      _isBoxInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBoxInitialized) {
      return SizedBox.shrink();
    }
    return ValueListenableBuilder<Box>(
        valueListenable: _settingsBox!.settingsBoxListenable,
        builder: (context, box, child) {
          final appearanceSettings = _settingsBox?.getAppearanceSettings() ??
              AppearanceSettingsModel();
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: FlexThemeData.light(
              scheme: appearanceSettings.flexSchemeEnum,
              appBarStyle: FlexAppBarStyle.primary,
              appBarElevation: 4.0,
              appBarOpacity: appearanceSettings.appBarOpacity,
              transparentStatusBar: appearanceSettings.transparentStatusBar,
              blendLevel: appearanceSettings.blendLevel,
              useMaterial3: appearanceSettings.useMaterial3,
              bottomAppBarElevation: 8.0,
              swapColors: appearanceSettings.swapLightColors,
              tabBarStyle: appearanceSettings.flexTabBarStyleEnum,
              textTheme: GoogleFonts.montserratTextTheme(),
              subThemesData: appearanceSettings.useSubThemes
                  ? FlexSubThemesData(
                      defaultRadius: appearanceSettings.defaultRadius,
                    )
                  : null,
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
            ),
            darkTheme: FlexThemeData.dark(
              scheme: appearanceSettings.flexSchemeEnum,
              appBarStyle: FlexAppBarStyle.material,
              appBarElevation: 4.0,
              appBarOpacity: appearanceSettings.appBarOpacity,
              transparentStatusBar: appearanceSettings.transparentStatusBar,
              darkIsTrueBlack: appearanceSettings.amoled,
              blendLevel: appearanceSettings.blendLevel,
              useMaterial3: appearanceSettings.useMaterial3,
              bottomAppBarElevation: 8.0,
              swapColors: appearanceSettings.swapDarkColors,
              tabBarStyle: appearanceSettings.flexTabBarStyleEnum,
              textTheme: GoogleFonts.montserratTextTheme(),
              subThemesData: appearanceSettings.useSubThemes
                  ? FlexSubThemesData(
                      defaultRadius: appearanceSettings.defaultRadius,
                    )
                  : null,
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
            ),
            themeMode: appearanceSettings.themeMode == 'light'
                ? ThemeMode.light
                : appearanceSettings.themeMode == 'dark'
                    ? ThemeMode.dark
                    : ThemeMode.system,
            routerConfig: router,
          );
        });
  }
}
