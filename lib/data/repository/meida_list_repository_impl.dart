import 'package:media_player/data/data_source/media_data_source.dart';
import 'package:media_player/data/model/media_item.dart';

import 'media_list_repository.dart';

class MediaListRepositoryImpl extends MediaListRepository {
  MediaDataSource _dataSource;

  MediaListRepositoryImpl(this._dataSource);

  @override
  Future<List<MediaItem>> getMediaList() {
    return _dataSource.getMediaList().then((value) => value.mediaItems);
  }
}
