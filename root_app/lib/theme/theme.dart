import 'package:flutter/material.dart';

/* 
이 파일은 앱의 테마와 색상 관리띠띠 하는 파일 

사용 방법:
- 앱 전체 테마를 적용하려면 `AppTheme.appTheme`를 `MaterialApp`의 theme 속성에 추가가.
- 색상을 사용하려면면 `AppTheme.colorName` 를 쓰면 됨 (예: `AppTheme.primaryColor`).

EXAMPLE:
```dart
MaterialApp(
  theme: AppTheme.appTheme,  // AppTheme 전체에테마 적용
  home: MyHomePage(),
);

Text(
  '안녕하세요!',
  style: TextStyle(color: AppTheme.textColor),  // AppTheme 색상 적용
);
*/

class AppTheme {
  static const Color primaryColor = Color(0xFFebebeb);
  static const Color secondaryColor = Color(0xFF007AFF);
  static const Color accentColor = Color(0xFF203D77);
  static const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color textColor = Color(0xFF212121);
  static const Color iconColor = Color.fromRGBO(41, 96, 198, 1);
  static const Color buttonColor = Color(0xFFFFFFFF);
  static const Color buttonDividerColor = Color.fromRGBO(60, 60, 67, 0.36);
  static const Color appBarPrimaryColor = Color(0xFF00376E);

  static final ThemeData appTheme = ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: appBarPrimaryColor,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textColor),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: backgroundColor,
    ),
    primaryColor: primaryColor,
    secondaryHeaderColor: secondaryColor,
    hintColor: accentColor,
    iconTheme: const IconThemeData(color: iconColor),
  );
}
