
import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/dialogs/edit_filename_dialog.dart';
import 'package:cloud/dialogs/file_detail_dialog.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/models/sort_option.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/utils/export_file.dart';
import 'package:cloud/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_cache.dart';

List<PopupMenuItem> mainPagePopupMenuItems({
  required BuildContext context,
  required WidgetRef ref,
  required String sortOptionId,
  FileModel? folder,
  FileModel? showingFile
}) {
  final isTrash = sortOptionId == "!TRASH";
  var sortOption = appCacheData.sortOption(sortOptionId);
  sort() {
    if(isTrash) {
      ref.read(filesProvider.notifier).sortTrash();
    }
    else {
      ref.read(filesProvider.notifier).sortFiles(folder?.id);
    }
  }

  return [
    customItem(
      title: AppLocalizations.of(context).get("sort_by_name"),
      currentSortOption: sortOption,
      sortOption: SortOption.name,
      sortOptionDescending: SortOption.nameDescending,
      id: sortOptionId,
      sort: sort,
    ),
    customItem(
      title: AppLocalizations.of(context).get("sort_by_created"),
      currentSortOption: sortOption,
      sortOption: SortOption.created,
      sortOptionDescending: SortOption.createdDescending,
      id: sortOptionId,
      sort: sort,
    ),
    customItem(
      title: AppLocalizations.of(context).get("sort_by_modified"),
      currentSortOption: sortOption,
      sortOption: SortOption.modified,
      sortOptionDescending: SortOption.modifiedDescending,
      id: sortOptionId,
      sort: sort,
    ),
    customItem(
      title: AppLocalizations.of(context).get("sort_by_uploaded"),
      currentSortOption: sortOption,
      sortOption: SortOption.uploaded,
      sortOptionDescending: SortOption.uploadedDescending,
      id: sortOptionId,
      sort: sort,
    ),
    if(sortOptionId == "!TRASH") ...[
      customItem(
        title: AppLocalizations.of(context).get("sort_by_deleted"),
        currentSortOption: sortOption,
        sortOption: SortOption.deleted,
        sortOptionDescending: SortOption.deletedDescending,
        id: sortOptionId,
        sort: sort,
      ),
    ],
    customItem(
      title: AppLocalizations.of(context).get("sort_by_size"),
      currentSortOption: sortOption,
      sortOption: SortOption.size,
      sortOptionDescending: SortOption.sizeDescending,
      id: sortOptionId,
      sort: sort,
    ),
    if(folder != null)...[
      PopupMenuItem(child: Text(AppLocalizations.of(context).get("details")), onTap: () {
        showDialog(context: context, builder: (context) {
          return FileDetailDialog(fileModel: folder);
        });
      }),
      PopupMenuItem(child: Text(AppLocalizations.of(context).get("rename")), onTap: () {
        showDialog(context: context, builder: (context) {
          return EditFilenameDialog(initialValue: folder.name, onSave: (folderName) {
            renameFile(fileModel: folder, filename: folderName, ref: ref, context: context);
          });
        });
      }),
    ],
    if(showingFile != null) ...filePagePopupMenuItems(context: context, fileModel: showingFile, ref: ref)
  ];
}

PopupMenuItem customItem({
  required String title,
  required String currentSortOption,
  required String sortOption,
  required String sortOptionDescending,
  required String id,
  required void Function() sort,
}) {
  return PopupMenuItem(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Visibility(
          visible:
              currentSortOption == sortOption ||
              currentSortOption == sortOptionDescending,
          child: Icon(
            currentSortOption == sortOption
                ? Icons.arrow_upward
                : Icons.arrow_downward,
          ),
        ),
      ],
    ),
    onTap: () {
      if (currentSortOption == sortOption) {
        appCacheData.setSortOption(sortOption: sortOptionDescending, id: id);
      } else {
        appCacheData.setSortOption(sortOption: sortOption, id: id);
      }
      appCacheData.save();
      sort();
    },
  );
}

List<PopupMenuItem> filePagePopupMenuItems({required BuildContext context, required WidgetRef ref, required FileModel fileModel}) {
  return [
    PopupMenuItem(child: Text(AppLocalizations.of(context).get("details")), onTap: () {
      showDialog(context: context, builder: (context) {
        return FileDetailDialog(fileModel: fileModel);
      });
    }),
    PopupMenuItem(child: Text(AppLocalizations.of(context).get("rename")), onTap: () {
      showDialog(context: context, builder: (context) {
        return EditFilenameDialog(initialValue: fileModel.name, onSave: (filename) {
          renameFile(fileModel: fileModel, filename: filename, ref: ref, context: context);
        });
      });
    }),
    PopupMenuItem(child: Text(AppLocalizations.of(context).get("export")), onTap: () {
      exportFile(fileModel: fileModel, context: context, ref: ref);
    }),
    if(!fileModel.isFolder)  PopupMenuItem(child: Text(AppLocalizations.of(context).get(fileModel.isAvailableOffline ? "make_online_only" : "make_available_offline")), onTap: () {
      if(fileModel.isAvailableOffline) {
        fileModel.removeDownload(ref: ref);
      }
      else {
        fileModel.makeAvailableOnOffline(ref: ref);
      }
    }),
  ];
}