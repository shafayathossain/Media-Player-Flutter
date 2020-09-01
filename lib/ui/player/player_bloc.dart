import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/data/model/media_item.dart';
import 'package:media_player/data/repository/player_repository.dart';
import 'package:media_player/data/repository/player_states.dart';
import 'package:media_player/ui/player/player_event.dart';
import 'package:media_player/ui/player/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final PlayerRepository _repository;

  PlayerBloc(this._repository) : super(null);
  StreamController<Status> playerStreamController = StreamController<Status>();
  Stream<Status> get playerStatus => playerStreamController.stream;

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    print(event);
    if (event is PlayEvent) {
      play(event.item);
    } else if (event is PauseEvent) {
      pause();
    } else if (event is ListenEvent) {
      listenForPlayer();
    }
  }

  void listenForPlayer() async {
    await for (Status status in _repository.listenForPlayer()) {
      print(status);
      playerStreamController.sink.add(status);
    }
  }

  void play(MediaItem item) async {
    await _repository.play(item);
  }

  void pause() {
    _repository.pause();
  }
}
