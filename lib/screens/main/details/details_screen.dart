import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nekoflow/data/models/info_model.dart';
import 'package:nekoflow/data/models/watchlist/watchlist_model.dart';
import 'package:nekoflow/data/services/anime_service.dart';
import 'package:nekoflow/screens/main/stream/stream_screen.dart';
import 'package:nekoflow/widgets/episodes_list.dart';
import 'package:nekoflow/widgets/favorite_button.dart';
import 'package:shimmer/shimmer.dart';

class DetailsScreen extends StatefulWidget {
  final String title;
  final String id;
  final String image;
  final String type;
  final dynamic tag;

  const DetailsScreen({
    super.key,
    required this.title,
    required this.id,
    required this.image,
    required this.tag,
    this.type = 'N/A',
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final ValueNotifier<bool> _isDescriptionExpanded = ValueNotifier(false);
  late final AnimeService _animeService = AnimeService();
  late final Box<WatchlistModel> _watchlistBox =
      Hive.box<WatchlistModel>('user_watchlist');
  final ScrollController _scrollController = ScrollController();
  ContinueWatchingItem? continueWatchingItem;
  AnimeData? info;
  String? error;

  Future<AnimeInfo?> fetchData() async {
    try {
      return await _animeService.fetchAnimeInfoById(id: widget.id);
    } catch (_) {
      setState(() => error = 'Network error occurred');
      return null;
    }
  }

  Future<void> _loadContnueWatching() async {
    final watchlist = _watchlistBox.get('continueWatching',
            defaultValue: WatchlistModel(continueWatching: [])) ??
        WatchlistModel(continueWatching: []);
    // continueWatchingItem = watchlist.continueWatching
    if (watchlist.continueWatching!.isNotEmpty) {
      try {
        continueWatchingItem = watchlist.continueWatching?.singleWhere(
          (item) => item.id == widget.id,
        );
      } catch (e) {
        continueWatchingItem =
            null; // Handle the case when no matching item is found
        print('Item not found: $e');
      }
    }
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 85.0),
      child: Stack(
        children: [
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color.fromARGB(255, 44, 41, 41),
                Colors.black.withOpacity(0.2),
                const Color.fromARGB(0, 178, 30, 30),
              ],
            ).createShader(rect),
            blendMode: BlendMode.srcATop,
            child: Hero(
              tag: 'poster-${widget.id}-${widget.tag}',
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 400,
                      color: Colors.grey[300],
                      child:
                          Icon(Icons.error, size: 50, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  shadows: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      offset: Offset(1, 2),
                      blurRadius: 10,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String label, String? value) {
    ThemeData themeData = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, style: themeData.textTheme.labelMedium),
          const SizedBox(height: 2),
          value == null
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[600]!,
                  child: Container(
                    margin: EdgeInsets.only(top: 3),
                    width: 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                )
              : Text(
                  value.isEmpty ? 'N/A' : value,
                  style: themeData.textTheme.labelMedium,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection({bool isLoading = false}) {
    ThemeData themeData = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildQuickInfoItem(Icons.timelapse, "Duration",
                isLoading ? null : info?.anime?.moreInfo?.duration),
            _buildQuickInfoItem(Icons.translate, "Japanese",
                isLoading ? null : info?.anime?.moreInfo?.japanese),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Details',
          style: themeData.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: _isDescriptionExpanded,
          builder: (_, isExpanded, __) {
            return AnimatedCrossFade(
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              firstChild: Text(
                info?.anime?.info?.description ?? 'Description not available',
                style: themeData.textTheme.bodyLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                info?.anime?.info?.description ?? 'Description not available',
                style: themeData.textTheme.bodyLarge,
              ),
            );
          },
        ),
        TextButton(
          onPressed: () =>
              _isDescriptionExpanded.value = !_isDescriptionExpanded.value,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isDescriptionExpanded,
            builder: (_, isExpanded, __) => Row(
              children: [
                Text(isExpanded ? 'Show Less' : 'Show More',
                    style: themeData.textTheme.bodyMedium),
                Icon(
                  Icons.arrow_drop_down,
                  size: 25,
                  color: themeData.iconTheme.color,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        EpisodesList(
          id: widget.id,
          title: widget.title,
          poster: widget.image,
          type: info?.anime?.info?.stats?.type ?? 'N/A',
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _loadContnueWatching();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isDescriptionExpanded.dispose();
    _animeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: themeData.colorScheme.primary,
      body: FutureBuilder<AnimeInfo?>(
        future: fetchData(),
        builder: (context, snapshot) {
          final bool isLoading =
              snapshot.connectionState == ConnectionState.waiting;
          info = snapshot.data?.data;

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: screenHeight * 0.6,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.navigate_before, size: 40),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderSection(),
                ),
                actions: [
                  FavoriteButton(
                    animeId: widget.id,
                    title: widget.title,
                    image: widget.image,
                    type: widget.type,
                  ),
                  const SizedBox(width: 10)
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: themeData.cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: _buildDetailsSection(isLoading: isLoading),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: continueWatchingItem == null
          ? SizedBox.shrink()
          : BottomAppBar(
              height: 100,
              color: Colors.transparent, // Make BottomAppBar transparent
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      50), // Clip to match container's rounded corners
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 5.0, sigmaY: 5.0), // Apply blur effect
                    child: Container(
                      color: themeData.secondaryHeaderColor.withOpacity(0.6),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        title: Text(
                          "EP : ${continueWatchingItem!.episode}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                             ),
                        ),
                        subtitle: Text(
                          continueWatchingItem!.name,
                          style: TextStyle(
                              ),
                          maxLines: 1,
                        ),
                        trailing: IconButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StreamScreen(
                                        title: widget.title,
                                        id: widget.id,
                                        episodeId:
                                            continueWatchingItem!.episodeId,
                                        poster: widget.image,
                                        episode:
                                            continueWatchingItem!.episode))),
                            icon: Icon(
                              Icons.play_circle,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}