import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shonenx/services/hive_service.dart';

final hiveServiceProvider = FutureProvider<HiveService>((ref) async {
  final service = HiveService();
  await service.init();
  ref.onDispose(() => service.dispose());
  return service;
});
