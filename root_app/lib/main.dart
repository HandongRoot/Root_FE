import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:root_app/controllers/folder_controller.dart';
import 'package:root_app/routes/root_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:root_app/navbar.dart';
import 'package:root_app/screens/folder/folder.dart';
import 'package:root_app/screens/login/login.dart';
import 'package:root_app/screens/my_page/delete_page.dart';
import 'package:root_app/screens/search/search_page.dart';
import 'package:root_app/theme/theme.dart';
import 'package:root_app/modals/shared_modal.dart';

export 'package:root_app/main.dart';
import 'package:root_app/services/navigation_service.dart';

const platform = MethodChannel('com.example.root_app/share');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY'],
    loggingEnabled: true,
  );

  final storage = FlutterSecureStorage();
  final accessToken = await storage.read(key: 'access_token');

  final isLoggedIn = accessToken != null && accessToken.isNotEmpty;

  final prefs = await SharedPreferences.getInstance();
  final isFirstTimeGallery = prefs.getBool('isFirstTimeGallery') ?? true;
  final isFirstTimeFolder = prefs.getBool('isFirstTimeFolder') ?? true;

  //print("✅ Access token: $accessToken");
  //print("✅ Is logged in? $isLoggedIn");

  Get.put(FolderController());

  runApp(MyApp(
      isFirstTimeGallery: isFirstTimeGallery,
      isFirstTimeFolder: isFirstTimeFolder,
      isLoggedIn: isLoggedIn));
}

class SharedModalEntryApp extends StatelessWidget {
  const SharedModalEntryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Builder(
        builder: (context) {
          platform.setMethodCallHandler((call) async {
            if (call.method == "sharedText") {
              final sharedUrl = call.arguments.toString();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => SharedModal(sharedUrl: sharedUrl),
              );
            }
          });
          return const Scaffold();
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isFirstTimeFolder;
  final bool isFirstTimeGallery;
  final bool isLoggedIn;

  const MyApp(
      {super.key,
      required this.isFirstTimeFolder,
      required this.isFirstTimeGallery,
      required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return GetMaterialApp(
          navigatorKey: navigatorKey,
          title: 'Root',
          theme: AppTheme.appTheme,
          debugShowCheckedModeBanner: false,
          home: RootRouter(isLoggedIn: isLoggedIn),
          getPages: [
            GetPage(name: '/login', page: () => const Login()),
            GetPage(name: '/home', page: () => const NavBar()),
            GetPage(name: '/search', page: () => SearchPage()),
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

class TestTokenButtonPage extends StatelessWidget {
  const TestTokenButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MethodChannel 테스트")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            const platform = MethodChannel('com.example.root_app/share');
            final testToken = "flutter_test_token";

            try {
              //print("👉 Flutter에서 saveAccessToken 호출 시도");
              await platform.invokeMethod('saveAccessToken', testToken);
              //print("✅ Flutter에서 saveAccessToken 호출 성공");
            } catch (e) {
              //print("❌ Flutter에서 saveAccessToken 호출 실패: $e");
            }
          },
          child: const Text("App Group 토큰 수동 저장"),
        ),
      ),
    );
  }
}

Future<void> resetFirstTimeFlag() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isFirstTimeGallery');
  await prefs.remove('isFirstTimeFolder');
  //print("Tutorial reset complete.");
}

Future<void> handleSharedData(MethodCall call) async {
  if (call.method == "sharedText") {
    final String sharedUrl = call.arguments.trim();
    //print("✅ 공유된 링크: $sharedUrl");

    String? videoId = extractYouTubeId(sharedUrl);
    String title = '';
    String thumbnail = '';

    if (videoId != null) {
      final videoData = await fetchYoutubeVideoData(videoId);
      title = videoData?['title'] ?? 'YouTube 영상';
      thumbnail = videoData?['thumbnail'] ??
          'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
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
    if (match != null && match.groupCount >= 1) return match.group(1);
  }
  return null;
}

Future<Map<String, dynamic>?> fetchYoutubeVideoData(String videoId) async {
  final apiKey = dotenv.env['YOUTUBE_API_KEY'];
  final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/videos?id=$videoId&key=$apiKey&part=snippet');

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
    //print('YouTube API 호출 실패: ${response.statusCode}');
  }
  return null;
}

Future<Map<String, String>?> fetchWebPageData(String url) async {
  try {
    if (url.contains("m.blog.naver.com") || url.contains("blog.naver.com")) {
      url = url.replaceAll("m.blog.naver.com", "blog.naver.com");
    }

    final response = await http.get(Uri.parse(url), headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
    });

    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);
      final metaTags = document.getElementsByTagName('meta');

      String title = '';
      String thumbnail = '';

      for (var meta in metaTags) {
        final property = meta.attributes['property'] ?? meta.attributes['name'];
        final content = meta.attributes['content'];
        if (property == 'og:title' && content != null) title = content;
        if (property == 'og:image' && content != null) thumbnail = content;
      }

      if (thumbnail.isNotEmpty && !thumbnail.startsWith('http')) {
        Uri uri = Uri.parse(url);
        thumbnail = '${uri.scheme}://${uri.host}$thumbnail';
      }

      if (title.isEmpty) {
        final titleElement = document.getElementsByTagName('title');
        if (titleElement.isNotEmpty) title = titleElement.first.text.trim();
      }

      if (thumbnail.isEmpty && url.contains("blog.naver.com")) {
        final imageElement = document.querySelector('img.se-image');
        if (imageElement != null) {
          thumbnail = imageElement.attributes['src'] ?? '';
        }
      }

      if (thumbnail.isEmpty) {
        thumbnail =
            "https://ssl.pstatic.net/static/pwe/address/img_profile.png";
      }

      return {'title': title, 'thumbnail': thumbnail};
    } else {
      //print('🚨 웹페이지 로딩 실패: ${response.statusCode}');
    }
  } catch (e) {
    //print('🚨 웹페이지 파싱 중 오류 발생: $e');
  }
  return null;
}

Future<void> sendSharedDataToBackend(
    String title, String thumbnail, String linkedUrl) async {
  final String? baseUrl = dotenv.env['BASE_URL'];
  if (baseUrl == null) return;

  final storage = const FlutterSecureStorage();
  final accessToken = await storage.read(key: 'access_token');
  if (accessToken == null) return;

  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/content'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode(
        {"title": title, "thumbnail": thumbnail, "linkedUrl": linkedUrl}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    //print('공유 데이터 업로드 성공 🎉');
  } else {
    //print('공유 데이터 업로드 실패: ${response.statusCode}');
  }
}
