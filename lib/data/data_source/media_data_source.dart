import 'package:media_player/data/model/media_list_response.dart';
import 'package:media_player/data/rest/rest_service.dart';

class MediaDataSource {
  RestService _restService;

  MediaDataSource(this._restService);

  Future<MediaListResponse> getMediaList() {
    return _restService.getMediaList().then((value) {
      if (value.statusCode >= 200 && value.statusCode <= 399) {
        return MediaListResponse.fromJson(value.data);
      } else {
        throw Exception(["Request error"]);
      }
    });
  }
}
