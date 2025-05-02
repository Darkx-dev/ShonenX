import 'package:shonenx/data/hive/boxes/anime_watch_progress_box.dart';
import 'package:shonenx/data/hive/boxes/settings_box.dart';

// Custom exception for uninitialized Hive boxes
class UninitializedHiveBoxException implements Exception {
  final String message;
  UninitializedHiveBoxException(this.message);

  @override
  String toString() => 'UninitializedHiveBoxException: $message';
}

class HiveService {
  AnimeWatchProgressBox? _animeWatchProgressBox;
  SettingsBox? _settingsBox;

  Future<void> init() async {
    try {
      _animeWatchProgressBox = AnimeWatchProgressBox();
      await _animeWatchProgressBox!.init();

      _settingsBox = SettingsBox();
      await _settingsBox!.init();

    } catch (e) {
      throw HiveInitializationException('Failed to initialize Hive boxes: $e');
    }
  }

  void dispose() {
    _animeWatchProgressBox?.close();
    _settingsBox?.close();
  }

  AnimeWatchProgressBox get progress {
    if (_animeWatchProgressBox == null) {
      throw UninitializedHiveBoxException('AnimeWatchProgressBox not initialized');
    }
    return _animeWatchProgressBox!;
  }

  SettingsBox get settings {
    if (_settingsBox == null) {
      throw UninitializedHiveBoxException('SettingsBox not initialized');
    }
    return _settingsBox!;
  }
}

// Custom exception for initialization failures
class HiveInitializationException implements Exception {
  final String message;
  HiveInitializationException(this.message);

  @override
  String toString() => 'HiveInitializationException: $message';
}