import 'package:media_player/data/model/media_item.dart';

abstract class MediaListRepository {
  Future<List<MediaItem>> getMediaList();
}
