import 'dart:async';

import 'package:media_player/data/audio.dart';
import 'package:media_player/data/model/media_item.dart';
import 'package:media_player/data/player_observer.dart';
import 'package:media_player/data/repository/player_repository.dart';
import 'package:media_player/data/repository/player_states.dart';

class PlayerRepositoryImpl extends PlayerRepository with PlayerObserver {
  final _audioUrl = "http://server8.mp3quran.net/afs/";
  final _player = Audio.instance();
  final controller = StreamController<Status>();
  final durationController = StreamController<int>();
  final timeConroller = StreamController<int>();
  Stream<Status> get playerState => controller.stream;
  Stream<int> get duration => durationController.stream;
  Stream<int> get time => timeConroller.stream;

  @override
  Stream<Status> listenForPlayer() {
    return playerState;
  }

  @override
  Stream<int> listenForDuration() {
    return duration;
  }

  @override
  Future<void> play(MediaItem item) async {
    print("$_audioUrl/${item.number.toString().padLeft(3, "0")}.mp3");
    _player.play("$_audioUrl/${item.number.toString().padLeft(3, "0")}.mp3",
        title: item.englishName,
        subtitle: item.englishNameTranslation,
        position: Duration(seconds: 0),
        isLiveStream: false);
    listenForAudioPlayerEvents();
  }

  @override
  void pause() {
    _player.pause();
  }

  @override
  void onPause() {
    controller.sink.add(Status.paused);
  }

  @override
  void onPlay() {
    controller.sink.add(Status.playing);
  }

  @override
  void onComplete() {
    _player.reset();
    controller.sink.add(Status.stopped);
  }

  @override
  void onTime(int position) {
    timeConroller.add(position);
  }

  @override
  void onSeek(int position, double offset) {}

  @override
  void onDuration(int duration) {
    durationController.add(duration);
  }

  @override
  void onError(String error) {
    print(error);
  }
}
