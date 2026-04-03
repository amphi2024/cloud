import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:cloud/components/popup_menu_items.dart';
import 'package:cloud/dialogs/select_folder_dialog.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/providers/providers.dart';
import 'package:cloud/utils/delete_files.dart';
import 'package:cloud/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/fragment_index.dart';

List<Widget> appbarActions({
  required BuildContext context,
  required int fragmentIndex,
  required FileModel currentFolder,
  required List<String>? selectedItems,
  required WidgetRef ref
}) {
  if (selectedItems != null) {
    switch (fragmentIndex) {
      case FragmentIndex.trash:
        return trashSelectionAction(ref: ref, context: context, selectedItems: selectedItems);
      default:
        return filesSelectionAction(
          ref: ref,
          context: context,
          currentFolder: currentFolder,
          selectedItems: selectedItems
        );
    }
  }

  return [
    // IconButton(
    //   onPressed: () {
    //     if (ref.read(searchKeywordProvider) == null) {
    //       ref.read(searchKeywordProvider.notifier).startSearch();
    //     } else {
    //       ref.read(searchKeywordProvider.notifier).endSearch();
    //     }
    //   },
    //   icon: Icon(Icons.search),
    // ),
    _SearchButton(),
    PopupMenuButton(
      tooltip: "",
      icon: Icon(Icons.grid_view_rounded),
      itemBuilder: (context) {
        if (fragmentIndex == FragmentIndex.trash) {
          return mainPagePopupMenuItems(
            context: context,
            ref: ref,
            sortOptionId: "!TRASH"
          );
        } else if (currentFolder.id.isEmpty) {
          return mainPagePopupMenuItems(
            context: context,
            ref: ref,
            sortOptionId: "!FILES"
          );
        } else {
          return mainPagePopupMenuItems(
            context: context,
            ref: ref,
            sortOptionId: currentFolder.id,
            folder: currentFolder
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
  required List<String>? selectedItems
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
                moveSelectedFilesToTrash(ref: ref, selectedIds: selectedItems!.toSet());
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
  required List<String>? selectedItems
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
                restoreSelectedFiles(ref: ref, selectedIds: selectedItems!.toSet());
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
                permanentlyDeleteSelectedFiles(ref: ref, selectedIds: selectedItems!.toSet());
              },
            );
          },
        );
      },
      icon: Icon(Icons.delete),
    ),
  ];
}

class _SearchButton extends ConsumerWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchKeyword = ref.watch(searchKeywordProvider);
    final isTablet_ = isWideScreen(context);

    if(isDesktop() || (searchKeyword == null && isTablet_)) {
      return IconButton(
        onPressed: () {
          if (ref.read(searchKeywordProvider) == null) {
            ref.read(searchKeywordProvider.notifier).startSearch();
          } else {
            ref.read(searchKeywordProvider.notifier).endSearch();
          }
        },
        icon: Icon(Icons.search),
      );
    }

    if(isTablet_) {

      final themeData = Theme.of(context);
      return SizedBox(
        width: 250,
        height: 40,
        child: TextField(
          onChanged: (text) {
            ref.read(searchKeywordProvider.notifier).setKeyword(text);
          },
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).get("hint_search_files"),
            prefixIcon: Icon(
              Icons.search,
              size: 15,
              color: themeData.disabledColor,
            ),
            suffix: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
              ref.read(searchKeywordProvider.notifier).endSearch();
            }, icon: Icon(Icons.cancel_outlined, size: 15)),
            contentPadding: EdgeInsets.all(8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: themeData.disabledColor,
                  style: BorderStyle.solid,
                  width: 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: themeData.disabledColor,
                  style: BorderStyle.solid,
                  width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: themeData.highlightColor,
                  style: BorderStyle.solid,
                  width: 2),
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }
}