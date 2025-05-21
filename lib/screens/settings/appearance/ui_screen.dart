import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shonenx/core/models/anilist/anilist_media_list.dart'
    as anime_media;
import 'package:shonenx/data/hive/providers/ui_provider.dart';
import 'package:shonenx/widgets/ui/shonenx_settings.dart';

class UISettingsScreen extends ConsumerWidget {
  const UISettingsScreen({super.key});

  static final anime_media.Media animeMedia = anime_media.Media(
    id: 1,
    coverImage: anime_media.CoverImage(
      large:
          'https://cdn.noitatnemucod.net/thumbnail/300x400/100/bcd84731a3eda4f4a306250769675065.jpg',
      medium:
          'https://cdn.noitatnemucod.net/thumbnail/300x400/100/bcd84731a3eda4f4a306250769675065.jpg',
    ),
    title: anime_media.Title(
      english: "One Piece",
      romaji: "One Piece",
      native: "One Piece",
    ),
    format: 'TV',
    averageScore: 69,
    status: 'Completed',
    genres: ['Action', 'Adventure', 'Comedy'],
    episodes: 220,
    season: 'Fall',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final settingsState = ref.watch(uiSettingsProvider);

    // if (settingsState.isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return _buildContent(context, ref);
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              SettingsSection(
                context: context,
                title: 'Layout',
                items: [
                  SettingsItem(
                    onTap: () => _showDefaultTabDialog(context, ref),
                    icon: Iconsax.home,
                    title: 'Default Tab',
                    description: 'Set the tab shown on app launch',
                  ),
                  SettingsItem(
                    onTap: () => _showLayoutStyleDialog(context, ref),
                    icon: Iconsax.grid_3,
                    title: 'Layout Style',
                    description: 'Choose between grid or list view',
                    disabled: false,
                  ),
                ],
              ),
              SettingsSection(
                context: context,
                title: 'Content Display',
                items: [
                  SettingsItem(
                    icon: Iconsax.card,
                    title: 'Card Style',
                    description: 'Customize card appearance',
                    onTap: () => _showCardStyleDialog(context, ref),
                  ),
                ],
              ),
              SettingsSection(
                context: context,
                title: 'Immersive Mode',
                items: [
                  SettingsSwitch(
                    icon: Icons.fullscreen,
                    title: 'Enable Immersive Mode',
                    description:
                        'Toggle immersive mode for a distraction-free experience',
                    value: ref.watch(uiSettingsProvider).immersiveMode,
                    onChanged: (value) {
                      ref.read(uiSettingsProvider.notifier).updateSettings(
                            (prev) => prev.copyWith(
                              immersiveMode: value,
                            ),
                          );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ]),
          ),
        ],
      ),
    );
  }

  void _showDefaultTabDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final uiSettings = ref.read(uiSettingsProvider);
    final List<String> tabs = ["Home", "Watchlist", "Browse"];

    ValueNotifier<String> selectedTab = ValueNotifier(
        tabs.contains(uiSettings.defaultTab) ? uiSettings.defaultTab : 'Home');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Default tab'),
          content: ValueListenableBuilder<String>(
            valueListenable: selectedTab,
            builder: (context, value, child) {
              return DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                dropdownColor: colorScheme.surfaceContainerHighest,
                icon: Icon(Iconsax.arrow_down_1, color: colorScheme.onSurface),
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (newValue) => selectedTab.value = newValue!,
                items: tabs.map((tab) {
                  return DropdownMenuItem<String>(
                    value: tab,
                    child: Text(
                      tab,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () {
                ref.read(uiSettingsProvider.notifier).updateSettings(
                      (prev) => prev.copyWith(defaultTab: selectedTab.value),
                    );
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showLayoutStyleDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final uiSettings = ref.read(uiSettingsProvider);
    final List<String> layoutStyles = ['horizontal', 'vertical'];

    ValueNotifier<String> selectedStyle = ValueNotifier(
      layoutStyles.contains(uiSettings.layoutStyle)
          ? uiSettings.layoutStyle
          : 'horizontal',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Layout Style'),
          content: ValueListenableBuilder<String>(
            valueListenable: selectedStyle,
            builder: (context, value, child) {
              return DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                dropdownColor: colorScheme.surfaceContainerHighest,
                icon: Icon(Iconsax.arrow_down_1, color: colorScheme.onSurface),
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (newValue) => selectedStyle.value = newValue!,
                items: layoutStyles.map((style) {
                  return DropdownMenuItem<String>(
                    value: style,
                    child: Text(
                      style.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () {
                ref.read(uiSettingsProvider.notifier).updateSettings(
                      (prev) => prev.copyWith(layoutStyle: selectedStyle.value),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    duration: const Duration(seconds: 5),
                    content: AwesomeSnackbarContent(
                      title: 'Restart required',
                      message: 'You need to restart to avoid UI glitches once',
                      contentType: ContentType.warning,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showCardStyleDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final uiSettings = ref.read(uiSettingsProvider);
    final List<String> cardStyles = [
      'Card',
      'Compact',
      'Poster',
      'Glass',
      'Neon',
      'Minimal',
      'Cinematic',
    ];
    ValueNotifier<String> selectedStyle = ValueNotifier(
      cardStyles.contains(uiSettings.cardStyle) ? uiSettings.cardStyle : 'Card',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Card Style'),
          content: ValueListenableBuilder<String>(
            valueListenable: selectedStyle,
            builder: (context, value, child) {
              return DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
                dropdownColor: colorScheme.surfaceContainerHighest,
                icon: Icon(Iconsax.arrow_down_1, color: colorScheme.onSurface),
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (newValue) => selectedStyle.value = newValue!,
                items: cardStyles.map((style) {
                  return DropdownMenuItem<String>(
                    value: style,
                    child: Text(
                      style,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: colorScheme.onSurface)),
            ),
            TextButton(
              onPressed: () {
                ref.read(uiSettingsProvider.notifier).updateSettings(
                      (prev) => prev.copyWith(cardStyle: selectedStyle.value),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    duration: const Duration(seconds: 5),
                    content: AwesomeSnackbarContent(
                      title: 'Restart required',
                      message: 'You need to restart to avoid UI glitches once',
                      contentType: ContentType.warning,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }
}
