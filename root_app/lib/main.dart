import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A simple DebugText widget that prints its fontFamily when built.
class DebugText extends StatelessWidget {
  final String data;
  final TextStyle? style;

  const DebugText(this.data, {this.style, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Print the fontFamily to the debug console.
    print("Rendering text with font: ${style?.fontFamily}");
    return Text(data, style: style);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeData appTheme = ThemeData(
    primarySwatch: Colors.blue,
    // Make sure your font 'Pretendard' is defined in pubspec.yaml and loaded.
    fontFamily: 'Pretendard',
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MaterialApp(
          title: 'Debug Text Test',
          theme: appTheme,
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              title: const DebugText(
                'Debug Text Test',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 20),
              ),
            ),
            body: Center(
              child: DebugText(
                'Hello, this is DebugText!',
                style: TextStyle(fontFamily: 'Pretendard', fontSize: 24.sp),
              ),
            ),
          ),
        );
      },
    );
  }
}
