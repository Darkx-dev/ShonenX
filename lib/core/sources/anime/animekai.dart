import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shonenx/core/models/anime/anime_model.dep.dart';
import 'package:shonenx/core/models/anime/episode_model.dart';
import 'package:shonenx/core/models/anime/page_model.dart';
import 'package:shonenx/core/models/anime/server_model.dart';
import 'package:shonenx/core/models/anime/source_model.dart';
import 'package:shonenx/core/sources/anime/anime_provider.dart';
import 'package:shonenx/core/utils/app_logger.dart';
import 'package:http/http.dart' as http;

class AnimekaiProvider extends AnimeProvider {
  AnimekaiProvider({String? customApiUrl})
      : super(
            apiUrl: customApiUrl != null
                ? '$customApiUrl/anime/animekai'
                : "${dotenv.env['API_URL']}/anime/animekai",
            baseUrl: 'https://animekai.to/',
            providerName: 'animekai');

  @override
  Future<HomePage> getHome() {
    throw UnimplementedError();
  }

  @override
  Future<DetailPage> getDetails(String animeId) {
    throw UnimplementedError();
  }

  @override
  Future<BaseEpisodeModel> getEpisodes(String animeId) async {
    AppLogger.d('Fetching episodes for animeId: $animeId');
    final response = await http.get(Uri.parse('$apiUrl/info?id=$animeId'));
    final data = jsonDecode(response.body);
    AppLogger.d('Received episodes data for animeId: $animeId');
    return BaseEpisodeModel(
        totalEpisodes: data['totalEpisodes'],
        episodes: (data['episodes'] as List<dynamic>)
            .map((episode) => EpisodeDataModel(
                id: episode['id'],
                number: episode['number'],
                title: episode['title'],
                isFiller: episode['isFiller'],
                url: episode['url']))
            .toList());
  }

  @override
  Future<BaseServerModel> getServers(String episodeId) async {
    throw UnimplementedError();
  }

  @override
  Future<WatchPage> getWatch(String animeId) {
    throw UnimplementedError();
  }

  @override
  Future<SearchPage> getPage(String route, int page) {
    throw UnimplementedError();
  }

  @override
  Future<SearchPage> getSearch(String keyword, String? type, int page) async {
    AppLogger.d('Searching for keyword: $keyword, type: $type, page: $page');
    final response = await http.get(Uri.parse('$apiUrl/$keyword'));
    final data = jsonDecode(response.body);
    AppLogger.d('Search results for $keyword: ${data['results'].length} items');
    return SearchPage(
        totalPages: data['totalPages'],
        currentPage: data['cucurrentPage'],
        results: (data['results'] as List<dynamic>)
            .map(
              (anime) => BaseAnimeModel(
                id: anime['id'],
                name: anime['title'],
                url: anime['url'],
                jname: anime['japaneseTitle'],
                type: anime['type'],
                episodes: EpisodesModel(
                  sub: anime['sub'],
                  dub: anime['dub'],
                  total: anime['sub'],
                ),
                poster: anime['image'],
              ),
            )
            .toList());
  }

  @override
  Future<BaseSourcesModel> getSources(
    String animeId,
    String episodeId,
    String? serverName,
    String? category,
  ) async {
    final dub = category == 'dub' ? 1 : 0;
    AppLogger.d('Fetching sources for animeId: $animeId, episodeId: $episodeId, dub: $dub');
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/watch/$episodeId?dub=$dub'));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch sources: HTTP ${response.statusCode}');
      }
      final jsonString = response.body;
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (!data.containsKey('sources')) {
        throw Exception('API response missing "sources" key');
      }
      AppLogger.d('Received sources for episodeId: $episodeId');
      return BaseSourcesModel(
        sources: (data['sources'] as List<dynamic>)
            .map((source) => Source(
                  url: source['url'],
                  isM3U8: source['isM3U8'],
                ))
            .toList(),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching sources for episodeId: $episodeId', e, stackTrace);
      rethrow; // Propagate the error to the caller (e.g., WatchScreen)
    }
  }

  @override
  List<String> getSupportedServers() {
    return ["vidcloud", "streamsb", "vidstreaming", "streamtape"];
  }

  @override
  bool getDubSubParamSupport() {
    return true;
  }
}