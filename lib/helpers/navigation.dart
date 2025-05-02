import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shonenx/core/models/anilist/anilist_media_list.dart';

void navigateToDetail(BuildContext context, Media media, String tag) {
  context.push('/details?tag=$tag', extra: media);
}
