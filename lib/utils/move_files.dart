import 'package:cloud/models/file_model.dart';
import 'package:desktop_listview/desktop_listview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_web_channel.dart';
import '../providers/files_provider.dart';

void moveSelectedFiles({required Set<String> selectedIds, required String oldParentId, required WidgetRef ref, required FileModel parent, DesktopListviewController? desktopListviewController, required Map<String, FileModel> files}) {
  if ((!parent.isFolder && parent.id.isNotEmpty) || parent.id == oldParentId) {
    return;
  }
  for(var id in selectedIds) {
    final model = files.get(id);
    model.parentId = parent.id;
    appWebChannel.updateFileInfo(fileModel: model);
  }
  ref.read(filesProvider.notifier).moveFiles(selectedIds.toList(), oldParentId, parent.id);
  desktopListviewController?.endSelection();
}