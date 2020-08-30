import 'media_item.dart';

class MediaListResponse {
  int code;
  String status;
  List<MediaItem> mediaItems;

  MediaListResponse({this.code, this.status, this.mediaItems});

  MediaListResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    status = json['status'];
    if (json['data'] != null) {
      mediaItems = new List<MediaItem>();
      json['data'].forEach((v) {
        mediaItems.add(new MediaItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mediaItems = new Map<String, dynamic>();
    mediaItems['code'] = this.code;
    mediaItems['status'] = this.status;
    if (this.mediaItems != null) {
      mediaItems['data'] = this.mediaItems.map((v) => v.toJson()).toList();
    }
    return mediaItems;
  }
}
