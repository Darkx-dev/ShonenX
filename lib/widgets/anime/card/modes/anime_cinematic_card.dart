import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shonenx/core/models/anilist/anilist_media_list.dart';
import 'package:shonenx/widgets/anime/card/anime_card_image.dart';

class CinematicCard extends StatelessWidget {
  final Media? anime;
  final String tag;
  final bool isHovered;

  const CinematicCard({
    super.key,
    required this.anime,
    required this.tag,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius =
        (theme.cardTheme.shape as RoundedRectangleBorder?)?.borderRadius ??
            BorderRadius.circular(12);

    // Cinematic aspect ratio (closer to 2.39:1 anamorphic widescreen)
    return AspectRatio(
      aspectRatio: 2.39 / 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        transform:
            isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image with parallax effect
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                top: isHovered ? -10 : 0,
                bottom: isHovered ? -10 : 0,
                left: isHovered ? -10 : 0,
                right: isHovered ? -10 : 0,
                child: AnimeImage(
                  anime: anime,
                  tag: "${tag}_bg",
                  height: double.infinity,
                ),
              ),

              // Dramatic lighting overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      theme.shadowColor.withOpacity(0.95),
                      theme.shadowColor.withOpacity(0.3),
                      theme.shadowColor.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Cinematic letterbox effect (optional)
              Column(
                children: [
                  Container(height: 5, color: Colors.black),
                  const Spacer(),
                  Container(height: 5, color: Colors.black),
                ],
              ),

              // Content with dramatic layout
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left side: Small poster thumbnail
                    if (anime?.coverImage?.large != null)
                      Container(
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AnimeImage(
                            anime: anime,
                            tag: "${tag}_thumb",
                            height: 130,
                          ),
                        ),
                      ),

                    const SizedBox(width: 24),

                    // Main content
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with dramatic typography
                          _buildTitle(anime, theme),

                          const SizedBox(height: 8),

                          // Genres as a horizontal scroll
                          if (anime?.genres != null &&
                              anime!.genres!.isNotEmpty)
                            SizedBox(
                              height: 24,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: anime!.genres!.length.clamp(0, 3),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.tertiary
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.tertiary
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      anime!.genres![index],
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onBackground
                                            .withOpacity(0.9),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Stats row with cinematic styling
                          Row(
                            children: [
                              if (anime?.episodes != null)
                                _buildCinematicTag(
                                  context,
                                  '${anime!.episodes} Episodes',
                                  Iconsax.play,
                                  theme.colorScheme.secondary,
                                ),
                              if (anime?.averageScore != null) ...[
                                const SizedBox(width: 12),
                                _buildCinematicTag(
                                  context,
                                  '${anime!.averageScore}%',
                                  Iconsax.star1,
                                  theme.colorScheme.primary,
                                ),
                              ],
                              if (anime?.status != null) ...[
                                const SizedBox(width: 12),
                                _buildCinematicTag(
                                  context,
                                  _formatStatus(anime!.status!),
                                  Iconsax.timer_1,
                                  theme.colorScheme.tertiary,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right side: Format badge and action buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Format badge at top right
                        if (anime?.format != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              _formatMediaType(anime!.format!),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                        const Spacer(),

                        // Action button
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isHovered ? 1.0 : 0.0,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Iconsax.play_circle, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Watch',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ambient highlight effect on hover
              if (isHovered)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        width: 2,
                      ),
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(Media? anime, ThemeData theme) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.white,
          Colors.white.withOpacity(0.9),
        ],
        begin: Alignment.center,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        anime?.title?.english ??
            anime?.title?.romaji ??
            anime?.title?.native ??
            'Unknown Title',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          height: 1.1,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCinematicTag(
      BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color.withOpacity(0.9),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
          ),
        ],
      ),
    );
  }

  String _formatMediaType(String format) {
    final formattedType = format.split('.').last;

    switch (formattedType.toUpperCase()) {
      case 'TV':
        return 'TV';
      case 'MOVIE':
        return 'FILM';
      case 'OVA':
        return 'OVA';
      case 'ONA':
        return 'ONA';
      case 'SPECIAL':
        return 'SPECIAL';
      default:
        return formattedType;
    }
  }

  String _formatStatus(String status) {
    final formattedStatus = status.split('.').last;

    switch (formattedStatus.toUpperCase()) {
      case 'FINISHED':
        return 'Completed';
      case 'RELEASING':
        return 'Airing';
      case 'NOT_YET_RELEASED':
        return 'Coming Soon';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return formattedStatus;
    }
  }
}
