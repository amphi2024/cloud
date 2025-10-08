import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/channels/app_web_channel.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/utils/toast.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void onFailToCreateFile(BuildContext context) {
  showToast(context, AppLocalizations.of(context).get("failed_to_create"));
}

void pickFilesAndUpload({required String currentFolderId, required WidgetRef ref, required BuildContext context}) async {
  final result = await FilePicker.platform.pickFiles(allowMultiple: true);

  if(result != null) {
    for(var platformFile in result.files) {

      final file = File(platformFile.xFile.path);
      final fileStat = await file.stat();
      final jsonData = {
        "name": platformFile.name,
        "type": "file",
        "modified": (await platformFile.xFile.lastModified()).toUtc().millisecondsSinceEpoch,
        "created": fileStat.changed.toUtc().millisecondsSinceEpoch,
        "uploaded": DateTime.now().toUtc().millisecondsSinceEpoch,
        "parent_id": currentFolderId,
        "sha256": (await sha256.bind(file.openRead()).first).toString(),
        "size": platformFile.size
      };

      appWebChannel.createFile(data: jsonData, onSuccess: (id) {
        appWebChannel.uploadFileToCloud(id: id, filePath: platformFile.xFile.path, onSuccess: () {
          var fileModel = FileModel(id: id, data: jsonData);
          ref.read(filesProvider.notifier).insertFile(fileModel);
        }, onFailed: (code) {
          onFailToCreateFile(context);
        }, onProgress: (sent, total) {

        });
      }, onFailed: (code) {
        onFailToCreateFile(context);
      });
    }

  }
}

void createFolder({required String folderName, required String parentFolderId, required WidgetRef ref, required BuildContext context}) {
  var fileModel = FileModel(id: "", data: {
    "parent_id": parentFolderId,
    "type": "folder"
  });
  var dateTime = DateTime.now();
  fileModel.name = folderName;
  fileModel.modified = dateTime;
  fileModel.created = dateTime;
  fileModel.uploaded = dateTime;

  appWebChannel.createFile(data: fileModel.data, onSuccess: (id) {
    fileModel.id = id;
    ref.read(filesProvider.notifier).insertFile(fileModel);
  }, onFailed: (code) {
    showToast(context, AppLocalizations.of(context).get("failed_to_create_folder"));
  });
}