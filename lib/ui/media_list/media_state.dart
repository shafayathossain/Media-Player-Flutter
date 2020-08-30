import 'package:media_player/data/model/media_item.dart';

class MediaState {}

class MediaListState extends MediaState {
  List<MediaItem> mediaItems;

  MediaListState(this.mediaItems);
}

class LoadingState extends MediaState {}

class LoadedState extends MediaState {}
