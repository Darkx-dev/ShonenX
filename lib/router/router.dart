import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shonenx/core/models/anilist/anilist_media_list.dart';
import 'package:shonenx/providers/hive_service_provider.dart';
import 'package:shonenx/screens/browse_screen.dart';
import 'package:shonenx/screens/continue_watching_screen.dart';
import 'package:shonenx/screens/details_screen.dart';
import 'package:shonenx/screens/error_screen.dart';
import 'package:shonenx/screens/home_screen.dart';
import 'package:shonenx/screens/loading_screen.dart';
import 'package:shonenx/screens/see_all_screen.dart';
import 'package:shonenx/screens/settings/about/about_screen.dart';
import 'package:shonenx/screens/settings/about/help_support_screen.dart';
import 'package:shonenx/screens/settings/about/privacy_policy_screen.dart';
import 'package:shonenx/screens/settings/about/terms_screen.dart';
import 'package:shonenx/screens/settings/appearance/theme_screen.dart';
import 'package:shonenx/screens/settings/appearance/ui_screen.dart';
import 'package:shonenx/screens/settings/player/player_screen.dart';
import 'package:shonenx/screens/settings/profile/profile_screen.dart';
import 'package:shonenx/screens/settings/profile/sync_screen.dart';
import 'package:shonenx/screens/settings/settings_screen.dart';
import 'package:shonenx/screens/settings/source/provider_screen.dart';
import 'package:shonenx/screens/watch_screen/watch_screen.dart';
import 'package:shonenx/screens/watchlist_screen.dart';
import 'package:shonenx/widgets/ui/layouts/settings_layout.dart';

// Navigation item configuration
class NavItem {
  final String path;
  final IconData icon;
  final Widget screen;

  NavItem({required this.path, required this.icon, required this.screen});
}

final List<NavItem> navItems = [
  NavItem(path: '/', icon: Iconsax.home, screen: const HomeScreen()),
  NavItem(
      path: '/browse', icon: Iconsax.discover_1, screen: const BrowseScreen()),
  NavItem(
      path: '/watchlist',
      icon: Iconsax.bookmark,
      screen: const WatchlistScreen()),
];

// Router configuration
final GoRouter router = GoRouter(
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      builder: (context, state) => const LoadingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppRouterScreen(navigationShell: navigationShell),
      branches: navItems.asMap().entries.map((entry) {
        // final index = entry.key;
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
    _buildSettingsRoute(),
    GoRoute(
      path: '/all/:path',
      builder: (context, state) => SeeAllScreen(
        title: state.uri.queryParameters['title'] ?? 'Untitled',
        path: state.pathParameters['path'] ?? '',
      ),
    ),
    GoRoute(
      path: '/continue-all',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) {
          final hiveService = ref.watch(hiveServiceProvider).value;
          return ContinueWatchingScreen(
            animeWatchProgressBox: hiveService!.progress,
          );
        },
      ),
    ),
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

// Settings route configuration
GoRoute _buildSettingsRoute() {
  return GoRoute(
    path: '/settings',
    builder: (context, state) => const SettingsScreen(),
    routes: [
      ..._buildSettingsSubRoutes([
        _SettingsRouteConfig(
          path: 'profile',
          title: 'Profile',
          screen: const ProfileSettingsScreen(),
          subRoutes: [
            _SettingsRouteConfig(
              path: 'sync',
              title: 'Sync',
              screen: const SyncSettingsScreen(),
            ),
          ],
        ),
        _SettingsRouteConfig(
          path: 'providers',
          title: 'Providers',
          screen: const ProviderSettingsScreen(),
        ),
        _SettingsRouteConfig(
          path: 'theme',
          title: 'Theme',
          screen: const ThemeSettingsScreen(),
        ),
        _SettingsRouteConfig(
          path: 'ui',
          title: 'User Interface',
          screen: const UISettingsScreen(),
        ),
        _SettingsRouteConfig(
          path: 'about',
          title: 'About',
          screen: const AboutScreen(),
          subRoutes: [
            _SettingsRouteConfig(
              path: 'terms',
              title: 'Terms of Service',
              screen: const TermsOfServiceScreen(),
            ),
            _SettingsRouteConfig(
              path: 'privacy',
              title: 'Privacy Policy',
              screen: const PrivacyPolicyScreen(),
            ),
          ],
        ),
        _SettingsRouteConfig(
          path: 'player',
          title: 'Player',
          screen: const PlayerSettingsScreen(),
        ),
        _SettingsRouteConfig(
          path: 'support',
          title: 'Help & Support',
          screen: const HelpSupportScreen(),
        ),
      ]),
    ],
  );
}

class _SettingsRouteConfig {
  final String path;
  final String title;
  final Widget screen;
  final List<_SettingsRouteConfig> subRoutes;

  _SettingsRouteConfig({
    required this.path,
    required this.title,
    required this.screen,
    this.subRoutes = const [],
  });
}

List<GoRoute> _buildSettingsSubRoutes(List<_SettingsRouteConfig> configs) {
  return configs.map((config) {
    return GoRoute(
      path: config.path,
      builder: (context, state) => SettingsLayout(
        title: config.title,
        child: config.screen,
      ),
      routes: _buildSettingsSubRoutes(config.subRoutes),
    );
  }).toList();
}

// AppRouterScreen
class AppRouterScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppRouterScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showExitConfirmationDialog(context, isSystemExit: true);
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: isWideScreen ? 90 : 0,
                bottom: isWideScreen ? 15 : 0,
                top: isWideScreen ? 15 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: navigationShell,
              ),
            ),
            Positioned(
              left: isWideScreen ? 10 : 0,
              right: isWideScreen ? null : 0,
              top: isWideScreen ? 20 : null,
              bottom: 10,
              child: SafeArea(
                child: isWideScreen
                    ? _buildFloatingSideNav(context)
                    : _buildCrystalBottomNav(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingSideNav(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.primary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = navigationShell.currentIndex == index;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: index == 0
                    ? BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50))
                    : index == (navItems.length - 1)
                        ? BorderRadius.only(
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          )
                        : null,
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : null,
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              margin: const EdgeInsets.all(5),
              child: InkWell(
                onTap: () => navigationShell.goBranch(index),
                child: Center(
                  child: Icon(
                    item.icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCrystalBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width * 0.15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: theme.colorScheme.surface.withOpacity(0.5),
              border:
                  Border.all(color: theme.colorScheme.primary.withOpacity(0.8)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = navigationShell.currentIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () => navigationShell.goBranch(index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.2)
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// Exit confirmation dialog
void showExitConfirmationDialog(BuildContext context,
    {bool isSystemExit = false}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Exit'),
      content: const Text('Are you sure you want to exit the app?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (isSystemExit) {
              SystemNavigator.pop();
            } else {
              context.pop();
            }
          },
          child: const Text('Exit'),
        ),
      ],
    ),
  );
}
