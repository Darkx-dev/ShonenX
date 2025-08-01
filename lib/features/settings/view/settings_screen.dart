import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shonenx/features/settings/widgets/settings_item.dart';
import 'package:shonenx/features/settings/widgets/settings_section.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton.filledTonal(
              onPressed: () => context.pop(), icon: Icon(Iconsax.arrow_left_2)),
          title: const Text('Settings'),
          forceMaterialTransparency: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              SettingsSection(
                  title: 'Account',
                  titleColor: colorScheme.primary,
                  onTap: () {},
                  items: [
                    SettingsItem(
                      icon: Icon(Iconsax.user, color: colorScheme.primary),
                      iconColor: colorScheme.primary,
                      title: 'Profile Settings',
                      description: 'AniList integration, account preferences',
                      onTap: () => context.push('/settings/account'),
                    ),
                  ]),
              const SizedBox(height: 10),
              SettingsSection(
                  title: 'Content & Playback',
                  titleColor: colorScheme.primary,
                  onTap: () {},
                  items: [
                    SettingsItem(
                      icon: Icon(Icons.source_outlined,
                          color: colorScheme.primary),
                      iconColor: colorScheme.primary,
                      title: 'Anime Sources',
                      description: 'Manage anime content providers',
                      onTap: () => context.push('/settings/anime-sources'),
                    ),
                    SettingsItem(
                      icon:
                          Icon(Iconsax.video_play, color: colorScheme.primary),
                      iconColor: colorScheme.primary,
                      title: 'Video Player',
                      description: 'Manage video player settings',
                      onTap: () => context.push('/settings/player'),
                    ),
                  ]),
              const SizedBox(height: 10),
              SettingsSection(
                  title: 'Appearance',
                  titleColor: colorScheme.primary,
                  onTap: () {},
                  items: [
                    SettingsItem(
                      icon:
                          Icon(Iconsax.paintbucket, color: colorScheme.primary),
                      iconColor: colorScheme.primary,
                      title: 'Theme Settings',
                      description: 'Customize app colors and appearance',
                      onTap: () => context.push('/settings/theme'),
                    ),
                    SettingsItem(
                      icon: Icon(Iconsax.mobile, color: colorScheme.primary),
                      iconColor: colorScheme.primary,
                      title: 'UI Settings',
                      description: 'Customize the interface and layout',
                      onTap: () => context.push('/settings/ui'),
                    ),
                  ]),
              const SizedBox(height: 10),
              SettingsSection(
                  title: 'Support',
                  titleColor: colorScheme.primary,
                  onTap: () {},
                  items: [
                    SettingsItem(
                      icon:
                          Icon(Iconsax.info_circle, color: colorScheme.primary),
                      iconColor: colorScheme.primary,
                      title: 'About',
                      description: 'App information and licenses',
                      onTap: () => context.push('/settings/about'),
                    ),
                  ]),
              const SizedBox(height: 20)
            ],
          ),
        ));
  }
}
