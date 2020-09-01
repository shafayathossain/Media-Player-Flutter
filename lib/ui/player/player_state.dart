import 'package:media_player/data/model/media_item.dart';
import 'package:media_player/data/repository/player_states.dart';

class PlayerState {
  Status playerStatus;
  MediaItem item;

  PlayerState(this.playerStatus, this.item);
}
