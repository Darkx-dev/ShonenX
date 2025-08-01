import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shonenx/core/models/anilist/anilist_media_list.dart';
import 'package:shonenx/features/anime/view/watch_screen.dart';
import 'package:shonenx/features/browse/view/browse_screen.dart';
import 'package:shonenx/features/details/view/details_screen.dart';
import 'package:shonenx/features/error/view/error_screen.dart';
import 'package:shonenx/features/settings/view/about_screen.dart';
import 'package:shonenx/features/settings/view/account_settings_screen.dart';
import 'package:shonenx/features/settings/view/anime_sources_settings_screen.dart';
import 'package:shonenx/features/settings/view/player_settings_screen.dart';
import 'package:shonenx/features/settings/view/settings_screen.dart';
import 'package:shonenx/features/settings/view/subtitle_customization_screen.dart';
import 'package:shonenx/features/settings/view/theme_settings_screen.dart';
import 'package:shonenx/features/settings/view/ui_settings_screen.dart';
import 'package:shonenx/router/router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return _router;
});

final _router = GoRouter(
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppRouterScreen(navigationShell: navigationShell),
      branches: navItems.asMap().entries.map((entry) {
        final item = entry.value;
        return StatefulShellBranch(
          routes: [
            GoRoute(
              path: item.path,
              builder: (context, state) {
                if (item.path == '/browse') {
                  return BrowseScreen(
                    key: ValueKey(state.uri.toString()),
                    keyword: state.uri.queryParameters['keyword'],
                  );
                }
                return item.screen;
              },
            ),
          ],
        );
      }).toList(),
    ),

    // Standalone routes
    _buildSettingsRoute(),
    GoRoute(
      path: '/details',
      builder: (context, state) => AnimeDetailsScreen(
        anime: state.extra as Media,
        tag: state.uri.queryParameters['tag'] ?? '',
      ),
    ),
    GoRoute(
      path: '/watch/:id',
      builder: (context, state) => WatchScreen(
        animeId: state.pathParameters['id']!,
        episode: int.tryParse(state.uri.queryParameters['episode'] ?? '1') ?? 1,
        animeMedia: state.extra as Media,
        startAt: Duration(
          seconds:
              int.tryParse(state.uri.queryParameters['startAt'] ?? '0') ?? 0,
        ),
        animeName: state.uri.queryParameters['animeName']!,
      ),
    ),
  ],
);

GoRoute _buildSettingsRoute() {
  return GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
    routes: [
      GoRoute(
        path: 'account',
        builder: (context, state) => const AccountSettingsScreen(),
        routes: [],
      ),
      GoRoute(
        path: 'anime-sources',
        builder: (context, state) => const AnimeSourcesSettingsScreen(),
      ),
      GoRoute(
        path: 'theme',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: 'ui',
        builder: (context, state) => const UiSettingsScreen(),
      ),
      GoRoute(
        path: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
          path: 'player',
          builder: (context, state) => const PlayerSettingsScreen(),
          routes: [
            GoRoute(
              path: 'subtitles',
              builder: (context, state) => const SubtitleCustomizationScreen(),
            ),
          ])
    ],
  );
}
