import 'package:shonenx/core/models/anilist/anilist_media_list.dart';
import 'package:shonenx/core/repositories/anime_repository.dart';

class MalRepository implements AnimeRepository {
  // final MalService service;

  // MalRepository(this.service);

  @override
  Future<List<Media>> searchAnime(String title,
      {int page = 1, int perPage = 10}) {
    // TODO: implement getAnimeDetails
    throw UnimplementedError();
  }

  @override
  Future<Media> getAnimeDetails(int animeId) {
    // TODO: implement getAnimeDetails
    throw UnimplementedError();
  }

  @override
  Future<List<Media>> getFavorites() {
    // TODO: implement getFavorites
    throw UnimplementedError();
  }

  @override
  Future<List<Media>> getPopularAnime() {
    // TODO: implement getPopularAnime
    throw UnimplementedError();
  }

  @override
  Future<List<Media>> getRecentlyUpdatedAnime() {
    // TODO: implement getRecentlyUpdatedAnime
    throw UnimplementedError();
  }

  @override
  Future<List<Media>> getTopRatedAnime() {
    // TODO: implement getTopRatedAnime
    throw UnimplementedError();
  }

  @override
  Future<List<Media>> getTrendingAnime() {
    // TODO: implement getTrendingAnime
    throw UnimplementedError();
  }

  @override
  Future<List<Media>> getUpcomingAnime() {
    // TODO: implement getUpcomingAnime
    throw UnimplementedError();
  }

  @override
  Future<MediaListCollection> getUserAnimeList(
      {required String type, required String status}) {
    // TODO: implement getUserAnimeList
    throw UnimplementedError();
  }

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();
}
