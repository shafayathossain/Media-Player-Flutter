import 'package:media_player/data/model/media_item.dart';

import 'player_states.dart';

abstract class PlayerRepository {
  Stream<Status> listenForPlayer();

  Stream<List<int>> listenForProgress();

  Stream<int> listenForDuration();

  Future<void> play(MediaItem item);

  MediaItem getMediaItem();

  void pause();
}
