import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import '../models/app_settings.dart';

final appMethodChannel = AppMethodChannel.getInstance();

class AppMethodChannel extends MethodChannel {
  static final AppMethodChannel _instance = AppMethodChannel._internal("cloud_method_channel");

  AppMethodChannel._internal(super.name) {
    setMethodCallHandler((call) async {
      switch (call.method) {
        default:
          break;
      }
    });
  }

  int systemVersion = 0;

  static AppMethodChannel getInstance() => _instance;

  void setNavigationBarColor(Color color) {
    if (Platform.isAndroid) {
      invokeMethod("set_navigation_bar_color", {"color": color.value, "transparent_navigation_bar": appSettings.transparentNavigationBar});
    }
  }

  Future<void> getSystemVersion() async {
    systemVersion = await invokeMethod("get_system_version");
  }
}
