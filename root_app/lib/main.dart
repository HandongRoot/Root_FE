import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:root_app/components/navbar.dart';
import 'package:root_app/theme/theme.dart';
import 'search_page.dart';
import 'my_page.dart'; // Import the modified MyPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(MyApp());
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
                showMyPageModal(context);
                return const SizedBox.shrink();
              });
            }
            return null;
          },
          routes: {
            '/': (context) => NavBar(),
            '/search': (context) => SearchPage(),
          },
        );
      },
    );
  }
}
