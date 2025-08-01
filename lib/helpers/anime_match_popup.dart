import 'dart:async';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shonenx/core/models/anilist/anilist_media_list.dart';
import 'package:shonenx/core/models/anime/anime_model.dep.dart';
import 'package:shonenx/core/registery/anime_source_registery_provider.dart';
import 'package:shonenx/core/sources/anime/anime_provider.dart';
import 'package:shonenx/core/utils/app_logger.dart';
import 'package:shonenx/helpers/matcher.dart';

/// Searches for an anime match and navigates to the watch screen.
///
/// It first attempts a high-confidence automatic match. If unsuccessful,
/// it displays a search dialog for manual selection.
Future<void> providerAnimeMatchSearch({
  Function? beforeSearchCallback,
  Function? afterSearchCallback,
  required BuildContext context,
  required WidgetRef ref,
  required Media animeMedia,
  int plusEpisode = 0,
}) async {
  beforeSearchCallback?.call();
  AppLogger.d('Starting anime match search for animeId: ${animeMedia.id}');

  try {
    final animeProvider = ref.read(selectedAnimeProvider);
    final title = animeMedia.title?.english ?? animeMedia.title?.romaji;
    if (animeProvider == null || title == null) {
      throw Exception('Anime provider or title is missing.');
    }

    final initialResponse = await animeProvider.getSearch(
        Uri.encodeComponent(title.trim()), animeMedia.format, 1);
    if (!context.mounted) return;

    if (initialResponse.results.isEmpty) {
      _showErrorSnackBar(context, 'Anime Not Found',
          'We couldn\'t locate this anime with the selected provider.');
      return;
    }

    // Calculate similarity for valid results and sort them
    final matchedResults = initialResponse.results
        .where((r) => r.name != null && r.id != null)
        .map((r) => (
              result: r,
              similarity: calculateSimilarity(
                  r.name!.toLowerCase(), title.toLowerCase())
            ))
        .where((p) => p.similarity > 0.1) // Filter out very low-quality matches
        .toList()
      ..sort((a, b) => b.similarity.compareTo(a.similarity));

    if (!context.mounted) return;

    // Navigate directly if a high-confidence match is found
    if (matchedResults.isNotEmpty && matchedResults.first.similarity >= 0.8) {
      final bestMatch = matchedResults.first.result;
      AppLogger.d('High-confidence match found: ${bestMatch.name}');
      _navigateToWatch(
        context: context,
        ref: ref,
        animeId: bestMatch.id!,
        animeName: bestMatch.name!,
        animeMedia: animeMedia,
        plusEpisode: plusEpisode,
      );
      return;
    }

    // Show search dialog for manual selection
    await showDialog(
      context: context,
      builder: (_) => _AnimeSearchDialog(
        initialResults: matchedResults.map((r) => r.result).toList(),
        animeProvider: animeProvider,
        animeMedia: animeMedia,
        plusEpisode: plusEpisode,
        initialQuery: title,
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.e('Anime match search failed', e, stackTrace);
    if (context.mounted) {
      _showErrorSnackBar(context, 'Error', 'Failed to load anime details.');
    }
  } finally {
    afterSearchCallback?.call();
  }
}

/// A minimal dialog for searching and selecting an anime.
class _AnimeSearchDialog extends ConsumerStatefulWidget {
  final List<BaseAnimeModel> initialResults;
  final AnimeProvider animeProvider;
  final Media animeMedia;
  final int plusEpisode;
  final String initialQuery;

  const _AnimeSearchDialog({
    required this.initialResults,
    required this.animeProvider,
    required this.animeMedia,
    required this.plusEpisode,
    required this.initialQuery,
  });

  @override
  ConsumerState<_AnimeSearchDialog> createState() => _AnimeSearchDialogState();
}

class _AnimeSearchDialogState extends ConsumerState<_AnimeSearchDialog> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  List<BaseAnimeModel> _results = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _results = widget.initialResults;
    _searchController = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchFocusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().length < 2) return;
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _searchAnime(query),
    );
  }

  Future<void> _searchAnime(String query) async {
    setState(() => _isLoading = true);
    try {
      final response = await widget.animeProvider.getSearch(
          Uri.encodeComponent(query.trim()), widget.animeMedia.format, 1);
      if (mounted) {
        setState(() =>
            _results = response.results.where((r) => r.id != null).toList());
      }
    } catch (e, stackTrace) {
      AppLogger.e('Anime search in dialog failed', e, stackTrace);
      if (mounted) {
        _showErrorSnackBar(context, 'Search Error', 'Could not fetch results.');
        setState(() => _results = []);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectAnime(BaseAnimeModel anime) {
    Navigator.of(context).pop();
    _navigateToWatch(
      context: context,
      ref: ref,
      animeId: anime.id!,
      animeName: anime.name ?? 'Unknown',
      animeMedia: widget.animeMedia,
      plusEpisode: widget.plusEpisode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find Your Anime', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Select the correct match or try a new search.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by title...',
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildResultsContent(theme)),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.search_status, size: 48, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text('No Anime Found', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Try different keywords.', style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      itemBuilder: (context, index) => _AnimeTile(
        anime: _results[index],
        onTap: () => _selectAnime(_results[index]),
      ),
    );
  }
}

/// A minimal, stateless widget to display an anime search result.
class _AnimeTile extends StatelessWidget {
  final BaseAnimeModel anime;
  final VoidCallback onTap;

  const _AnimeTile({required this.anime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadata = [anime.releaseDate, anime.type]
        .where((s) => s != null && s.isNotEmpty)
        .join(' • ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      hoverColor: theme.colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: anime.poster ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: theme.colorScheme.surfaceContainerHigh,
                    child: Icon(Iconsax.image, color: theme.disabledColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    anime.name ?? 'No Title',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (metadata.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      metadata,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Iconsax.arrow_right_3,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Helper to show a standardized error snackbar.
void _showErrorSnackBar(BuildContext context, String title, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: ContentType.failure,
        ),
      ),
    );
}

/// Helper to construct the route and navigate to the watch screen.
void _navigateToWatch({
  required BuildContext context,
  required WidgetRef ref,
  required String animeId,
  required String animeName,
  required Media animeMedia,
  required int plusEpisode,
}) {
  // final progress = ref
  //     .read(animeWatchProgressProvider.notifier)
  //     .getMostRecentEpisodeProgressByAnimeId(animeMedia.id!);

  // final episode = (progress?.episodeNumber ?? 0) + plusEpisode;
  // final startAt = progress?.progressInSeconds ?? 0;
  // final encodedName = Uri.encodeComponent(animeName);

  final route = '/watch/$animeId'
      '?animeName=$animeName'
      '&episode=0';
  // '&startAt=';

  AppLogger.d('Navigating to watch screen: $route');
  context.push(route, extra: animeMedia);
}
