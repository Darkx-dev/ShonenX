import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shonenx/app_initializer.dart';
import 'package:shonenx/core/utils/app_logger.dart';
import 'package:shonenx/features/settings/view_model/theme_notifier.dart';
import 'package:shonenx/shared/providers/router_provider.dart';

void main(List<String> args) async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  try {
    AppLogger.i('Starting app initialization');
    await AppInitializer.initialize();
  } catch (e) {
    AppLogger.e('Error initializing app: $e');
    runApp(const MaterialApp(
      home: Scaffold(body: Center(child: Text('Initialization failed'))),
    ));
    return;
  }

  if (runWebViewTitleBarWidget(args)) return;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemStatusBarContrastEnforced: false
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeSettingsProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: FlexThemeData.light(
        swapColors: theme.swapColors,
        blendLevel: theme.blendLevel,
        scheme: theme.flexSchemeEnum,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      darkTheme: FlexThemeData.dark(
        swapColors: theme.swapColors,
        blendLevel: theme.blendLevel,
        scheme: theme.flexSchemeEnum,
        darkIsTrueBlack: theme.amoled,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      themeMode: theme.themeMode == 'light'
          ? ThemeMode.light
          : theme.themeMode == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system,
      routerConfig: router,
    );
  }
}
