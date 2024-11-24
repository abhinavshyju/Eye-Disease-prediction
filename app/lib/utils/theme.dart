import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(backgroundColor: Colors.red)));
  }
}

class LightColor {
  static Color transperant = Color.fromARGB(0, 255, 255, 255);
  static Color primary = Color.fromRGBO(47, 39, 206, 1);
  static Color primary_dienabled = Color.fromRGBO(47, 39, 206, 0.30);
}
