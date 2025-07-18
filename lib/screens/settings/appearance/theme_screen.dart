// import 'package:flex_color_scheme/flex_color_scheme.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:shonenx/data/hive/models/settings/theme_model.dart';
// import 'package:shonenx/data/hive/providers/theme_provider.dart';
// import 'package:shonenx/widgets/ui/shonenx_settings.dart';

// // Section configuration model
// class SectionConfig {
//   final String title;
//   final List<SettingItemConfig> items;

//   SectionConfig({required this.title, required this.items});
// }

// class SettingItemConfig {
//   final String title;
//   final String description;
//   final IconData icon;
//   final Widget? trailing;
//   final VoidCallback? onTap;
//   final bool isSlider;
//   final double? sliderValue;
//   final double? sliderMin;
//   final double? sliderMax;
//   final int? sliderDivisions;
//   final String? sliderSuffix;
//   final ValueChanged<double>? onSliderChanged;

//   SettingItemConfig({
//     required this.title,
//     required this.description,
//     required this.icon,
//     this.trailing,
//     this.onTap,
//     this.isSlider = false,
//     this.sliderValue,
//     this.sliderMin,
//     this.sliderMax,
//     this.sliderDivisions,
//     this.sliderSuffix,
//     this.onSliderChanged,
//   });
// }

// class ThemeSettingsScreen extends ConsumerWidget {
//   const ThemeSettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Consumer(
//       builder: (context, ref, child) {
//         final settings = ref.watch(themeSettingsProvider);
//         // if (settingsState.isLoading) {
//         //   return const Center(child: CircularProgressIndicator());
//         // }
//         final sections = _buildSectionConfigs(context, settings, ref);
//         return ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: sections.length + 1,
//           itemBuilder: (context, index) {
//             if (index == sections.length) {
//               return SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.15);
//             }
//             return SettingsSection(
//               title: sections[index].title,
//               items: sections[index].items,
//             );
//           },
//         );
//       },
//     );
//   }

//   List<SectionConfig> _buildSectionConfigs(
//       BuildContext context, ThemeSettings settings, WidgetRef ref) {
//     final notifier = ref.read(themeSettingsProvider.notifier);
//     final colorScheme = Theme.of(context).colorScheme;

//     return [
//       SectionConfig(
//         title: 'Theme',
//         items: [
//           SettingItemConfig(
//             title: 'Dark Mode',
//             description: 'Switch to dark theme',
//             icon: Iconsax.moon,
//             trailing: Switch(
//               value: settings.themeMode != 'light',
//               onChanged: (value) => notifier.updateField(
//                   (prev) => prev.copyWith(themeMode: value ? 'dark' : 'light')),
//               activeColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//             ),
//             onTap: () {},
//           ),
//           if (settings.themeMode != 'light')
//             SettingItemConfig(
//               title: 'AMOLED Dark',
//               description: 'Use pure black for dark mode',
//               icon: Iconsax.colorfilter,
//               trailing: Switch(
//                 value: settings.amoled,
//                 onChanged: (value) => notifier
//                     .updateField((prev) => prev.copyWith(amoled: value)),
//                 activeColor: colorScheme.primaryContainer,
//                 activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//               ),
//               onTap: () {},
//             ),
//         ],
//       ),
//       SectionConfig(
//         title: 'Material Design',
//         items: [
//           SettingItemConfig(
//             title: 'Material 3',
//             description: 'Enable Material 3 design',
//             icon: Iconsax.designtools,
//             trailing: Switch(
//               value: settings.useMaterial3,
//               onChanged: (value) => notifier
//                   .updateField((prev) => prev.copyWith(useMaterial3: value)),
//               activeColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//             ),
//             onTap: () {},
//           ),
//           SettingItemConfig(
//             title: 'Sub-themes',
//             description: 'Apply theme to all components',
//             icon: Iconsax.brush_2,
//             trailing: Switch(
//               value: settings.useSubThemes,
//               onChanged: (value) => notifier
//                   .updateField((prev) => prev.copyWith(useSubThemes: value)),
//               activeColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//             ),
//             onTap: () {},
//           ),
//         ],
//       ),
//       SectionConfig(
//         title: 'Colors',
//         items: [
//           SettingItemConfig(
//             title: 'Swap Light Colors',
//             description: 'Swap primaryContainer/secondary in light mode',
//             icon: Iconsax.arrange_square,
//             trailing: Switch(
//               value: settings.swapLightColors,
//               onChanged: (value) => notifier
//                   .updateField((prev) => prev.copyWith(swapLightColors: value)),
//               activeColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//             ),
//             onTap: () {},
//           ),
//           if (settings.themeMode != 'light')
//             SettingItemConfig(
//               title: 'Swap Dark Colors',
//               description: 'Swap primaryContainer/secondary in dark mode',
//               icon: Iconsax.arrange_square,
//               trailing: Switch(
//                 value: settings.swapDarkColors,
//                 onChanged: (value) => notifier.updateField(
//                     (prev) => prev.copyWith(swapDarkColors: value)),
//                 activeColor: colorScheme.primaryContainer,
//                 activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//               ),
//               onTap: () {},
//             ),
//           // SettingItemConfig(
//           //   title: 'Use Key Colors',
//           //   description: 'Use key colors for theme',
//           //   icon: Iconsax.color_swatch,
//           //   trailing: Switch(
//           //     value: settings.useKeyColors,
//           //     onChanged: (value) => notifier
//           //         .updateField((prev) => prev.copyWith(useKeyColors: value)),
//           //     activeColor: colorScheme.primaryContainer,
//           //     activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//           //   ),
//           //   onTap: () {},
//           // ),
//           // SettingItemConfig(
//           //   title: 'Use Tertiary',
//           //   description: 'Include tertiary colors in theme',
//           //   icon: Iconsax.color_swatch,
//           //   trailing: Switch(
//           //     value: settings.useTertiary,
//           //     onChanged: (value) => notifier
//           //         .updateField((prev) => prev.copyWith(useTertiary: value)),
//           //     activeColor: colorScheme.primaryContainer,
//           //     activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//           //   ),
//           //   onTap: () {},
//           // ),
//           SettingItemConfig(
//             title: 'Color Blend Level',
//             description: settings.blendLevel.toStringAsFixed(1),
//             icon: Iconsax.slider,
//             isSlider: true,
//             sliderValue: settings.blendLevel.toDouble(),
//             sliderMin: 0,
//             sliderMax: 40,
//             sliderDivisions: 40,
//             sliderSuffix: '',
//             onSliderChanged: (value) => notifier.updateField(
//                 (prev) => prev.copyWith(blendLevel: value.toInt())),
//             onTap: () {},
//           ),
//         ],
//       ),
//       SectionConfig(
//         title: 'Components',
//         items: [
//           SettingItemConfig(
//             title: 'App Bar Opacity',
//             description:
//                 '${(settings.appBarOpacity * 100).toStringAsFixed(1)}%',
//             icon: Iconsax.slider,
//             isSlider: true,
//             sliderValue: settings.appBarOpacity,
//             sliderMin: 0,
//             sliderMax: 1,
//             sliderDivisions: 20,
//             sliderSuffix: '%',
//             onSliderChanged: (value) => notifier
//                 .updateField((prev) => prev.copyWith(appBarOpacity: value)),
//             onTap: () {},
//           ),
//           SettingItemConfig(
//             title: 'Use AppBar Colors',
//             description: 'Apply custom colors to app bar',
//             icon: Iconsax.colorfilter,
//             trailing: Switch(
//               value: settings.useAppbarColors,
//               onChanged: (value) => notifier
//                   .updateField((prev) => prev.copyWith(useAppbarColors: value)),
//               activeColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//             ),
//             onTap: () {},
//           ),
//           SettingItemConfig(
//             title: 'Tab Bar Opacity',
//             description:
//                 '${(settings.tabBarOpacity * 100).toStringAsFixed(1)}%',
//             icon: Iconsax.slider,
//             isSlider: true,
//             sliderValue: settings.tabBarOpacity,
//             sliderMin: 0,
//             sliderMax: 1,
//             sliderDivisions: 20,
//             sliderSuffix: '%',
//             onSliderChanged: (value) => notifier
//                 .updateField((prev) => prev.copyWith(tabBarOpacity: value)),
//             onTap: () {},
//           ),
//           SettingItemConfig(
//             title: 'Bottom Bar Opacity',
//             description:
//                 '${(settings.bottomBarOpacity * 100).toStringAsFixed(1)}%',
//             icon: Iconsax.slider,
//             isSlider: true,
//             sliderValue: settings.bottomBarOpacity,
//             sliderMin: 0,
//             sliderMax: 1,
//             sliderDivisions: 20,
//             sliderSuffix: '%',
//             onSliderChanged: (value) => notifier
//                 .updateField((prev) => prev.copyWith(bottomBarOpacity: value)),
//             onTap: () {},
//           ),
//           SettingItemConfig(
//             title: 'Transparent Status Bar',
//             description: 'Make status bar transparent',
//             icon: Iconsax.status,
//             trailing: Switch(
//               value: settings.transparentStatusBar,
//               onChanged: (value) => notifier.updateField(
//                   (prev) => prev.copyWith(transparentStatusBar: value)),
//               activeColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//             ),
//             onTap: () {},
//           ),
//           SettingItemConfig(
//             title: 'Border Radius',
//             description: '${settings.defaultRadius.toStringAsFixed(1)}dp',
//             icon: Iconsax.slider,
//             isSlider: true,
//             sliderValue: settings.defaultRadius,
//             sliderMin: 0,
//             sliderMax: 24,
//             sliderDivisions: 24,
//             sliderSuffix: 'dp',
//             onSliderChanged: (value) => notifier
//                 .updateField((prev) => prev.copyWith(defaultRadius: value)),
//             onTap: () {},
//           ),
//           SettingItemConfig(
//             title: 'Tooltip Background',
//             description: 'Match tooltips to background',
//             icon: Iconsax.message_question,
//             trailing: Switch(
//               value: settings.tooltipsMatchBackground,
//               onChanged: (value) => notifier.updateField(
//                   (prev) => prev.copyWith(tooltipsMatchBackground: value)),
//               activeColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//             ),
//             onTap: () {},
//           ),
//         ],
//       ),
//       SectionConfig(
//         title: 'Typography',
//         items: [
//           SettingItemConfig(
//             title: 'Custom Typography',
//             description: 'Use custom text theme',
//             icon: Iconsax.text,
//             trailing: Switch(
//               value: settings.useTextTheme,
//               onChanged: (value) => notifier
//                   .updateField((prev) => prev.copyWith(useTextTheme: value)),
//               activeColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer.withOpacity(0.5),
//             ),
//             onTap: () {},
//           ),
//         ],
//       ),
//       SectionConfig(
//         title: 'Color Scheme',
//         items: [
//           SettingItemConfig(
//             title: 'Color Scheme',
//             description: 'Select a color scheme',
//             icon: Iconsax.colorfilter,
//             trailing: Text(
//               _formatSchemeName(settings.colorScheme),
//               style: TextStyle(color: colorScheme.onSurface),
//             ),
//             onTap: () => _showColorSchemeModal(context, settings, notifier),
//           ),
//         ],
//       ),
//     ];
//   }

//   void _showColorSchemeModal(BuildContext context, ThemeSettings settings,
//       ThemeSettingsNotifier notifier) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (modalContext) {
//         return ColorSchemeModal(
//           settings: settings,
//           notifier: notifier,
//         );
//       },
//     );
//   }

//   String _formatSchemeName(String name) {
//     return name
//         .splitMapJoin(
//           RegExp(r'(?=[A-Z])'),
//           onMatch: (m) => ' ${m.group(0)}',
//           onNonMatch: (n) => n,
//         )
//         .trim()
//         .split(' ')
//         .map((word) => word[0].toUpperCase() + word.substring(1))
//         .join(' ');
//   }
// }

// class SettingsSection extends StatelessWidget {
//   final String title;
//   final List<SettingItemConfig> items;

//   const SettingsSection({super.key, required this.title, required this.items});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Card(
//       elevation: 4,
//       shadowColor: colorScheme.shadow.withOpacity(0.2),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ExpansionTile(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: colorScheme.primaryContainer,
//           ),
//         ),
//         initiallyExpanded: title == 'Theme',
//         childrenPadding: const EdgeInsets.all(16),
//         tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         children: items.map((item) => _buildItem(context, item)).toList(),
//       ),
//     );
//   }

//   Widget _buildItem(BuildContext context, SettingItemConfig config) {
//     final colorScheme = Theme.of(context).colorScheme;

//     if (config.isSlider) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SettingsItem(
//             icon: config.icon,
//             title: config.title,
//             description: config.description,
//             onTap: config.onTap ?? () {},
//           ),
//           SliderTheme(
//             data: SliderThemeData(
//               trackHeight: 2,
//               thumbColor: colorScheme.primaryContainer,
//               activeTrackColor: colorScheme.primaryContainer,
//               inactiveTrackColor: colorScheme.surfaceContainerHighest,
//             ),
//             child: Slider(
//               value: config.sliderValue!,
//               min: config.sliderMin!,
//               max: config.sliderMax!,
//               divisions: config.sliderDivisions!,
//               onChanged: config.onSliderChanged!,
//             ),
//           ),
//         ],
//       );
//     }

//     return SettingsItem(
//       icon: config.icon,
//       title: config.title,
//       description: config.description,
//       trailing: config.trailing,
//       onTap: config.onTap ?? () {},
//     );
//   }
// }

// class ColorSchemeModal extends StatelessWidget {
//   final ThemeSettings settings;
//   final ThemeSettingsNotifier notifier;

//   const ColorSchemeModal(
//       {super.key, required this.settings, required this.notifier});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height * 0.5,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Select Color Scheme',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: GridView.builder(
//                 cacheExtent: 500,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 1.5,
//                 ),
//                 itemCount: FlexScheme.values.length,
//                 itemBuilder: (context, index) {
//                   final scheme = FlexScheme.values[index];
//                   return _SimpleColorSchemeCard(
//                     scheme: scheme,
//                     isSelected: settings.colorScheme == scheme.name,
//                     onSelected: (selectedScheme) {
//                       notifier.updateField(
//                         (prev) =>
//                             prev.copyWith(colorScheme: selectedScheme.name),
//                       );
//                       Navigator.pop(context);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SimpleColorSchemeCard extends StatelessWidget {
//   final FlexScheme scheme;
//   final bool isSelected;
//   final ValueChanged<FlexScheme> onSelected;

//   const _SimpleColorSchemeCard({
//     required this.scheme,
//     required this.isSelected,
//     required this.onSelected,
//   });

//   static final Map<FlexScheme, ColorScheme> _colorCache = {};

//   ColorScheme _getColorScheme(FlexScheme scheme) {
//     return _colorCache.putIfAbsent(
//       scheme,
//       () => FlexThemeData.light(scheme: scheme).colorScheme,
//     );
//   }

//   String _formatSchemeName(String name) {
//     return name
//         .splitMapJoin(
//           RegExp(r'(?=[A-Z])'),
//           onMatch: (m) => ' ${m.group(0)}',
//           onNonMatch: (n) => n,
//         )
//         .trim()
//         .split(' ')
//         .map((word) => word[0].toUpperCase() + word.substring(1))
//         .join(' ');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final schemeData = _getColorScheme(scheme);
//     final colorScheme = Theme.of(context).colorScheme;

//     return GestureDetector(
//       onTap: () => onSelected(scheme),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color:
//                 isSelected ? colorScheme.primaryContainer : Colors.transparent,
//             width: 2,
//           ),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                       color: colorScheme.primaryContainer.withOpacity(0.2),
//                       blurRadius: 6)
//                 ]
//               : null,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 20,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: schemeData.primaryContainer,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Container(
//                   width: 20,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: schemeData.secondary,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _formatSchemeName(scheme.name),
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: colorScheme.onSurface,
//               ),
//               maxLines: 2,
//               textAlign: TextAlign.center,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
