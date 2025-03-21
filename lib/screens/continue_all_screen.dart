import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shonenx/data/hive/boxes/anime_watch_progress_box.dart';
import 'package:shonenx/data/hive/models/anime_watch_progress_model.dart';
import 'package:shonenx/widgets/anime/anime_continue_card.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class ContinueAllScreen extends StatelessWidget {
  final AnimeWatchProgressBox animeWatchProgressBox;

  const ContinueAllScreen({super.key, required this.animeWatchProgressBox});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Content(box: animeWatchProgressBox),
    );
  }
}

class _Content extends StatefulWidget {
  final AnimeWatchProgressBox box;

  const _Content({required this.box});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _sortBy = 'lastWatched';
  String _filterBy = 'all'; // 'all', 'inProgress', 'completed'
  bool _groupMode = false;
  bool _multiSelectMode = false;
  final Set<String> _selectedItems = {};
  late AnimationController _animationController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (!widget.box.isInitialized) {
      widget.box.init();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value);
    });
  }

  void _enterMultiSelectMode() {
    setState(() {
      _multiSelectMode = true;
      _animationController.forward();
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _multiSelectMode = false;
      _selectedItems.clear();
      _animationController.reverse();
    });
  }

  void _clearAllEntries() async {
    await widget.box.clearAll();
    _exitMultiSelectMode();
  }

  void _deleteSelected() async {
    for (var key in _selectedItems) {
      final parts = key.split('-');
      final animeId = int.parse(parts[0]);
      final episodeNumber = int.parse(parts[1]);
      final entry = widget.box.getEntry(animeId);
      if (entry != null) {
        final updatedEpisodes =
            Map<int, EpisodeProgress>.from(entry.episodesProgress);
        updatedEpisodes.remove(episodeNumber);
        if (updatedEpisodes.isEmpty) {
          await widget.box.deleteEntry(animeId);
        } else {
          await widget.box
              .setEntry(entry.copyWith(episodesProgress: updatedEpisodes));
        }
      }
    }
    _exitMultiSelectMode();
  }

  List<({AnimeWatchProgressEntry anime, EpisodeProgress episode})>
      _getFilteredEntries() {
    var entries = widget.box.getAllMostRecentWatchedEpisodesWithAnime();

    // Search filter
    if (_searchQuery.isNotEmpty) {
      entries = entries
          .where((entry) => entry.anime.animeTitle
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Filter by status
    if (_filterBy != 'all') {
      entries = entries.where((entry) {
        return _filterBy == 'completed'
            ? entry.episode.isCompleted
            : !entry.episode.isCompleted;
      }).toList();
    }

    // Sorting
    switch (_sortBy) {
      case 'title':
        entries
            .sort((a, b) => a.anime.animeTitle.compareTo(b.anime.animeTitle));
        break;
      case 'episode':
        entries.sort((a, b) =>
            a.episode.episodeNumber.compareTo(b.episode.episodeNumber));
        break;
      case 'lastWatched':
        entries.sort(
            (a, b) => b.episode.watchedAt!.compareTo(a.episode.watchedAt!));
        break;
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              leading: IconButton(
                icon: Icon(Iconsax.arrow_left_2, color: colorScheme.primary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Continue Watching',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(_groupMode ? Iconsax.grid_2 : Iconsax.grid_1,
                      color: colorScheme.onSurface),
                  onPressed: () => setState(() => _groupMode = !_groupMode),
                  tooltip: 'Toggle Layout',
                ),
                PopupMenuButton<String>(
                  icon: Icon(Iconsax.sort, color: colorScheme.onSurface),
                  onSelected: (value) => setState(() => _sortBy = value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'title',
                      child: Text('Sort by Title',
                          style: GoogleFonts.montserrat()),
                    ),
                    PopupMenuItem(
                      value: 'episode',
                      child: Text('Sort by Episode',
                          style: GoogleFonts.montserrat()),
                    ),
                    PopupMenuItem(
                      value: 'lastWatched',
                      child: Text('Sort by Last Watched',
                          style: GoogleFonts.montserrat()),
                    ),
                  ],
                  color: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Iconsax.filter, color: colorScheme.onSurface),
                  onSelected: (value) => setState(() => _filterBy = value),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'all',
                      child: Text('All', style: GoogleFonts.montserrat()),
                    ),
                    PopupMenuItem(
                      value: 'inProgress',
                      child:
                          Text('In Progress', style: GoogleFonts.montserrat()),
                    ),
                    PopupMenuItem(
                      value: 'completed',
                      child: Text('Completed', style: GoogleFonts.montserrat()),
                    ),
                  ],
                  color: colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: _SearchField(onChanged: _onSearchChanged),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: ValueListenableBuilder<Box>(
                valueListenable: widget.box.boxValueListenable,
                builder: (context, box, child) {
                  final entries = _getFilteredEntries();
                  return entries.isEmpty
                      ? const SliverFillRemaining(child: _EmptyState())
                      : _EntriesView(
                          entries: entries,
                          groupMode: _groupMode,
                          multiSelectMode: _multiSelectMode,
                          selectedItems: _selectedItems,
                          onLongPress: (key) {
                            if (!_multiSelectMode) _enterMultiSelectMode();
                            setState(() => _selectedItems.contains(key)
                                ? _selectedItems.remove(key)
                                : _selectedItems.add(key));
                          },
                          onTap: (key) {
                            if (_multiSelectMode) {
                              setState(() => _selectedItems.contains(key)
                                  ? _selectedItems.remove(key)
                                  : _selectedItems.add(key));
                            } else {
                              // Add navigation logic here if needed
                            }
                          },
                        );
                },
              ),
            ),
          ],
        ),
        if (_multiSelectMode)
          Positioned(
            bottom: 16,
            right: 16,
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    onPressed: _exitMultiSelectMode,
                    backgroundColor: colorScheme.primary,
                    tooltip: 'Exit Multi-Select',
                    child:
                        const Icon(Iconsax.close_circle, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.small(
                    onPressed: _deleteSelected,
                    backgroundColor: Colors.red,
                    tooltip: 'Delete Selected',
                    child: const Icon(Iconsax.trash, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.small(
                    onPressed: () => _showClearAllDialog(context),
                    backgroundColor: Colors.orange,
                    tooltip: 'Clear All',
                    child: const Icon(Iconsax.broom, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear All?',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Text('This will remove all watch progress. Are you sure?',
            style: GoogleFonts.montserrat()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.montserrat()),
          ),
          TextButton(
            onPressed: () {
              _clearAllEntries();
              Navigator.pop(context);
            },
            child:
                Text('Clear', style: GoogleFonts.montserrat(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search titles...',
          hintStyle:
              GoogleFonts.montserrat(color: colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Iconsax.search_normal, color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: GoogleFonts.montserrat(),
        onChanged: onChanged,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.video_octagon,
            size: 100,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing Here Yet',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Watch some anime to track your progress!',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntriesView extends StatelessWidget {
  final List<({AnimeWatchProgressEntry anime, EpisodeProgress episode})>
      entries;
  final bool groupMode;
  final bool multiSelectMode;
  final Set<String> selectedItems;
  final Function(String) onLongPress;
  final Function(String) onTap;

  const _EntriesView({
    required this.entries,
    required this.groupMode,
    required this.multiSelectMode,
    required this.selectedItems,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;

    if (groupMode) {
      final groupedEntries = <int,
          List<({AnimeWatchProgressEntry anime, EpisodeProgress episode})>>{};
      for (var entry in entries) {
        groupedEntries.putIfAbsent(entry.anime.animeId, () => []).add(entry);
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final animeId = groupedEntries.keys.elementAt(index);
            final group = groupedEntries[animeId]!;
            return _GroupedSection(
              anime: group.first.anime,
              episodes: group,
              multiSelectMode: multiSelectMode,
              selectedItems: selectedItems,
              onLongPress: onLongPress,
              onTap: onTap,
            );
          },
          childCount: groupedEntries.length,
        ),
      );
    }

    return isWideScreen
        ? SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 340, // Adjusted for modern card width
              childAspectRatio: 16 / 10,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCard(context, index),
              childCount: entries.length,
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCard(context, index),
              ),
              childCount: entries.length,
            ),
          );
  }

  Widget _buildCard(BuildContext context, int index) {
    final entry = entries[index];
    final key = '${entry.anime.animeId}-${entry.episode.episodeNumber}';
    return AnimatedScale(
      scale: selectedItems.contains(key) ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: _CardItem(
        anime: entry.anime,
        episode: entry.episode,
        index: index,
        isSelected: selectedItems.contains(key),
        onLongPress: () => onLongPress(key),
        onTap: () => onTap(key),
        multiSelectMode: multiSelectMode,
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final AnimeWatchProgressEntry anime;
  final EpisodeProgress episode;
  final int index;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final bool multiSelectMode;

  const _CardItem({
    required this.anime,
    required this.episode,
    required this.index,
    required this.isSelected,
    required this.onLongPress,
    required this.onTap,
    required this.multiSelectMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: ContinueWatchingCard(
        anime: anime,
        episode: episode,
        index: index,
        isSelected: isSelected,
        onTap: onTap,
        multiSelectMode: multiSelectMode,
      ),
    );
  }
}

class _GroupedSection extends StatefulWidget {
  final AnimeWatchProgressEntry anime;
  final List<({AnimeWatchProgressEntry anime, EpisodeProgress episode})>
      episodes;
  final bool multiSelectMode;
  final Set<String> selectedItems;
  final Function(String) onLongPress;
  final Function(String) onTap;

  const _GroupedSection({
    required this.anime,
    required this.episodes,
    required this.multiSelectMode,
    required this.selectedItems,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  State<_GroupedSection> createState() => _GroupedSectionState();
}

class _GroupedSectionState extends State<_GroupedSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: widget.anime.animeCover.isNotEmpty
                  ? NetworkImage(widget.anime.animeCover)
                  : null,
              backgroundColor: colorScheme.surfaceContainer,
              child: widget.anime.animeCover.isEmpty
                  ? Icon(Iconsax.image, color: colorScheme.onSurfaceVariant)
                  : null,
            ),
            title: Text(
              widget.anime.animeTitle,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Iconsax.arrow_down_1 : Iconsax.arrow_right_2,
                color: colorScheme.primary,
              ),
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            ...widget.episodes.map((entry) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _CardItem(
                    anime: entry.anime,
                    episode: entry.episode,
                    index: widget.episodes.indexOf(entry),
                    isSelected: widget.selectedItems.contains(
                        '${entry.anime.animeId}-${entry.episode.episodeNumber}'),
                    onLongPress: () => widget.onLongPress(
                        '${entry.anime.animeId}-${entry.episode.episodeNumber}'),
                    onTap: () => widget.onTap(
                        '${entry.anime.animeId}-${entry.episode.episodeNumber}'),
                    multiSelectMode: widget.multiSelectMode,
                  ),
                )),
        ],
      ),
    );
  }
}
