// utils/url_converter.dart

//TODO: youtube 이랑 유투브 쇼츠만 변환하도록 설정함.. 다른거 다 설정 하거나 방법 찾아봐야함.
String getThumbnailFromUrl(String url) {
  String? videoId =
      getIdFromUrl(url); // Extract video ID from YouTube or YouTube Shorts

  if (videoId != null) {
    // Return thumbnail URL
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  } else {
    // Handle non-YouTube URLs or invalid URLs
    return url;
  }
}

String? getIdFromUrl(String url) {
  // Updated regex to handle both regular YouTube videos and YouTube Shorts
  RegExp regExp = RegExp(
      r'(?:(?:https?:)?\/\/)?(?:www\.)?(?:youtube\.com\/(?:watch\?v=|shorts\/|embed\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})');

  var match = regExp.firstMatch(url);
  return match?.group(1); // Return the extracted video ID, if matched
}
