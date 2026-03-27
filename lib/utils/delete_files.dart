import 'package:desktop_listview/desktop_listview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_web_channel.dart';
import '../providers/files_provider.dart';
import '../providers/providers.dart';

void moveSelectedFilesToTrash({required WidgetRef ref, required Set<String> selectedIds, DesktopListviewController? desktopListviewController}) {
  for (var id in selectedIds) {
    var fileModel = ref.read(filesProvider).files.get(id);
    fileModel.deleted = DateTime.now();
    appWebChannel.updateFileInfo(fileModel: fileModel);
  }
  final currentFolder =
  ref.read(historyProvider.notifier).currentFolder();
  ref
      .read(filesProvider.notifier)
      .moveFilesToTrash(currentFolder.id, selectedIds.toList());
  ref.read(selectedFilesProvider.notifier).endSelection();
  desktopListviewController?.endSelection();
}

void restoreSelectedFiles({required WidgetRef ref, required Set<String> selectedIds, DesktopListviewController? desktopListviewController}) {
  for (var id in selectedIds) {
    var fileModel = ref.read(filesProvider).files.get(id);
    fileModel.deleted = null;
    fileModel.parentId = "";
    appWebChannel.updateFileInfo(fileModel: fileModel);
  }
  ref.read(filesProvider.notifier).restoreFiles(selectedIds.toList());
  ref.read(selectedFilesProvider.notifier).endSelection();
  desktopListviewController?.endSelection();
}