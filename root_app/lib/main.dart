import 'package:flutter/material.dart';
import 'home_navigation.dart';
import 'add.dart';
import 'search_page.dart';

void main() {
  runApp(MyApp()); // 앱 돌릴떄 여기서 시작함
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // 거슬리는 debug banner 지우는 코드
      initialRoute: '/', // Default route
      routes: {
        '/': (context) =>
            HomeNavigation(), // HomeNavigation will manage switching between HomePage and GalleryPage
        '/add': (context) => AddPage(),
        '/search': (context) => SearchPage(),
      },
    );
  }
}
