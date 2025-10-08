import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/dialogs/edit_filename_dialog.dart';
import 'package:cloud/dialogs/file_detail_dialog.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/models/sort_option.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_web_channel.dart';
import '../models/app_cache.dart';
import '../utils/toast.dart';

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
            folder.name = folderName;
            folder.modified = DateTime.now();
            appWebChannel.updateFileInfo(fileModel: folder, onSuccess: () {
              ref.read(filesProvider.notifier).insertFile(folder);
            });
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
          fileModel.name = filename;
          fileModel.modified = DateTime.now();
          appWebChannel.updateFileInfo(fileModel: fileModel, onSuccess: () {
            ref.read(filesProvider.notifier).insertFile(fileModel);
          });
        });
      });
    }),
    PopupMenuItem(child: Text(AppLocalizations.of(context).get("export")), onTap: () async {
      final filePath = await FilePicker.platform.saveFile(
          fileName: fileModel.name,
          bytes: Uint8List.fromList([])
      );

      if(filePath != null) {
        appWebChannel.downloadFileFromCloud(id: fileModel.id, onSuccess: (bytes) async {
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          if(context.mounted) {
            showToast(context, AppLocalizations.of(context).get("export_successful"));
          }
        });
      }
    })
  ];
}