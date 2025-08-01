import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shonenx/core/models/anilist/anilist_media_list.dart';

/// Header widget for the anime details screen with banner, poster, and title
class DetailsHeader extends StatelessWidget {
  final Media anime;
  final String tag;
  final VoidCallback onEditPressed;

  const DetailsHeader({
    super.key,
    required this.anime,
    required this.tag,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 420,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: anime.bannerImage ?? anime.coverImage?.large ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: colorScheme.surfaceContainer),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    colorScheme.surfaceContainerLowest,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Hero(
                    tag: tag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: anime.coverImage?.large ?? '',
                        width: 105,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          anime.title?.english ?? anime.title?.romaji ?? '',
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (anime.title?.native != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              anime.title!.native!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        const SizedBox(height: 12),
                        GenreTags(
                          genres: anime.genres ?? [],
                          status: anime.status ?? 'Unknown',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left_1, color: Colors.white, size: 28),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.edit, color: Colors.white, size: 28),
          tooltip: 'Add or Edit in your list',
          onPressed: onEditPressed,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

/// Widget for displaying genre tags and status
class GenreTags extends StatelessWidget {
  final List<String> genres;
  final String status;

  const GenreTags({
    super.key,
    required this.genres,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GenreTag(
            text: status,
            color: theme.colorScheme.primaryContainer,
            isStatus: true,
          ),
          const SizedBox(width: 8),
          ...genres.map((genre) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GenreTag(text: genre),
              )),
        ],
      ),
    );
  }
}

/// Individual tag widget for genres and status
class GenreTag extends StatelessWidget {
  final String text;
  final Color? color;
  final bool isStatus;

  const GenreTag({
    super.key,
    required this.text,
    this.color,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.2) ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? Colors.white.withOpacity(0.9),
              fontWeight: isStatus ? FontWeight.w600 : FontWeight.w500,
            ),
      ),
    );
  }
}
