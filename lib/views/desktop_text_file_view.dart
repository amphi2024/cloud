import 'package:cloud/models/app_cache.dart';
import 'package:cloud/providers/text_file_view_width_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopTextFileView extends ConsumerWidget {
  final Widget child;
  const DesktopTextFileView({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = ref.watch(textFileViewWidthProvider);

    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: width,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                left: 0,
                bottom: 0,
                top: 0,
                child: GestureDetector(
                  onDoubleTap: () {
                    ref.read(textFileViewWidthProvider.notifier).set(defaultTextFileViewWidth);
                    appCacheData.textFileViewWidth = defaultTextFileViewWidth;
                    appCacheData.save();
                  },
                  onHorizontalDragUpdate: (d) {
                    ref.read(textFileViewWidthProvider.notifier).set(width - d.delta.dx);
                  },
                  onHorizontalDragEnd: (d) {
                    appCacheData.textFileViewWidth = width;
                    appCacheData.save();
                  },
                  child: SizedBox(
                    width: 10,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeColumn,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: GestureDetector(
                  onDoubleTap: () {
                    ref.read(textFileViewWidthProvider.notifier).set(defaultTextFileViewWidth);
                    appCacheData.textFileViewWidth = defaultTextFileViewWidth;
                    appCacheData.save();
                  },
                  onHorizontalDragUpdate: (d) {
                    ref.read(textFileViewWidthProvider.notifier).set(width + d.delta.dx);
                  },
                  onHorizontalDragEnd: (d) {
                    appCacheData.textFileViewWidth = width;
                    appCacheData.save();
                  },
                  child: SizedBox(
                    width: 10,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.resizeColumn,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
