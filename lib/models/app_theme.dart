import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {

  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color lightGray = Color.fromRGBO(245, 245, 245, 1);
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color lightBlue = Color.fromRGBO(0, 89, 255, 1.0);
  static const Color skyBlue = Color.fromRGBO(70, 180, 255, 1.0);
  static const Color midnight = Color.fromRGBO(35, 35, 35, 1.0);
  static const Color inactiveGray = Color(0xFF999999);
  static const Color yellow = Color(0xFFFFF176);
  static const Color charCoal = Color.fromRGBO(45, 45, 45, 1.0);
  static const Color transparent =Color(0x00000000);
  static const Color red =Color(0xFFFF1F24);

  LightTheme lightTheme = LightTheme();
  DarkTheme darkTheme = DarkTheme();

  AppTheme();

  Future<void> save({bool upload = true}) async {

  }

  Future<void> delete({bool upload = true}) async {

  }

  Map<String, dynamic> toMap() {
    return {

    };
  }

}
