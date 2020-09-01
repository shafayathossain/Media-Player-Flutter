import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/data/model/media_item.dart';
import 'package:media_player/data/repository/player_repository.dart';
import 'package:media_player/data/repository/player_states.dart';
import 'package:media_player/ui/player/player_event.dart';
import 'package:media_player/ui/player/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final PlayerRepository _repository;
  static PlayerBloc bloc;
  static Status lastStatus = Status.stopped;
  StreamController<PlayerState> playerStreamController =
      StreamController<PlayerState>.broadcast();
  Stream<PlayerState> get playerStatus => playerStreamController.stream;

  StreamController<List<double>> playerProgressController =
      StreamController<List<double>>.broadcast();
  Stream<List<double>> get playerProgress => playerProgressController.stream;

  StreamController<int> playerDurationController =
      StreamController<int>.broadcast();
  Stream<int> get playerDuration => playerDurationController.stream;

  factory PlayerBloc(repository) {
    return bloc ??= PlayerBloc._internal(repository);
  }

  PlayerBloc._internal(this._repository) : super(null);

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    print(event);
    if (event is PlayEvent) {
      play(event.item);
    } else if (event is PauseEvent) {
      pause();
    } else if (event is ListenEvent) {
      listenForPlayer();
    } else if (event is ProgressEvent) {
      listenForProgress();
    } else if (event is DurationEvent) {
      listenForDuration();
    }
  }

  void listenForPlayer() async {
    if (_repository.getMediaItem() != null) {
      playerStreamController.sink
          .add(PlayerState(lastStatus, _repository.getMediaItem()));
    }
    _repository.listenForPlayer().listen((status) {
      lastStatus = status;
      playerStreamController.sink
          .add(PlayerState(status, _repository.getMediaItem()));
    });
  }

  void listenForProgress() async {
    await for (List<int> progress in _repository.listenForProgress()) {
      playerProgressController.sink.add(
          (progress.map((e) => e.toDouble()).toList()
            ..add(progress[1] / (progress[0]))));
    }
  }

  void listenForDuration() async {
    await for (int duration in _repository.listenForDuration()) {
      playerDurationController.sink.add(duration);
    }
  }

  void play(MediaItem item) async {
    await _repository.play(item);
  }

  void pause() {
    _repository.pause();
  }
}
