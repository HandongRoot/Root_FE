import 'package:flutter/material.dart';
import 'package:root_app/components/navigationbar.dart';
import 'package:root_app/theme/theme.dart';
import 'add.dart';
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
        '/': (context) => HomeNavigation(), // album gallery 왔다갔다
        '/add': (context) => AddPage(),
        '/search': (context) => SearchPage(),
        '/my': (context) => MyPage(),
      },
    );
  }
}
