import 'package:media_player/data/model/media_item.dart';

class PlayerEvent {}

class PlayEvent extends PlayerEvent {
  MediaItem item;

  PlayEvent(this.item);
}

class PauseEvent extends PlayerEvent {}

class ListenEvent extends PlayerEvent {}

class ProgressEvent extends PlayerEvent {}

class DurationEvent extends PlayerEvent {}
