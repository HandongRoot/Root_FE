import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Pretendard',
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontFamily: 'Pretendard',
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black),
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.white,
  ),
);
