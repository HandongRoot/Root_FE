import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:html/parser.dart' as htmlParser; // 추가
import 'package:root_app/components/navbar.dart';
import 'package:root_app/folder.dart';
import 'package:root_app/login.dart';
import 'package:root_app/modals/contentListPage/change_modal.dart';
import 'package:root_app/theme/theme.dart';
import 'search_page.dart';
import 'my_page.dart';

final String userId = '8a975eeb-56d1-4832-9d2f-5da760247dda';
const platform = MethodChannel('com.example.root_app/share');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(MyApp());

  platform.setMethodCallHandler(handleSharedData);
}

Future<void> handleSharedData(MethodCall call) async {
  if (call.method == "sharedText") {
    final String sharedUrl = call.arguments.trim();
    print("최종 공유된 링크: $sharedUrl");

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
    } else if (sharedUrl.startsWith('http')) {
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
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
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

      // 🔹 썸네일이 없을 경우 기본 이미지 제공
      if (thumbnail.isEmpty) {
        thumbnail = "https://example.com/default-thumbnail.png"; // 기본 썸네일
      }

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
    body: jsonEncode({"title": title, "thumbnail": thumbnail, "linkedUrl": linkedUrl}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('공유 데이터 업로드 성공 🎉');
  } else {
    print('공유 데이터 업로드 실패: ${response.statusCode}');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844),
      builder: (context, child) {
        return MaterialApp(
          title: 'Root',
          theme: appTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => NavBar(userId: userId),
            '/search': (context) => SearchPage(),
            '/signin': (context) => Login(),
            '/folder': (context) => Folder(onScrollDirectionChange: (_) {}),
            '/changeModal': (context) => ChangeModal(
                content: (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?)?['content']),
          },
        );
      },
    );
  }
}
