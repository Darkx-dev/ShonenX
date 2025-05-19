import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer';
import 'package:shonenx/core/models/anime/anime_model.dep.dart';
import 'package:shonenx/core/models/anime/episode_model.dart';
import 'package:shonenx/core/models/anime/page_model.dart';
import 'package:shonenx/core/models/anime/server_model.dart';
import 'package:shonenx/core/models/anime/source_model.dart';
import 'package:shonenx/core/sources/anime/anime_provider.dart';
import 'package:http/http.dart' as http;

class AnimekaiProvider extends AnimeProvider {
  AnimekaiProvider({String? customApiUrl})
      : super(
            apiUrl: customApiUrl != null
                ? '$customApiUrl/anime/animekai'
                : "${dotenv.env['API_URL']}/anime/animekai",
            baseUrl: 'https://animekai.to/',
            providerName: 'animekai');

  // Map<String, String> _getHeaders() {
  //   return {
  //     'User-Agent':
  //         'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36',
  //   };
  // }

  @override
  Future<HomePage> getHome() {
    // TODO: implement getHome
    throw UnimplementedError();
  }

  @override
  Future<DetailPage> getDetails(String animeId) {
    // TODO: implement getDetails
    throw UnimplementedError();
  }

  @override
  Future<BaseEpisodeModel> getEpisodes(String animeId) async {
    final response = await http.get(Uri.parse('$apiUrl/info?id=$animeId'));
    final data = jsonDecode(response.body);
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
    // TODO: implement getWatch
    throw UnimplementedError();
  }

  @override
  Future<WatchPage> getWatch(String animeId) {
    // TODO: implement getWatch
    throw UnimplementedError();
  }

  @override
  Future<SearchPage> getPage(String route, int page) {
    // TODO: implement getPage
    throw UnimplementedError();
  }

  @override
  Future<SearchPage> getSearch(String keyword, String? type, int page) async {
    log("Searching for $keyword");
    final response = await http.get(Uri.parse('$apiUrl/$keyword'));
    // log(response.body);
    final data = jsonDecode(response.body);
    log("${(data['results'] as List<dynamic>).map(
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
        ).toList()[0].name}");
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
    log('Fetching : ${'$apiUrl/watch/$episodeId?dub=$dub'}');
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
      log(data.toString());
      return BaseSourcesModel(
        sources: (data['sources'] as List<dynamic>)
            .map((source) => Source(
                  url: source['url'],
                  isM3U8: source['isM3U8'],
                ))
            .toList(),
      );
    } catch (e) {
      log('Error in getSources: $e', level: 1000);
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
