import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:root_app/components/navbar.dart';
import 'package:root_app/theme/theme.dart';
import 'search_page.dart';
import 'my_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(390, 844), // figma iphne 13 size
      builder: (context, child) {
        return MaterialApp(
          title: 'Root',
          theme: appTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => NavBar(),
            '/search': (context) => SearchPage(),
            '/my': (context) => MyPage(),
          },
        );
      },
    );
  }
}
