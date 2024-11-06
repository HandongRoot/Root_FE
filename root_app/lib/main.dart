import 'package:flutter/material.dart';
import 'home_navigation.dart';
import 'add.dart';
import 'search_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Root',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false, // 거슬리는 debug banner 지우는 코드
      initialRoute: '/',
      routes: {
        '/': (context) => HomeNavigation(), // home gallery 왔다갔다
        '/add': (context) => AddPage(),
        '/search': (context) => SearchPage(),
      },
    );
  }
}
