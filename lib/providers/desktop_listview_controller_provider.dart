import 'package:desktop_listview/desktop_listview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final desktopListviewControllerProvider = Provider((ref) {
  final controller = DesktopListviewController();
  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});