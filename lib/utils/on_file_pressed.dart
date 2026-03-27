
import 'package:cloud/pages/desktop_file_page.dart';
import 'package:cloud/utils/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/file_model.dart';
import '../pages/file_page.dart';
import '../pages/main_page.dart';
import '../providers/providers.dart';

void onFilePressed({required FileModel fileModel, required BuildContext context, required WidgetRef ref}) async {
  if(fileModel.deleted != null) {
    return;
  }
  if(fileModel.isFolder) {
    if(isDesktopOrTablet(context)) {
      ref.read(historyProvider.notifier).insertHistory(fileModel);
    }
    else {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => MainPage(folder: fileModel)));
    }
  }
  else {
    Navigator.push(context, PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        if(isDesktop()) {
          return DesktopFilePage(id: fileModel.id);
        }
        return FilePage(id: fileModel.id);
      },
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ));
  }
}