import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:cloud/channels/app_web_channel.dart';
import 'package:cloud/components/popup_menu_items.dart';
import 'package:cloud/dialogs/select_folder_dialog.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/fragment_index.dart';

List<Widget> appbarActions({
  required BuildContext context,
  required int fragmentIndex,
  required FileModel currentFolder,
  required List<String>? selectedItems,
  required WidgetRef ref,
  FileModel? showingFile,
}) {
  if (selectedItems != null) {
    switch (fragmentIndex) {
      case FragmentIndex.trash:
        return trashSelectionAction(ref: ref, context: context);
      default:
        return filesSelectionAction(
          ref: ref,
          context: context,
          currentFolder: currentFolder,
        );
    }
  }

  return [
    Visibility(
      visible: App.isDesktop() || App.isWideScreen(context),
      child: IconButton(
        onPressed: () {
          if (ref.read(searchKeywordProvider) == null) {
            ref.read(searchKeywordProvider.notifier).startSearch();
          } else {
            ref.read(searchKeywordProvider.notifier).endSearch();
          }
        },
        icon: Icon(Icons.search),
      ),
    ),
    PopupMenuButton(
      icon: Icon(Icons.more_vert_outlined),
      itemBuilder: (context) {
        if (fragmentIndex == FragmentIndex.trash) {
          return mainPagePopupMenuItems(
            context: context,
            ref: ref,
            sortOptionId: "!TRASH",
            showingFile: showingFile,
          );
        } else if (currentFolder.id.isEmpty) {
          return mainPagePopupMenuItems(
            context: context,
            ref: ref,
            sortOptionId: "!FILES",
            showingFile: showingFile,
          );
        } else {
          return mainPagePopupMenuItems(
            context: context,
            ref: ref,
            sortOptionId: currentFolder.id,
            folder: currentFolder,
            showingFile: showingFile,
          );
        }
      },
    ),
  ];
}

List<Widget> filesSelectionAction({
  required WidgetRef ref,
  required BuildContext context,
  required FileModel currentFolder,
}) {
  return [
    IconButton(
      onPressed: () {
        ref.read(selectedFilesProvider.notifier).endSelection();
      },
      icon: Icon(Icons.check_circle_outline),
    ),
    IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return SelectFolderDialog(
              excluding: ref.read(selectedFilesProvider)!,
              currentFolderId: currentFolder.id,
            );
          },
        );
      },
      icon: Icon(Icons.folder_copy),
    ),
    IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return ConfirmationDialog(
              title: AppLocalizations.of(context).get("@dialog_title_move_to_trash_selected_files"),
              onConfirmed: () {
                final list = ref.read(selectedFilesProvider)!;
                for (var id in list) {
                  var fileModel = ref.read(filesProvider).files.get(id);
                  fileModel.deleted = DateTime.now();
                  appWebChannel.updateFileInfo(fileModel: fileModel);
                }
                final currentFolder =
                    ref.read(historyProvider.notifier).currentFolder();
                ref
                    .read(filesProvider.notifier)
                    .moveFilesToTrash(currentFolder.id, list);
                ref.read(selectedFilesProvider.notifier).endSelection();
              },
            );
          },
        );
      },
      icon: Icon(Icons.delete),
    ),
  ];
}

List<Widget> trashSelectionAction({
  required WidgetRef ref,
  required BuildContext context,
}) {
  return [
    IconButton(
      onPressed: () {
        ref.read(selectedFilesProvider.notifier).endSelection();
      },
      icon: Icon(Icons.check_circle_outline),
    ),
    IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return ConfirmationDialog(
              title: AppLocalizations.of(context).get("@dialog_title_restore_selected_files"),
              onConfirmed: () {
                final list = ref.read(selectedFilesProvider)!;
                for (var id in list) {
                  var fileModel = ref.read(filesProvider).files.get(id);
                  fileModel.deleted = null;
                  fileModel.parentId = "";
                  appWebChannel.updateFileInfo(fileModel: fileModel);
                }
                ref.read(filesProvider.notifier).restoreFiles(list);
                ref.read(selectedFilesProvider.notifier).endSelection();
              },
            );
          },
        );
      },
      icon: Icon(Icons.restore),
    ),
    IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return ConfirmationDialog(
              title: AppLocalizations.of(context).get("@dialog_title_delete_selected_files"),
              onConfirmed: () {
                final list = ref.read(selectedFilesProvider)!;
                for (var id in list) {
                  appWebChannel.deleteFile(id: id);
                }
                ref.read(filesProvider.notifier).deleteFiles(list);
                ref.read(selectedFilesProvider.notifier).endSelection();
              },
            );
          },
        );
      },
      icon: Icon(Icons.delete),
    ),
  ];
}
