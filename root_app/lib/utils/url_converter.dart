// utils/url_converter.dart

//TODO: 유투브 한정이라.. 인스타그램이랑 다른 어플들도 해봐야할듯..
String getThumbnailFromUrl(String url) {
  String? videoId = getIdFromUrl(url); // extract youtube url

  if (videoId != null) {
    // Return thumbnail URL
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  } else {
    // 유툽 영상 아닌 url handling
    return url;
  }
}

String? getIdFromUrl(String url) {
  RegExp regExp = RegExp(
      r'(?:(?:https?:)?\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})');
  var match = regExp.firstMatch(url);
  return match?.group(1);
}
