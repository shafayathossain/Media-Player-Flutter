import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_player/data/repository/media_list_repository.dart';
import 'package:media_player/ui/media_list/media_event.dart';
import 'package:media_player/ui/media_list/media_state.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  MediaListRepository _repository;

  MediaBloc(this._repository) : super(null);

  @override
  Stream<MediaState> mapEventToState(MediaEvent event) async* {
    if (event is MediaEvent) {
      yield* _getMediaList();
    }
  }

  Stream<MediaState> _getMediaList() async* {
    yield* Stream.value(LoadingState());
    final response = await _repository.getMediaList();
    yield* Stream.value(MediaListState(response));
    yield* Stream.value(LoadedState());
  }
}
