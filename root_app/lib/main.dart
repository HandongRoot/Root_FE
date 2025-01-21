import 'package:flutter/material.dart';
import 'package:root_app/components/navbar.dart';
import 'package:root_app/theme/theme.dart';
import 'search_page.dart';
import 'my_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Root',
      theme: appTheme,
      debugShowCheckedModeBanner: false, // 거슬리는 debug banner 지우는 코드
      initialRoute: '/',
      routes: {
        '/': (context) => NavBar(), // folder gallery 페이지들 왔다갔다
        '/search': (context) => SearchPage(),
        '/my': (context) => MyPage(),
      },
    );
  }
}
