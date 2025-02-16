import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:root_app/components/navbar.dart';
import 'package:root_app/folder.dart';
import 'package:root_app/login.dart';
import 'package:root_app/theme/theme.dart';
import 'search_page.dart';
import 'my_page.dart';
import 'package:root_app/modals/change_modal.dart';

// TODO 임시
final String userId = '8a975eeb-56d1-4832-9d2f-5da760247dda';

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
