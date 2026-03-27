import 'package:cloud/models/app_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TextFileViewWidthNotifier extends Notifier<double> {
  @override
  double build() {
    return appCacheData.textFileViewWidth;
  }

  void set(double value) {
    state = value;
  }
}

final textFileViewWidthProvider = NotifierProvider<TextFileViewWidthNotifier, double>(TextFileViewWidthNotifier.new);