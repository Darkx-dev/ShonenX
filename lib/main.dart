import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shonenx/app_initializer.dart';
import 'package:shonenx/providers/hive_service_provider.dart';
import 'package:shonenx/theme/app_theme.dart';
import 'package:shonenx/router/router.dart';
import 'package:shonenx/widgets/ui/shonenx_search_bar.dart';
import 'package:window_manager/window_manager.dart';

class ToggleFullscreenIntent extends Intent {
  const ToggleFullscreenIntent();
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppInitializer.initialize();
  } catch (e) {
    // Log error or show error screen
    runApp(const MaterialApp(
      home: Scaffold(body: Center(child: Text('Initialization failed'))),
    ));
    return;
  }

  if (runWebViewTitleBarWidget(args)) return;
  // runApp(MaterialApp(
  //   home: SearchBarExample(),
  // ));
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isFullscreen = false;

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (!Platform.isAndroid && !Platform.isIOS) {
      windowManager.setFullScreen(_isFullscreen);
    }
    // Optionally adjust system UI for mobile
    if (!_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiveServiceAsync = ref.watch(hiveServiceProvider);

    return hiveServiceAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $err'))),
      ),
      data: (hiveService) {
        final settingsBox = hiveService.settings;
        return Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.f11): ToggleFullscreenIntent(),
          },
          child: Actions(
            actions: {
              ToggleFullscreenIntent: CallbackAction<ToggleFullscreenIntent>(
                onInvoke: (intent) => _toggleFullscreen(),
              ),
            },
            child: Focus(
              autofocus: true,
              child: ValueListenableBuilder<Box>(
                valueListenable: settingsBox.settingsBoxListenable,
                builder: (context, box, _) {
                  try {
                    final appearance = settingsBox.getThemeSettings();
                    return MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.light(appearance),
                      darkTheme: AppTheme.dark(appearance),
                      themeMode: appearance.themeMode == 'light'
                          ? ThemeMode.light
                          : appearance.themeMode == 'dark'
                              ? ThemeMode.dark
                              : ThemeMode.system,
                      routerConfig: router,
                    );
                  } catch (e) {
                    return MaterialApp(
                      home: Scaffold(
                          body: Center(child: Text('Settings error: $e'))),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
