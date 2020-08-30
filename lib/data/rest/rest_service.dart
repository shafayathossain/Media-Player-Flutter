import 'package:dio/dio.dart';
import 'package:media_player/data/dio_factory.dart';

class RestService {
  final DioFactory _dioFactory;

  RestService(this._dioFactory);

  Future<Response> getMediaList() {
    return _dioFactory.getDio().get("http://api.alquran.cloud/v1/surah");
  }
}
