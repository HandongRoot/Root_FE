import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:receive_sharing_intent/receive_sharing_intent.dart'; // 🔹 추가
import 'package:root_app/screens/login/tutorial.dart';
import 'package:root_app/screens/my_page/delete_page.dart';
import 'package:root_app/widgets/navbar.dart';
import 'package:root_app/screens/folder.dart';
import 'package:root_app/screens/login/login.dart';
import 'package:root_app/screens/search_page.dart';
import 'package:root_app/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String userId = '8a975eeb-56d1-4832-9d2f-5da760247dda';
const platform = MethodChannel('com.example.root_app/share');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatefulWidget {
  final bool isFirstTime;
  const MyApp({Key? key, required this.isFirstTime}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentSub;
  List<SharedMediaFile> _sharedFiles = [];

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(handleSharedData);
    _showGalleryTutorialIfNeeded();

    // 🔹 receive_sharing_intent 설정
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        setState(() {
          _sharedFiles = value;
          _processSharedData();
        });
      },
      onError: (err) {
        print("🚨 공유 데이터 스트림 오류: $err");
      },
    );

    // 🔹 앱이 처음 실행될 때 공유 데이터 확인
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles = value;
        _processSharedData();
      });

      // 📌 공유 데이터 처리 완료 후 리셋
      ReceiveSharingIntent.instance.reset();
    });
  }

  /// 🔹 공유된 데이터를 처리하는 함수
  void _processSharedData() {
    if (_sharedFiles.isNotEmpty) {
      for (var file in _sharedFiles) {
        if (file.type == SharedMediaType.text || file.path.contains("http")) {
          handleSharedData(MethodCall("sharedText", file.path));
        }
      }
    }
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  Future<void> _showGalleryTutorialIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      Future.delayed(Duration(milliseconds: 500), () {
        Get.dialog(GalleryTutorial(), barrierColor: Colors.transparent);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Root',
          theme: AppTheme.appTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => NavBar(userId: userId)),
            GetPage(name: '/search', page: () => SearchPage()),
            GetPage(name: '/signin', page: () => Login()),
            GetPage(
                name: '/folder',
                page: () => Folder(onScrollDirectionChange: (_) {})),
            GetPage(name: '/delete', page: () => DeletePage()),
          ],
        );
      },
    );
  }
}

Future<void> resetFirstTimeFlag() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isFirstTime'); //  ㅋㅋ 테스트용
  print("ifFristTime 리셋띠띠 shift R 하면 또 보임 ");
}

Future<void> handleSharedData(MethodCall call) async {
  if (call.method == "sharedText") {
    final String sharedUrl = call.arguments.trim();
    print("✅ 공유된 링크: $sharedUrl");

    String? videoId = extractYouTubeId(sharedUrl);
    String title = '';
    String thumbnail = '';

    if (videoId != null) {
      final videoData = await fetchYoutubeVideoData(videoId);
      if (videoData != null) {
        title = videoData['title'] ?? 'YouTube 영상';
        thumbnail = videoData['thumbnail'] ?? '';
      } else {
        thumbnail = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
        title = 'YouTube 영상';
      }
    } else if (sharedUrl.contains('naver.com') ||
        sharedUrl.startsWith('http')) {
      final pageData = await fetchWebPageData(sharedUrl);
      title = pageData?['title'] ?? '제목 없음';
      thumbnail = pageData?['thumbnail'] ?? '';
    } else {
      title = sharedUrl;
    }

    await sendSharedDataToBackend(title, thumbnail, sharedUrl);
  }
}

String? extractYouTubeId(String url) {
  final patterns = [
    RegExp(r'youtube\.com\/shorts\/([0-9A-Za-z_-]{11})'),
    RegExp(r'youtu\.be\/([0-9A-Za-z_-]{11})'),
    RegExp(r'youtube\.com\/watch\?v=([0-9A-Za-z_-]{11})'),
  ];

  for (final regExp in patterns) {
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
  }
  return null;
}

Future<Map<String, dynamic>?> fetchYoutubeVideoData(String videoId) async {
  final apiKey = dotenv.env['YOUTUBE_API_KEY'];
  final url = Uri.parse(
    'https://www.googleapis.com/youtube/v3/videos?id=$videoId&key=$apiKey&part=snippet',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['items'] != null && data['items'].isNotEmpty) {
      final snippet = data['items'][0]['snippet'];
      return {
        'title': snippet['title'],
        'thumbnail': snippet['thumbnails']['high']['url'],
      };
    }
  } else {
    print('YouTube API 호출 실패: ${response.statusCode}');
  }
  return null;
}

Future<Map<String, String>?> fetchWebPageData(String url) async {
  try {
    // 네이버 블로그 및 모바일 페이지를 고려하여 URL 변환
    if (url.contains("m.blog.naver.com") || url.contains("blog.naver.com")) {
      url = url.replaceAll("m.blog.naver.com", "blog.naver.com");
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
      },
    );

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final metaTags = document.getElementsByTagName('meta');

      String title = '';
      String thumbnail = '';

      for (var meta in metaTags) {
        final property = meta.attributes['property'] ?? meta.attributes['name'];
        final content = meta.attributes['content'];

        if (property == 'og:title' && content != null) {
          title = content;
        }
        if (property == 'og:image' && content != null) {
          thumbnail = content;
        }
      }

      // 🔹 썸네일 URL 보완 (상대 경로 처리)
      if (thumbnail.isNotEmpty && !thumbnail.startsWith('http')) {
        Uri uri = Uri.parse(url);
        thumbnail = '${uri.scheme}://${uri.host}$thumbnail';
      }

      // 🔹 제목이 없을 경우 <title> 태그에서 가져오기
      if (title.isEmpty) {
        final titleElement = document.getElementsByTagName('title');
        if (titleElement.isNotEmpty) {
          title = titleElement.first.text.trim();
        }
      }

      // 🔹 네이버 블로그 특정 처리 (대표 이미지가 있을 경우 가져오기)
      if (thumbnail.isEmpty && url.contains("blog.naver.com")) {
        final imageElement = document.querySelector('img.se-image');
        if (imageElement != null) {
          thumbnail = imageElement.attributes['src'] ?? '';
        }
      }

      // 🔹 썸네일이 없을 경우 기본 이미지 제공
      if (thumbnail.isEmpty) {
        thumbnail =
            "https://ssl.pstatic.net/static/pwe/address/img_profile.png"; // 네이버 기본 썸네일
      }

      print("📌 최종 제목: $title");
      print("📌 최종 썸네일: $thumbnail");

      return {'title': title, 'thumbnail': thumbnail};
    } else {
      print('🚨 웹페이지 로딩 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('🚨 웹페이지 파싱 중 오류 발생: $e');
  }
  return null;
}

Future<void> sendSharedDataToBackend(
    String title, String thumbnail, String linkedUrl) async {
  final String? BASE_URL = dotenv.env['BASE_URL'];
  if (BASE_URL == null) {
    print("BASE_URL이 .env 파일에 설정되지 않았습니다.");
    return;
  }

  final response = await http.post(
    Uri.parse('$BASE_URL/api/v1/content/$userId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(
        {"title": title, "thumbnail": thumbnail, "linkedUrl": linkedUrl}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('공유 데이터 업로드 성공 🎉');
  } else {
    print('공유 데이터 업로드 실패: ${response.statusCode}');
  }
}
