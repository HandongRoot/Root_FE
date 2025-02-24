import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // MethodChannel을 사용하기 위해 추가
import 'package:root_app/components/navbar.dart';
import 'package:root_app/folder.dart';
import 'package:root_app/login.dart';
import 'package:root_app/modals/contentListPage/change_modal.dart';
import 'package:root_app/theme/theme.dart';
import 'search_page.dart';
import 'my_page.dart';

// TODO 임시
final String userId = '8a975eeb-56d1-4832-9d2f-5da760247dda';

// MethodChannel 정의 (네이티브에서 Flutter로 데이터를 받기 위한 채널)
const platform = MethodChannel('com.example.root_app/share');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  runApp(MyApp());

  // 공유 데이터 수신을 위한 MethodChannel 핸들러 등록 (중요 추가사항)
  platform.setMethodCallHandler(handleSharedData);
}

// 공유 데이터를 처리하는 핸들러 함수 (중요 추가사항)
Future<void> handleSharedData(MethodCall call) async {
  if (call.method == "sharedText") {
    final String sharedText = call.arguments;
    await sendSharedDataToBackend(sharedText);
  }
}

// 백엔드로 데이터를 보내는 함수 (중요 추가사항)
Future<void> sendSharedDataToBackend(String sharedText) async {
  final String? BASE_URL = dotenv.env['BASE_URL'];
  if (BASE_URL == null) {
    print("BASE_URL이 .env 파일에 설정되지 않았습니다.");
    return;
  }

  final response = await http.post(
    Uri.parse('$BASE_URL/api/v1/content/$userId'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "title": "공유된 콘텐츠",
      "thumbnail": "",  // 추후 썸네일 URL 추가 가능
      "linkedUrl": sharedText,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('공유 데이터 업로드 성공');
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
          onGenerateRoute: (settings) {
            if (settings.name == '/my') {
              return MaterialPageRoute(builder: (context) {
                showMyPageModal(context, userId: userId);
                return const SizedBox.shrink();
              });
            }
            return null;
          },
          routes: {
            '/': (context) => NavBar(userId: userId),
            '/search': (context) => SearchPage(),
            '/signin': (context) => Login(),
            '/folder': (context) => Folder(onScrollDirectionChange: (_) {}),
            '/changeModal': (context) {
              final args = ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
              return ChangeModal(content: args?['content']);
            },
          },
        );
      },
    );
  }
}
